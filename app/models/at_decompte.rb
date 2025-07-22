class AtDecompte < ApplicationRecord
  ETAT = {
    creation: 1,
    liquide: 2,
    soumission_medecin: 3,
    validation_medecin: 4,
    valide: 5,
    validation_comptable: 6,
    rejete: 7,

  }
  enum etat: ETAT
  MAX_NOMBRE_JOUR = 28
  NBRE_JOUR_POUR_TECH = 15
  scope :a_liquider, -> { where.not(date_liquidation: nil)}
  scope :can_be_liquidated, -> { where(date_liquidation: nil, etat: [:creation, :validation_medecin]) }
  scope :validation_agence, -> { where(etat: :validation_agence) }
  scope :a_valider, -> { where.not(date_validation: nil)}
  scope :a_valider_agence, -> { where.not(date_validation_agence: nil)}
  scope :a_valide_comptable, -> { where.not(date_validation_comptable: nil)}
  scope :a_valide_medecin, -> { where.not(date_validation_medecin: nil)}

  belongs_to :arret_travail
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :validation_comptable_par, class_name: 'User', foreign_key: :validation_comptable_par, optional: true
  belongs_to :validation_medecin_conseil_par, class_name: 'User', foreign_key: :validation_medecin_conseil_par, optional: true
  belongs_to :validation_par, class_name: 'User', foreign_key: :validation_par, optional: true
  belongs_to :liquide_par, class_name: 'User', foreign_key: :liquide_par, optional: true
  belongs_to :rejete_par, class_name: 'User', foreign_key: :rejete_par, optional: true
  belongs_to :convoquer_par, class_name: 'User', foreign_key: :convoquer_par_id, optional: true
  belongs_to :ordre_paiement, optional: true
  validate :date_debut_valid?
  has_one_attached :certificat_medical
  validates :certificat_medical, attached: false, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :nombre_jour, :date_debut, presence: true
  validate :period_valid?

  attr_accessor :solicite_medecin_displayed

  after_create :set_montant!
  before_save :set_date_fin!, :set_validation_medecin_obligatoire!
  after_save :generate_compta_transaction

  def est_liquide?
    !date_liquidation.nil?
  end

  def not_liquide?
    date_liquidation.nil?
  end
  
  def est_valide?
    !date_validation.nil?
  end

  def besoin_validation_medecin?
    !date_validation.nil? and need_validation_medecin and date_validation_medecin.nil?
  end

  def pas_besoin_validation_mc
    valide? and !besoin_validation_medecin?
  end

  def est_valide_medecin?
    !date_validation_medecin.nil? 
  end

  def yes_or_non_validation_medecin?
    puts "=====BOOL",need_validation_medecin
    if date_validation_medecin.nil? and need_validation_medecin
      return "OUI"
    end
    unless need_validation_medecin
      return "NON"
    end
  end

  def est_valide_comptable?
    !date_validation_comptable.nil?
  end

  def peut_etre_liquide?(current_user)
    arret_travail.current_state >=:accepte && 
    (current_user.technicien_at? || 
    current_user.technicien_direction_at?) &&
      (creation? or validation_medecin?)
  end

  def peut_etre_valide_liquidation?(current_user)
    arret_travail.current_state >=:accepte &&
    !arret_travail.gueris? && 
    (current_user.chef_division_at? or current_user.chef_agence?) && 
    liquide?
  end

  def peut_etre_valide_medecin?(current_user)
=begin
    arret_travail.current_state >= :accepte &&
      current_user.medecin_conseil? &&
      valide? && besoin_validation_medecin?
=end
    arret_travail.current_state >= :accepte &&
      current_user.medecin_conseil? &&
      soumission_medecin?
  end

  def peut_etre_valide_comptable?(current_user)
    arret_travail.current_state >= :accepte &&
      !arret_travail.gueris? &&
      current_user.comptable? && (valide?)
  end

  def liquider!(user)
    update(date_liquidation: DateTime.now.to_date, etat: :liquide, liquide_par: user, est_calculer: true)
  end

  def validation_medecin
    update(est_valide_medecin: true, date_validation_medecin: DateTime.now.to_date, etat: :validation_medecin)
  end

  def valider
    update(est_valide: true, date_validation: DateTime.now.to_date, etat: :valide)
  end

  def validation_comptable
    update(date_validation_comptable: DateTime.now.to_date, etat: :validation_compatable)
  end

  def retour_liquider
    update(date_liquidation: nil, etat: :creation)
  end

  def validation_medecin
    update(date_validation_medecin: nil, etat: :validation_medecin)
  end

  def retour_valider
    update(date_validation: nil, etat: :liquide)
  end

  def retour_validation_comptable
    update(date_validation_comptable: nil, etat: :validation)
  end


  def month_current_ij
    date_debut.strftime("%B").downcase
  end

  def current_month
    Time.now.strftime("%B").downcase
  end
  
  def indemnite_journaliere
    return arret_travail.indemnite_journaliere
  end

  def indemnite_total
=begin
    ij = indemnite_journaliere
    periode = arret_travail.at_decomptes
    return 0 if periode.empty?
=end
    it = 0
    it = (demi_sal(id) + deux_tiers_sal(id)).ceil 
    it
  end

  def last_record
    last_record = arret_travail.at_decomptes
                               .where.not(id: id) # exclut l'objet courant
                               .order(date_fin: :desc)
                               .first
    return last_record
  end

   def first_record
     return arret_travail.at_decomptes.first unless arret_travail.at_decomptes.nil?
   end
 
  def msg_error
    msg = errors.full_messages.last
   return msg
  end


  def need_validation_medecin
    return false if first_record.present? && first_record.id == self.id
    return true  if duree_ij >= NBRE_JOUR_POUR_TECH
  end

  def montant
    return arrondir_cfa(indemnite_total)
  end

  def periode_ij
    return "du #{date_debut.strftime('%d/%m/%Y')} au #{set_date_fin!.strftime('%d/%m/%Y')}"
  end

  def duree_ij
    return ((date_fin - date_debut) + 1).to_i
  end

  def can_rejet?(current_user)
    ((current_user.chef_agence? || current_user.chef_division_at?) and valide?) || 
    (current_user.medecin_conseil? and !est_valide_medecin?)  || 
    (current_user.chef_agence? and !est_valide_comptable?) 

  end

  def can_convoquer?(current_user)
    # (current_user.medecin_conseil? and !est_valide_medecin?)
    (current_user.medecin_conseil? and soumission_medecin?)
  end

  

  def nb_jour_total_ij
    nbJourTotal = 0
    arret_travail.at_decomptes.each do |arret|
     duree_ij= ((arret.nombre_jour)+1).to_i
     nbJourTotal+=duree_ij
    end
    return nbJourTotal
  end

  def nb_jour_indemnises
    nb_jour = []
    nbJourTotal = 0
    listDecomptes = []
    arret_travail.at_decomptes.order('created_at asc').each_with_index do |arret, index|
      duree_ij = arret.nombre_jour
      nbJourTotal += duree_ij
      if nbJourTotal < 28
        nb_jour << { :key => arret.id, :demi_salaire => duree_ij, :deux_tiers => 0 }
      else
        res = nbJourTotal - 28
        if (duree_ij - res) > 0
          nb_jour << { :key => arret.id, :demi_salaire => (duree_ij - res), :deux_tiers => res }
        else
          nb_jour << { :key => arret.id, :demi_salaire => 0, :deux_tiers => duree_ij }
          
        end 
      end
    end
    return nb_jour
  end

  def demi_sal(pk) 
    demi_salaire=0
    ij =  indemnite_journaliere
    nb_jour_indemnises.each_with_index do |key, value|
      demi_salaire= key[:demi_salaire] if pk == key[:key]
    end
    montant = (ij / 2 * demi_salaire).to_f.ceil 
    return arrondir_cfa(montant)
  end

  def deux_tiers_sal(pk)
    demi_salaire=0
    ij = indemnite_journaliere
    nb_jour_indemnises.each_with_index do |key, value|
      demi_salaire = key[:deux_tiers] if pk == key[:key]
    end
    montant = ((ij *2/3) * demi_salaire).to_f.ceil 
    return arrondir_cfa(montant)
  end

  def duree_ij_last_record
    return last_record.duree_ij
  end

  def nb_jour_total_ij_before
    return nb_jour_total_ij - duree_ij_last_record
  end

  def can_rejete?(current_user)
=begin
    ((current_user.chef_agence? || current_user.chef_division_at?) and liquide?) or
    (current_user.medecin_conseil? and valide?) or (current_user.comptable? and (valide? || validation_medecin?))
=end
    ((current_user.chef_agence? || current_user.chef_division_at?) and liquide?) or
      (current_user.medecin_conseil? and soumission_medecin?) or (current_user.comptable? and valide?)
  end

  def valider_paiements(user)
    self.date_validation_comptable = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
    self.etat = :validation_comptable
    self.validation_comptable_par = user
    self.paiement = true
    unless self.save
      puts 'Error saving at_decompte:', self.errors.full_messages
    end
  end

  private

  def generate_compta_transaction
    return if est_repris?
    return if montant.nil? or montant.to_i <= 0
    num_paiement = ""
    nom_benef = ""
    prenom_benef = ""
    adr_benef = ""
    if validation_comptable? and not ComptaTransaction.exists?(dossier: self, statut: [:paye, :en_cours])
      if ordre_paiement.nil?
        if not self.arret_travail.is_subrogation?
          if not self.arret_travail.est_journalier?
            num_paiement = self.arret_travail.numero_affiliation
          else
            num_paiement = self.arret_travail.nin_salarie
          end          
            nom_benef = self.arret_travail.try(:nom_salarie)
            prenom_benef = self.arret_travail.try(:prenom_salarie)
            adr_benef = self.arret_travail.try(:adresse_domiciliaire_salarie)
        else
            num_paiement = self.arret_travail.numero_employeur
            nom_benef = self.arret_travail.try(:raison_sociale_employeur)
            prenom_benef = self.arret_travail.try(:raison_sociale_employeur)
            adr_benef = self.arret_travail.try(:adresse_employeur)
        end

        return if num_paiement.nil? || num_paiement.strip.empty?
        
        self.ordre_paiement = OrdrePaiement.create(dossier: self.arret_travail,
                                                      numero_allocataire: num_paiement)
              ComptaTransaction.create(
              en_tete: true,
              dossier: self,
              ordre_paiement: ordre_paiement,
              code_operation: 'AT_IJ',
              code_classe_evenement: 'LIQUIDATION',
              code_agence_liquidation: validation_comptable_par.agence.try(:code_psrm) || 'C_SG', # à définir
              numero_allocataire: num_paiement,
              nom: nom_benef,
              prenom: prenom_benef,
              adresse: adr_benef,
              mode_paiement: montant.to_i < 100000 ? :caisse_css : :cheque,
              code_banque_allocataire: nil,
              numero_compte_allocataire: nil,
              date_debut_periode: nil,
              date_fin_periode: nil,
              montant: montant,
              code_devise: 'XOF',
              statut: :en_cours,
              description: "AT decompte, IJ : #{prenom_benef}",
              )
              self.save
      end      
    end
  end

  def arrondir_cfa(mnt)
    arr = mnt.round
    while arr % 5 != 0 do
      arr = arr.next
    end
    arr
  end

  def date_debut_valid?
    return unless creation?
    if date_debut.to_date <= arret_travail.date_accident.to_date
      errors.add(:date_debut, "doit etre superieur  date accident")
    end
    if last_record.date_fin.to_date >= date_debut.to_date
      errors.add(:date_debut, "doit etre supérieure à la date de fin du précedent arret")
    end unless last_record.nil?
  end

  def period_valid?
    return unless creation?
    arret_travail.at_decomptes.where.not(id: id).each do |dpt|
      if date_debut.between?(dpt.date_debut, dpt.date_fin)
        errors.add(:date_debut, "ne doit figurer dans aucune période")
        break
      end
      if set_date_fin!.between?(dpt.date_debut, dpt.date_fin)
        errors.add(:date_fin, "ne doit figurer dans aucune période")
        break
      end
    end
  end

  def set_montant!
    self.montant = arrondir_cfa(indemnite_total)
    self.save
    puts "MONTANT", arret_travail.indemnite_total
  end

  def set_nombre_jour!
    self.nombre_jour = (date_fin - date_debut) + 1
  end

  def set_date_fin!
    self.date_fin = (date_debut + (nombre_jour-1)) 
  end

  def set_validation_medecin_obligatoire!
    return unless creation?
    self.validation_medecin_obligatoire = need_validation_medecin
    self.solicite_medecin = need_validation_medecin
    self.etat = validation_medecin_obligatoire ? :soumission_medecin : :creation
  end



end

