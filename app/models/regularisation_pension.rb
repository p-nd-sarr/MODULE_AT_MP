class RegularisationPension < ApplicationRecord
  include Documentable
  include WorkflowActiverecord
  
  MOTIF_REGULARISATION_PENSION = {
    annulation_de_suspension: 1,
    reordonnancement_de_pension: 2,
    regularisation_pour_les_majorants: 3,
    annulation_de_suspension_avec_rappel: 4,
    autre_motif: 5,
    pension_heredite: 6
  }.freeze

  TYPE_DOCUMENT_OBLIGATOIRE = {

  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      cni: 1,
      certificat_vie_individuelle: 62,
      formulaire_demande: 90,
    }
  ).freeze

  TYPE_DOCUMENT_HEREDITE = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      cni: 1,
      certificat_jugement_heredite: 101
    }
  ).freeze

  InvalidTransitionError = Class.new(StandardError)

  workflow_column :workflow_state

  workflow do
    state :creation, :meta => { label: 'Création' } do
      event :est_soumis_chef_agence, transition_to: :soumis_chef_agence
      event :est_soumis_chef_section_liquidation, transition_to: :soumis_chef_section_liquidation
    end

    state :soumis_chef_agence, :meta => { label: 'Soumis chef agence' } do
      event :est_soumis_chef_section_liquidation, transition_to: :soumis_chef_section_liquidation
      event :retour_creation, transition_to: :creation
    end


    state :soumis_chef_section_liquidation, :meta => { label: 'Soumis chef section liquidation' } do
      event :est_soumis_chef_service, transition_to: :soumis_chef_service
      event :retour_soumis_chef_agence, transition_to: :soumis_chef_agence
      event :retour_creation, transition_to: :creation
    end

    state :soumis_chef_service, :meta => { label: 'Soumis chef service allocation' } do
      event :est_soumis_directeur, transition_to: :soumis_directeur
      event :retour_soumis_chef_section_liquidation, transition_to: :soumis_chef_section_liquidation
    end

    state :soumis_directeur, :meta => { label: 'Soumis directeur prestation' } do
      event :est_soumis_inspection, transition_to: :soumis_inspection
      event :est_dossier_rejete, transition_to: :dossier_rejete
      event :retour_soumis_chef_service, transition_to: :soumis_chef_service
    end

    # state :validation_directeur do
    #   event :est_soumis_inspection, transition_to: :soumis_inspection
    #   event :est_dossier_rejete, transition_to: :dossier_rejete
    #   event :retour_soumis_directeur, transition_to: :soumis_directeur
    # end

    state :soumis_inspection, :meta => { label: 'Soumis inspection' } do
      event :est_validation_inspection, transition_to: :validation_inspection
      event :est_dossier_rejete, transition_to: :dossier_rejete
      event :retour_soumis_directeur, transition_to: :soumis_directeur
    end

    state :validation_inspection, :meta => { label: 'Validation inspection' }
    state :dossier_rejete

    on_transition do |from, to, triggering_event, *event_args|
      puts "#{from} -> #{to}"
    end

    #  use after transition for historisation
    after_transition do
      puts "=> traite par : #{self.traite_par}"
    end

    on_error do |error, from, to, event, *args|
      puts "Exception(#error.class) on #{from} -> #{to}"
    end
  end

  ETAT = {
      creation: 1,
      soumis: 2,
      affecte: 3,
      valide: 4,
      regularise: 5,
      rejete: 6,
      annuler: 7
  }.freeze

  enum motif_regularisation_pension: MOTIF_REGULARISATION_PENSION
  enum etat: ETAT

  has_one_attached :attachment
  belongs_to :allocataire,
    foreign_key: :numero_allocataire,
    primary_key: :numero_allocataire
  has_many :documents, as: :documentable, dependent: :destroy
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true
  belongs_to :validation_agence_par, class_name: 'User', foreign_key: :validation_agence_par_id, optional: true
  belongs_to :validation_service_par, class_name: 'User', foreign_key: :validation_service_par_id, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  belongs_to :validation_direction_par, class_name: 'User', foreign_key: :validation_direction_par_id, optional: true
  belongs_to :validation_inspection_par, class_name: 'User', foreign_key: :validation_inspection_par_id, optional: true
  belongs_to :validation_chef_section_par, class_name: 'User', foreign_key: :validation_chef_section_par_id, optional: true

  has_one :reg_beneficiary, foreign_key: :regularisation_pensions_id, dependent: :destroy
  has_many :enfants, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  belongs_to :agence_creation, :class_name => 'Admin::Agence', foreign_key: :agence_creation_id, optional: true
  has_one_attached :attachment
  has_many :regularisation_impayes, dependent: :destroy
  delegate :filename, to: :attachment, allow_nil: true
  validates :attachment, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, attached: true

  scope :periode, ->(date_debut, date_fin) { where("date_validation > ? AND date_validation < ?", date_debut, date_fin) }
  scope :meme_agence, ->(id) { where("agence_creation_id = ?", id) }

  scope :en_attente_validation_chef_service, -> { where(workflow_state: [:soumis_chef_service]) }
  scope :en_attente_validation_chef_agence, -> { where(workflow_state: [:soumis_chef_agence]) }
  scope :en_attente_validation_chef_section, -> { where(workflow_state: [:soumis_chef_section_liquidation]) }
  scope :en_attente_validation_dp, -> { where(workflow_state: [:soumis_directeur]) }
  scope :en_attente_validation_inspection, -> { where(workflow_state: [:soumis_inspection]) }

  validate :validate_numero_affiliation, on: :create
  validate :max_enfant_pris_en_charge, on: :create
  validate :validate_date_suspension, on: :create
  validate :validate_dates_regularisation, on: :create
  
  
  validate :validate_reordonnancement_pension, on: :save
  validate :validate_annulation_de_suspension, on: :create
  before_create :set_numero_dossier!, :set_duree_suspension!, :set_agence_creation!, :validate_dates_regularisation
  before_create :set_pourcentage_majoration!, :set_nb_enfant_a_regulariser!
  after_create :recalculer_points_majoration
  after_create :load_impayes
  after_save :regulariser_impayes

  validates :date_fin_regularisation, :date_debut_regularisation, :comment_gestionnaire,
            presence: true,
            if: -> { annulation_de_suspension_avec_rappel? },
            on: :create
  validates :autre_montant,
          presence: true,
          if: -> { autre_motif? },
          on: :create

  delegate :filename, to: :attachment, allow_nil: true
  after_save :generate_compta_transaction

  def set_duree_suspension!
    allocataire = Allocataire.find_by(numero_allocataire: numero_allocataire)
    if annulation_de_suspension?
      self.duree_suspension = ((Date.today.month - 0) / 1.month.second).to_i.abs
    end
    if reordonnancement_de_pension?
      self.nb_mois_retournes = allocataire.paiement_allocataires.retournes.size
    end
    if regularisation_pour_les_majorants?
      self.duree_suspension = nombre_mois_regul
    end
    if annulation_de_suspension_avec_rappel?
      self.duree_suspension = (((date_fin_regularisation.month - date_debut_regularisation.month))).to_i
    end
  end

  def set_montant_net
    allocataire = Allocataire.find_by(numero_allocataire: numero_allocataire)
    montant_net = allocataire.montant_net.floor
  end

  def etat_civil_demandeur_valide!(est_valide = true)
    update!(etat_civil_demandeur_valide: est_valide)
  end

  def beneficiaire_valide!(est_valide = true)
    update!(beneficiaire_valide: est_valide)
  end

  def documents_valide!(est_valide = true)
    update!(documents_valide: est_valide)
  end

  def pret_pour_soumission?
    etat_civil_demandeur_valide and documents_valide and impayes_non_traites and beneficiary_valid
  end

  def beneficiary_valid
    !pension_heredite? or (pension_heredite? and beneficiaire_valide)
  end

  def enfants_majoration
    enfants.valide.mineurs.
      where("date_naissance <= ?", instruit_le || DateTime.now).
      order('date_naissance DESC, created_at').
      limit(nb_enfant_restant_pour_majoration)
  end

  def nb_enfant_restant_pour_majoration
    allocataire = Allocataire.find_by(numero_allocataire: numero_allocataire)
    3 - allocataire.enfants_majoration.count
  end

  def nb_enfant_pour_majoration
    allocataire = Allocataire.find_by(numero_allocataire: numero_allocataire)
    allocataire.enfants.valide.mineurs.count - allocataire.enfants_majoration.count
  end

  def taux_majoration
    taux = [15, 5 * nb_enfant_pour_majoration].min
    (1.0 * taux)
    taux
  end

  def points_base_rc
    allocataire = Allocataire.find_by(numero_allocataire: numero_allocataire)
    allocataire.points_base_rc
  end

  def points_base_rg
    allocataire = Allocataire.find_by(numero_allocataire: numero_allocataire)
    allocataire.points_base_rg
  end

  def point_minoration_rc
    (points_base_rc * pourcentage_majoration/100).round
  end

  def point_minoration_rg
    (points_base_rg * pourcentage_majoration/100).round
  end

  def calcul_montant_majoration_rg
    if allocataire.versement_unique?
      salaire_reference = Admin::Bareme.salaire_reference_general_du(Date.today)
      (point_minoration_rg * salaire_reference).ceil(2)
    else
      valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_general_du(Date.today)
      (point_minoration_rg * valeur_point_mensuelle).ceil(2)
    end
  end

  def salaire_reference_rg
    Admin::Bareme.salaire_reference_general_du(Date.today)
  end

  def salaire_reference_rcc
    Admin::Bareme.salaire_reference_cadre_du(Date.today)
  end

  def valeur_point_rg
    Admin::BaremePension.valeur_mensuelle_general_du(Date.today)
  end

  def valeur_point_rcc
    Admin::BaremePension.valeur_mensuelle_cadre_du(Date.today)
  end

  def calcul_montant_majoration_rc
    if allocataire.versement_unique?
      salaire_reference = Admin::Bareme.salaire_reference_cadre_du(Date.today)
      (point_minoration_rc * salaire_reference).ceil(3)
    else
      valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_cadre_du(Date.today)
      (point_minoration_rc * valeur_point_mensuelle).ceil(3)
    end
  end

  def montant_a_regulariser
    (calcul_montant_majoration_rg + calcul_montant_majoration_rc).round
  end

  def date_debut_regul
    allocataire.date_jouissance.try(:beginning_of_month)
  end

  def periode_regul_majoration
    date_debut = date_debut_regul
    date_fin = date_soumission
    unless date_fin.nil? and date_debut.nil?
      return "#{date_debut.strftime("%d/%m/%Y")} - #{date_fin.strftime("%d/%m/%Y")}" 
    else
      return ""
    end
  end

  def nombre_mois_regul
    nb_mois = ((date_soumission.to_time - date_debut_regul.to_time)/1.month.second).to_i unless date_soumission.nil?
    if allocataire.versement_unique? or nb_mois==0
      return 1
    else
        return nb_mois
    end
  end

  def montant_total_a_regularise
    self.montant_regularisation= (nombre_mois_regul * montant_a_regulariser)
  end

  def set_montant_a_payer
    if annulation_de_suspension?
      self.montant_regularisation = (set_montant_net.to_f * duree_suspension.to_f).floor   
    end 
    if reordonnancement_de_pension?
      self.montant_regularisation = (set_montant_net.to_f * nb_mois_retournes.to_f).floor    
    end
    if regularisation_pour_les_majorants?
      self.montant_regularisation = nombre_mois_regul * montant_a_regulariser
    end
  end

  def impayes_soumis
    return true if regularisation_impayes.impayes_soumis.size > 0
  end

  def impayes_valides
    return true if regularisation_impayes.valide.size > 0 and reordonnancement_de_pension?
  end

  def impayes_non_traites
    return true if regularisation_impayes.non_traites.size == 0
  end

  def creer_au_siege?
    return true if ajoute_par.agence.code_site == "10" 
    return true if ajoute_par.agence.code_site == "14" 
    return true if ajoute_par.agence.code_site == "19" 
    return false                   
  end

  def meme_agence1?(current_user)
    ajoute_par.agence == current_user.agence
  end

  def validation_impayes?(current_user)
    (soumis_chef_agence? and current_user.chef_agence? and meme_agence1?(current_user)) or 
    (current_user.chef_service_allocation? and soumis_chef_service?)
  end 

  def montant_impayes
    regularisation_impayes.valide.map{|op| op.montant}.sum
  end

  def set_agence_creation!
    self.agence_creation = ajoute_par.try(:admin_agence)
  end

  def chef_agence_peut_valider(current_user)
    soumis_chef_agence? and meme_agence1?(current_user) and current_user.chef_agence? 
  end 

  def chef_service_peut_valider(current_user)
    soumis_chef_service?  and current_user.chef_service_allocation? and impayes_valides
  end 

  def calcul_duree_suspension
    return 0 unless annulation_de_suspension_avec_rappel?
    return 0 if date_fin_regularisation.nil? and date_debut_regularisation.nil?
    ((date_fin_regularisation.year - date_debut_regularisation.year) * 12 + date_fin_regularisation.month - date_debut_regularisation.month - (date_fin_regularisation.day >= date_debut_regularisation.day ? 0 : 1))
  end

  ########## Regularisation avec rappel ####################

  def debuts_mois
    return [] if date_debut_regularisation.nil? and date_fin_regularisation.nil?
    (date_debut_regularisation..date_fin_regularisation).map(&:beginning_of_month).uniq #.map {|d| d.strftime "%d/%m/%Y" }
  end

  def fins_mois
    return [] if date_debut_regularisation.nil? and date_fin_regularisation.nil?
    (date_debut_regularisation..date_fin_regularisation).map(&:end_of_month).uniq #.map {|d| d.strftime "%d/%m/%Y" }
  end

  def liste_periode_rappel
    list_periode = []
    unless debuts_mois.length.nil?
      (1..(debuts_mois.length - 1)).each { |i|

        vp_cadre = valeur_point_cadre(debuts_mois[i])
        vp_general = valeur_point_general(debuts_mois[i])

        montant_rapel = if debuts_mois[i].nil?
                          0
                        else
                          (vp_general * allocataire.points_servis_rg + vp_cadre * allocataire.points_servis_rc).ceil(0)
                        end

        objson = { 'periode' => "#{debuts_mois[i].strftime "%d/%m/%Y"} au #{fins_mois[i].strftime "%d/%m/%Y"}",
                   'val_point_cadre' => vp_cadre,
                   'val_point_general' => vp_general,
                   'points_servis_rg' => allocataire.points_servis_rg,
                   'points_servis_rc' => allocataire.points_servis_rc,
                   'montant_rappel' => montant_rapel
        }
        list_periode.push(objson)
      }
    end
    list_periode
  end

    def calcul_montant_rappel
    (calcul_montant_rappel_regime_general + calcul_montant_rappel_regime_cadre)
  end

  def calcul_montant_total_rappel
    liste_periode_rappel.map{|mnt| mnt['montant_rappel']}.sum
  end


  def montant_total_regularise
    if autre_motif?
      return 0 if autre_montant.nil?
      return autre_montant
    end

    if reordonnancement_de_pension?
      return 0 if autre_montant.nil?
      return montant_impayes
    end

    if annulation_de_suspension_avec_rappel?
       return 0 if calcul_montant_total_rappel.nil?
       return calcul_montant_total_rappel
    end
    0
  end

  def calcul_montant_rappel_regime_general
    valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_general_du(Date.today)
    (allocataire.points_servis_rg * valeur_point_mensuelle).ceil
  end

  def calcul_montant_rappel_regime_cadre
    valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_cadre_du(Date.today)
    (allocataire.points_servis_rc * valeur_point_mensuelle).ceil
  end

  def valeur_point_rc
    Admin::BaremePension.valeur_mensuelle_cadre_du(Date.today).ceil(2)
  end

  def valeur_point_rg
    Admin::BaremePension.valeur_mensuelle_general_du(Date.today).ceil(2)
  end

  private

  def set_numero_dossier!
    annee = Date.today.year
    self.numero_dossier = "REG/#{numero_allocataire}/#{annee}"
  end

  def set_pourcentage_majoration!
    self.pourcentage_majoration = taux_majoration
  end

  def set_nb_enfant_a_regulariser!
    self.nb_enfant_a_regulariser =  nb_enfant_pour_majoration
  end

  def set_nb_enfant_a_regulariser!
    self.nb_enfant_a_regulariser =  nb_enfant_pour_majoration
  end

  def validate_numero_affiliation
    return if numero_allocataire.nil?
    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Allocataire.where(numero_allocataire: numero_allocataire).exists?
  end

  def validate_reordonnancement_pension
    allocataire = Allocataire.find_by(numero_allocataire: numero_allocataire)
    if reordonnancement_de_pension? 
      nb_impayes=allocataire.ordre_paiements.impaye.size unless allocataire.ordre_paiements.nil?
      if nb_impayes<=0
        errors.add("Erreur!", "Pas de impayés")
      end
    end
  end
  
  def validate_annulation_de_suspension
    allocataire = Allocataire.find_by(numero_allocataire: numero_allocataire)
    if annulation_de_suspension?
      unless allocataire.suspendus?
        errors.add("Erreur!", "L'allocataire n'est pas suspendu")
      end
    end
  end

  def validate_date_suspension
    if annulation_de_suspension?
      if date_suspension_allocataire.nil?
        errors.add("Erreur!", "La date de suspension est obligatoire")
      end
      unless date_suspension_allocataire  <= (Date.today - 1.month)
        errors.add("Erreur!", "La date de suspension doit avoir au moins un mois")
      end
    end
  end

  def max_enfant_pris_en_charge
    allocataire = Allocataire.find_by(numero_allocataire: numero_allocataire)
    if regularisation_pour_les_majorants?
        unless allocataire.enfant3_id.nil? || allocataire.enfant2_id.nil? || allocataire.enfant1_id.nil?
          errors.add("Erreur! ", "Le nombre maximun d'enfant pris en charge est atteint")
       end
       if nb_enfant_pour_majoration<=0
        errors.add("Erreur!", "Tous les enfants sont déjà pris en charge")
      end
    end
  end

  def recalculer_points_majoration
    allocataire = Allocataire.find_by(numero_allocataire: numero_allocataire)
    allocataire.enfant1 = allocataire.enfants_pas_en_charge.first
    allocataire.enfant2 = allocataire.enfants_pas_en_charge.first
    allocataire.enfant3 = allocataire.enfants_pas_en_charge.first
    allocataire.date_fin_enfant1 = allocataire.enfants_majoration.first.try(:date_fin_mineur)
    allocataire.date_fin_enfant2 = allocataire.enfants_majoration.second.try(:date_fin_mineur)
    allocataire.date_fin_enfant3 = allocataire.enfants_majoration.third.try(:date_fin_mineur)
    allocataire.save
  end

  def load_impayes
    allocataire = Allocataire.find_by(numero_allocataire: numero_allocataire)
    # if allocataire.eteint? and self.pension_heredite?
    #   impayes = allocataire.ordre_paiements.impaye.where.not(echeance_paiement: nil).select { |m| m.before_one_month_after_alloc_death }
    # else
    #   impayes = allocataire.ordre_paiements.impaye
    # end
    impayes = allocataire.ordre_paiements.impaye
    puts "IMPAYE", impayes.inspect
    unless impayes.nil?
      impayes.each do |impaye|
        RegularisationImpaye.create(
          ordre_paiement_id: impaye.id,
          regularisation_pension_id: self.id,
          numero_ordre: impaye.numero,
          dossier_type: impaye.dossier_type,
          code_operations: impaye.compta_transactions.map { |op| op.code_operation }.join(","),
          annee: impaye.echeance_paiement.try(:annee),
          numero_allocataire: impaye.numero_allocataire,
          periode: impaye.echeance_paiement.try(:periode),
          numero_periode: impaye.echeance_paiement.try(:numero_periode),
          montant: impaye.montant
        )  
        #impaye.en_regularisation      
      end
      puts "REGIL====", regularisation_impayes.size
      if regularisation_impayes.size <= 0
        puts "INIF"
      end

    end
  end

  def regulariser_impayes
    if validation_inspection? and (reordonnancement_de_pension? or pension_heredite?)
      regularisation_impayes.valide.each do |impaye_valide|
        op = OrdrePaiement.find_by(numero: impaye_valide.numero_ordre)
        op.regulariser(User.current)
      end
    end
  end

  def validate_dates_regularisation
    if annulation_de_suspension_avec_rappel?
      if date_debut_regularisation.nil?
        errors.add(:date_debut_regularisation, "La date debut regularisation est obligatoire")
      end
      if date_debut_regularisation < Date.new(1958, 1, 1)
        errors.add(:date_debut_regularisation, "La date debut regularisation doit etre superieure ou égale à 01/01/1958")
      end
      max_date_fin = EcheancePaiement.order('annee DESC, numero_periode DESC').first.try(:periode_fin) || Date.today
      if date_fin_regularisation > max_date_fin
        errors.add(:date_fin_regularisation, "La date fin regularisation doit etre inferieure ou égale à #{max_date_fin.strftime("%d/%m/%Y")}")
      end
      if date_fin_regularisation.nil? and date_debut_regularisation <= Date.today
        errors.add(:date_fin_regularisation, "La date fin regularisation est obligatoire")
      end
      if date_fin_regularisation <= date_debut_regularisation
         errors.add("Erreur!", "date fin doit etre superieures à la date début")
      end
      if calcul_duree_suspension < 1
         errors.add("Erreur!", "Nombre de mois à régulariser doit etre supérieur à 1")
      end
    end
  end

  def generate_compta_transaction
    if validation_inspection? and not ComptaTransaction.exists?(dossier: self)
      op = OrdrePaiement.create(dossier: self, numero_allocataire: numero_allocataire)

      ComptaTransaction.create(
          dossier: self,
          code_operation: 'I_BRAA',
          code_classe_evenement: 'LIQUIDATION',
          code_agence_liquidation: 'I_SG',
          numero_allocataire: numero_allocataire,
          nom: allocataire.nom,
          prenom: allocataire.prenom,
          adresse: allocataire.adresse_rue,
          mode_paiement: allocataire.mode_paiement,
          code_banque_allocataire: allocataire.compte_bancaire_code_banque,
          numero_compte_allocataire: allocataire.rib,
          bank_id: allocataire.bank_id,
          bank_branch_id: allocataire.bank_branch_id,
          date_debut_periode: nil,
          date_fin_periode: nil,
          montant: montant_total_regularise,
          code_devise: 'XOF',
          statut: :en_cours,
          ordre_paiement: op,
          description: "Régularisation pension allocataire : #{numero_allocataire}",
      )
    end
  end


  def valeur_point_cadre(date)
    vp = Admin::BaremePension.valeur_mensuelle_cadre_du(date)
    if vp.nil?
      0
    else
      vp.ceil(2)
    end
  end

  def valeur_point_general(date)
    vp = Admin::BaremePension.valeur_mensuelle_general_du(date)
    if vp.nil?
      0
    else
      vp.ceil(2)
    end
  end
end
