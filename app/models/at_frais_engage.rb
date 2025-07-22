class AtFraisEngage < ApplicationRecord
  belongs_to :arret_travail
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :validation_comptable_par, class_name: 'User', foreign_key: :validation_comptable_par, optional: true
  belongs_to :validation_medecin_conseil_par, class_name: 'User', foreign_key: :validation_medecin_conseil_par, optional: true
  belongs_to :validation_par, class_name: 'User', foreign_key: :validation_par, optional: true
  belongs_to :liquide_par, class_name: 'User', foreign_key: :liquide_par, optional: true
  belongs_to :rejete_par, class_name: 'User', foreign_key: :rejete_par, optional: true
  belongs_to :ordre_paiement, optional: true

  TYPE_FRAIS = {
    medecin: 1,
    hopitaux: 2,
    pharmacien: 3,
    autre_fournisseurs: 4,
    divers: 5,
    soins_medicaux: 6,
    hospitalisation: 7,
    frais_phamaceutiques: 8,
    frais_de_transport: 9,
    prothese: 10,
    frais_funeraire: 11,
    autres: 12
  }

  REMBOURSE_A_QUI = {
    victime: 1,
    employeur: 2
  }
  ETAT = {
    creation: 1,
    liquide: 2,
    valide: 3,
    validation_comptable: 4,
    validation_medecin: 5,
    rejete: 6
  }
  enum etat: ETAT

  enum type_frais: TYPE_FRAIS
  enum rembourse_a_qui: REMBOURSE_A_QUI

  scope :can_be_liquidated, -> { where(date_liquidation: nil, etat: [:creation]) }
  #scope :a_liquider, -> { where(date_liquidation: nil) }
  scope :a_liquider, -> { where.not(date_liquidation: nil) }
  scope :valide_comptable, -> { where(etat: :validation_compatable) }
  scope :a_valider, -> { where.not(date_validation: nil) }
  scope :a_valide_comptable, -> { where.not(date_validation_comptable: nil) }
  scope :a_valide_medecin, -> { where.not(date_validation_medecin: nil) }

  before_create :set_frais_number!
  after_save :generate_compta_transaction

  def montant_en_chiffre
    self.montant.to_f
  end

  def liquider!(user)
    update(date_liquidation: DateTime.now.to_date, etat: :liquide, liquide_par: user)
  end

  def a_liquider?
    date_liquidation.nil?
  end

  def est_liquide?
    !date_liquidation.nil?
  end

  def est_valide?
    !date_validation.nil?
  end

  def est_valide_comptable?
    !date_validation_comptable.nil?
  end
  def est_valide_medecin?
    !date_validation_medecin.nil?
  end

  def peut_etre_liquide?(current_user)
    (arret_travail.current_state >=:accepte) &&
    !arret_travail.gueris? && 
    (current_user.technicien_at? || current_user.technicien_direction_at?) &&
    creation?

  end
  
  def peut_etre_valide?(current_user)
    arret_travail.current_state >=:liquidation_valide &&
     !arret_travail.gueris? && 
      current_user.comptable? && est_valide?
  end

  def peut_etre_valide_medecin?(current_user)
    arret_travail.current_state >=:accepte && !arret_travail.gueris? &&  current_user.medecin_conseil? && est_liquide?
  end

  def peut_etre_valider_liquidation?(current_user)
    arret_travail.current_state >=:liquidation_soumis && 
    !arret_travail.gueris? && 
    (current_user.chef_division_at? or current_user.chef_agence?) && est_liquide?
  end

  def peut_etre_valide_liquidation?(current_user)
    arret_travail.current_state >=:accepte &&
    !arret_travail.gueris? && 
    (current_user.chef_division_at? or current_user.chef_agence?) && 
    liquide?
  end

  def peut_etre_valide_comptable?(current_user)
    arret_travail.current_state >=:accepte &&
    !arret_travail.gueris? &&
    current_user.comptable? && validation_medecin?
  end

  def liquider
    update(date_liquidation: DateTime.now.to_date, etat: :liquidation)
  end

  def retour_liquider
    update(date_liquidation: nil, etat: :creation)
  end

  def validation_medecin
    update(est_valide_medecin: true, date_validation_medecin: DateTime.now.to_date, etat: :validation_medecin)
  end

  def valider
    update(est_valide: true, date_validation: DateTime.now.to_date, etat: :validation)
  end

  def retour_valider
    update(date_validation: nil, etat: :liquidation)
  end

  def validation_comptable
    update(date_validation_comptable: DateTime.now.to_date, etat: :validation_compatable)
  end

  def retour_validation_comptable
    update(date_validation_comptable: nil, etat: :validation)
  end

  def can_rejete?(current_user)
    ((current_user.chef_agence? || current_user.chef_division_at?) and liquide?) or
      (current_user.medecin_conseil? and valide?) or (current_user.comptable? and (valide? || validation_medecin?))
  end

  def valider_paiements(user)
    self.date_validation_comptable = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
    self.etat = :validation_comptable
    self.validation_comptable_par = user
    self.paiement = true
    unless self.save
      puts 'Error saving at_frais_engages:', self.errors.full_messages
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
        puts'rembourse à qui :', rembourse_a_qui
        if rembourse_a_qui == 'victime'
          if not self.arret_travail.est_journalier?
            num_paiement = self.arret_travail.numero_affiliation
          else
            num_paiement = self.arret_travail.nin_salarie
          end          
            nom_benef = self.arret_travail.try(:nom_salarie)
            prenom_benef = self.arret_travail.try(:prenom_salarie)
            adr_benef = self.arret_travail.try(:adresse_domiciliaire_salarie)
        elsif rembourse_a_qui == 'employeur'
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
                  code_operation: 'AT_FR_ENG',
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
                  description: "AT frais engagés, : #{prenom_benef}",
                )            
                self.save
      end
    end
  end

  def set_frais_number!
    annee = Date.today.year
    if prev_number_exist?
      dernier_dossier_ajoute = AtFraisEngage.where(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year)).order('created_at DESC').first
      self.numero = dernier_dossier_ajoute.numero.next
    else
      self.numero = "#{annee}/DOSSPR0001"
    end
  end

  def prev_number_exist?
    AtFraisEngage.exists?(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year))
  end
end