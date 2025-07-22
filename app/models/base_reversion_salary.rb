class BaseReversionSalary < ApplicationRecord
  include MyTools
  include WorkflowActiverecord
  include Documentable
  include ActsAsWorkflowHistory


    TYPE_DOCUMENT_OBLIGATOIRE = {
      carte_identite_defunt: 91,
      certificat_deces: 11,
      certificat_emploi_salaire: 13,
      contrat_travail: 48,
      formulaire_demande: 90,
      justificatif_reversion: 92,
    }.freeze
  
    TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
        {
         
          extrait_naissance: 2,
          passeport: 8,
          carte_consulaire: 9,
          contre_expertise: 96,
          
        }
    ).freeze

    SEXE = {
      homme: 1,
      femme: 2
    }.freeze
    enum sexe: SEXE

    MOTIF_NOT_COMPLETED = {
      en_attente_numerisation: 1,
      ouvert_en_cip: 2,
      en_attente_documents_obligatoires: 3,
      declarations_manquantes: 4,
    }.freeze
    enum motif_not_completed: MOTIF_NOT_COMPLETED
  

    InvalidTransitionError = Class.new(StandardError)
    workflow_column :workflow_state

    workflow do
      state :creation, :meta => {label: 'Création'} do
        event :est_soumis, transition_to: :soumis
      end
  
      state :soumis, :meta => {label: 'Soumis'} do
        event :est_instruit, transition_to: :instruit
        event :retour_creation, transition_to: :creation
      end
      state :instruit, :meta => {label: 'Instruit'} do
        event :est_carriere_soumis, transition_to: :carriere_soumis
        event :retour_soumis, transition_to: :soumis
      end
  
      state :carriere_soumis, :meta => {label: 'Carrières soumises'} do
        event :est_carriere_valide, transition_to: :cotisation_valide
        event :retour_instruit, transition_to: :instruit
      end
  
      state :cotisation_valide, :meta => {label: 'Cotisation valide'} do
        event :est_recap_soumis, transition_to: :recap_soumis
        event :retour_carriere, transition_to: :carriere_soumis
      end
  
      state :recap_soumis, :meta => {label: 'Recap soumis'} do
        event :est_recap_valide, transition_to: :liquidation_valide
        event :retour_cotisation, transition_to: :cotisation_valide
      end
  
      state :liquidation_valide, :meta => {label: 'Liquidation valide'} do
        event :est_dossier_valide, transition_to: :dossier_valide
        event :est_dossier_rejete, transition_to: :dossier_rejete
        event :retour_recap, transition_to: :recap_soumis
      end
  
      state :dossier_valide, :meta => {label: 'Dossier validé'}
      state :dossier_rejete, :meta => {label: 'Dossier rejeté'}

      on_transition do |from, to, triggering_event, *event_args|
        puts "#{from} -> #{to}"
        WorkflowHistory.create(
          dossier: self,
          from: from,
          to: to,
          user: traite_par
        )
      end

      #  use after transition for historisation
      after_transition do
        puts " => traite par : #{self.traite_par} "
      end
  
      on_error do |error, from, to, event, *args|
        puts "Exception(#error.class) on #{from} -> #{to}"
      end
    end
    scope :traitement_en_cours, -> { where(workflow_state: [:instruit]) }
    scope :en_attente, -> { where(workflow_state: [:soumis]) }
    scope :en_attente_instruction, -> { where(workflow_state: [:soumis]) }
    scope :en_attente_validation_carrieres, -> { where(workflow_state: [:carriere_soumis]) }
    scope :en_attente_salaire, -> { where(workflow_state: [:instruit]).where(affectation_salarie: nil) }
    scope :can_affecte, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide]) }
    scope :demandes_affectees, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide]).where.not(affectation_salarie: nil) }
    scope :visible_for_admins, -> { where(workflow_state: [:creation, :soumis, :instruit, :carriere_soumis, :cotisation_valide, :liquidation_valide, :recap_soumis, :dossier_valide,:remboursement_regularise]) }
    scope :en_attente_allocation, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide]).where(affectation_allocataire: nil) }
    scope :en_attente_cotisation, -> { where(workflow_state: [:instruit]).where(affectation_salarie: nil) }
    scope :non_affecter, -> { where(affectation_allocataire: nil) }
    scope :affected_allocataire, -> { where.not(affectation_allocataire: nil) }
    scope :affected_salarie, -> { where.not(affectation_salarie: nil) }
    scope :en_agence, ->(id) { where("ajoute_par_id = ?", id) }
    scope :mes_affectations_allocataire, ->(id) { where("affectation_allocataire = ?", id) }
    scope :mes_affectations_salarie, ->(id) { where("affectation_salarie = ?", id) }
    scope :valider_carriere, -> { where(carriere_valide: :false) }
    
    belongs_to :allocataire, optional: true
    belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affectation_allocataire, optional: true
    belongs_to :affecter_salarie, class_name: 'User', foreign_key: :affectation_salarie, optional: true
    has_many :documents, as: :documentable, dependent: :destroy
    has_many :demandeur_reversions
    has_many :dossier_reversion_salaries, dependent: :destroy
    has_many :enfants, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :carrieres_prestation, class_name: 'Carriere', foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :carrieres, class_name: 'Psrm::Carriere', foreign_key: :matric, primary_key: :numero_affiliation
  belongs_to :admin_agence, :class_name => 'Admin::Agence', foreign_key: :admin_agence_id, optional: true
  belongs_to :agence_creation, :class_name => 'Admin::Agence', foreign_key: :agence_creation_id, optional: true

  belongs_to :soumission_carriere_par, class_name: 'User', foreign_key: :soumission_carriere_par, optional: true
  belongs_to :validation_carriere_par, class_name: 'User', foreign_key: :validation_carriere_par, optional: true
  belongs_to :soumission_validation_par, class_name: 'User', foreign_key: :soumission_validation_par, optional: true
  belongs_to :validation_liquidation_par, class_name: 'User', foreign_key: :validation_liquidation_par, optional: true
  belongs_to :affecte_a, class_name: 'User', foreign_key: :affecte_a_id, optional: true

  scope :non_retourner, -> { where(motif: nil) }
  scope :dossiers_incomplets, -> { where(not_completed: true) }

  belongs_to :participant, :class_name => 'Psrm::Participant',
             foreign_key: :numero_affiliation,
             primary_key: :matric,
             optional: true

  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
    belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajouter_par_id
    belongs_to :instruit_par, class_name: 'User', foreign_key: :instruit_par_id, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affectation_allocataire, optional: true
  belongs_to :update_fullname_par, class_name: 'User', foreign_key: :update_fullname_id, optional: true

  delegate :filename, to: :attachment, allow_nil: true
  validate :validate_numero_affiliation, on: :create
  validate :validate_date, on: :create
  before_create :set_numero_dossier!
  after_create :create_carriere!
  validate :documents_deposes_obligatoires_valide, on: :create

  def set_as_agent_chosen(id)
    self.affecte_a_id = id
    self.save
  end

  def is_not_agent_chosen_anymore(id)
    self.affecte_a_id = nil
    self.save
  end

  def is_set_manager(id)
    User.find(id) == self.affecte_a
  end

  def date_validation
    valider_le || workflow_histories.where(to: 'dossier_valide').maximum(:created_at) || Date.today
  end

  def traite?
    dossier_valide? or dossier_rejete?
  end

  def etat_civil_demandeur_valide!(est_valide = true)
      update(etat_civil_demandeur_valide: est_valide)
    end

    def documents_valide!(est_valide = true)
      if est_valide
        return false if documents.where(type_document: [:cni, :certificat_deces, :certificat_emploi_salaire,:contrat_travail]).empty?
        update(documents_valide: est_valide)
      else
        update(documents_valide: est_valide)
      end
      true
    end
  
    def epouses_valide!(est_valide = true)
      update(epouses_valide: est_valide)
    end
  
    def enfants_valide!(est_valide = true)
      update(enfants_valide: est_valide)
    end
  
    def carriere_valide!(est_valide = true)
      update(carriere_valide: est_valide)
    end
  
    def recap_point_valide!(est_valide = true)
      update(recap_point_valide: est_valide)
    end

    def dossier_demandeur_valide!(est_valide = true)
      if  dossier_reversion_salaries.soumis.count > 0
          update(dossier_demandeur_valide: est_valide)
      end
    end

    def pret_pour_soumission?
      etat_civil_demandeur_valide and epouses_valide and enfants_valide and documents_valide and dossier_demandeur_valide
    end
  
    def traitement_en_cours?
      self.current_state.between? :instruit, :carriere_soumis
    end
  
    def can_affecte_gestionnaire?
      self.current_state.between? :instruit, :cotisation_valide
    end
  
    def pret_pour_validation?
      carriere_valide and recap_point_valide
    end
  
    def affecter_allocatation?
      !affecter_allocataire.nil?
    end
  
    def affecter_cotisation?
      !affecter_salarie.nil?
    end

    def enfants_demandeur
        enfantDemandeurs =Enfant.where(id: enfants_id)
    end

    def conjoints_demandeur
        conjointDemandeurs =Conjoint.where(id: conjoints_id)
        return conjointDemandeurs
    end

    def taux_majoration
      nombre_enfants_mineurs = enfants.valide.mineurs.
          where("date_naissance <= ?", instruit_le || DateTime.now).count
      taux = [15, 5 * nombre_enfants_mineurs].min
      (1.0 * taux)
    end
  
    def taux_minoration_rc
      return 0 
    end
  
    def taux_minoration_rg
      return 0 
    end
  
  

    def calcul_points_regime_general
      carrieres_prestation.valide.regime_general.sum(:points)
    end
  
    def calcul_points_regime_cadre
      carrieres_prestation.valide.regime_cadre.sum(:points)
    end
  
    def calcul_points
      carrieres_prestation.valide.sum(:points)
    end

    def calcul_points_gratuits_regime_general
      carrieres_prestation.valide.regime_general.sum(&:points_gratuits)
    end
  
    def calcul_points_gratuits_regime_cadre
      carrieres_prestation.valide.regime_cadre.sum(&:points_gratuits)
    end
  
    def calcul_points_gratuits
      carrieres_prestation.valide.sum(&:points_gratuits)
    end
  
    def calcul_points_minoration_regime_general
     # return 0 if retraite_normale? or retraite_anticipee_invalide?
      carrieres_prestation.valide.regime_general.map do |carriere|
        (1.0 * (carriere.points + carriere.points_gratuits) * taux_minoration_rg / 100)
      end.sum.round
    end
  
    def calcul_points_minoration_regime_cadre
      #return 0 if retraite_normale? or retraite_anticipee_invalide?
      carrieres_prestation.valide.regime_cadre.map do |carriere|
        (1.0 * (carriere.points + carriere.points_gratuits) * taux_minoration_rc / 100)
      end.sum.round
    end
  
    def calcul_points_minoration
      calcul_points_minoration_regime_general + calcul_points_minoration_regime_cadre
    end
  
    def calcul_points_majoration_regime_general
        (1.0 * calcul_points_base_regime_general * taux_majoration / 100).round
    end
  
    def calcul_points_majoration_regime_cadre
      (1.0 * calcul_points_base_regime_cadre * taux_majoration / 100).round
    end
  
    def calcul_points_majoration
      calcul_points_majoration_regime_general + calcul_points_majoration_regime_cadre
    end
  
    def calcul_points_base_regime_general
      calcul_points_regime_general + calcul_points_gratuits_regime_general - calcul_points_minoration_regime_general
    end
  
    def calcul_points_base_regime_cadre
      calcul_points_regime_cadre + calcul_points_gratuits_regime_cadre - calcul_points_minoration_regime_cadre
    end
  
    def calcul_points_base
      calcul_points_base_regime_general + calcul_points_base_regime_cadre
    end
  
    def calcul_points_servis_regime_general
      calcul_points_base_regime_general + calcul_points_majoration_regime_general
    end
  
    def calcul_points_servis_regime_cadre
      calcul_points_base_regime_cadre + calcul_points_majoration_regime_cadre
    end
  
    def calcul_points_servis
      calcul_points_base + calcul_points_majoration
    end

    def nombre_veuves_can_be_eligibles
      date_fin = date_deces
      conjoints.map do |conjoint|
        date_debut = conjoint.date_mariage
        age = date_fin.year - date_debut.year
        age -= 1 if date_fin < date_debut + age.years
        (age >= 2) ? 1 : 0
      end.sum
    end
  
    def nombre_veuves_eligibles_grappe
      dossier_reversion_salaries = DossierReversionSalary.where(numero_affiliation: numero_affiliation)
      dossier_reversion_salaries.veuve.eligibles.count
    end
  
    def nombre_orphelins_eligibles_grappe
      dossier_reversion_salaries = DossierReversionSalary.where(numero_affiliation: numero_affiliation)
      dossier_reversion_salaries.orphelin.eligibles.count
    end

    def nombre_veuves_eligibles
      return nombre_epouses_eligible unless nombre_epouses_eligible.nil?
      conjoints_demandeur.count
    end

    def nombre_orphelins_eligibles
      return nombre_enfant_eligible unless nombre_enfant_eligible.nil?
      enfants_demandeur.count
    end

    def part_veuves
      nombre_veuves_eligibles.zero? ? 0 : 50.0
    end
  
    def part_orphelins
     1.0 * [100 - part_veuves, nombre_orphelins_eligibles * 20].min
    end
  
    def total_parts
      # dossier_reversion_salaries = DossierReversionSalary.where(numero_affiliation: numero_affiliation)
      dossier_reversion_salaries.map(&:part).sum.ceil(1)
    end
  
    def nombre_veuve_eligible_atteint?
      # dossier_reversion_salaries = DossierReversionSalary.where(numero_affiliation: numero_affiliation)
      
      nb_max = 4
      dossier_reversion_salaries.veuve.eligibles.count >= nb_max
    end

    def conjoint_checked(id)
      unless conjoints_id.nil?
        id.to_s.in?(conjoints_id)? true : false  
      else
        false
      end
    end

    def enfant_checked(id)
      #id.to_s.in?(enfants_id) unless enfants_id.nil?
      unless enfants_id.nil?
        id= id.to_s
        id.in?(enfants_id)? true : false  
      else
        return false
      end
    end

    def retourner_all_carrieres(carrieres)
      unless carrieres.nil?
        carrieres.each do |carriere|
          carriere.etat=:en_attente
          carriere.save
        end
      end
    end

   def can_integrate_carrieres?(current_user)
    current_user.gestionnaire_compte_salarie? && instruit? && affecter_salarie == current_user
   end

   def can_make_not_incomplet?(current_user)
    (current_user.gestionnaire_compte_allocataire? && creation? && ajoute_par == current_user) or
    (current_user.gestionnaire_compte_salarie? && instruit? && affecter_salarie == current_user)
  end

 

    private

    def set_numero_dossier!
      annee = Date.today.year
      self.numero_dossier = "RVS/#{numero_affiliation}/#{annee}"
    end
    def date_cessation_activite_validation
      return if date_cessation_activite.nil?
  
      if date_cessation_activite > Date.today
        errors.add(:date_cessation_activite, "ne peut pas être supérieure à la date d'aujourd'hui")
      end
    end

    def validate_numero_affiliation
      
      return if numero_affiliation.nil? or numero_affiliation.empty?
      errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Psrm::Participant.where(matric: numero_affiliation).exists?
     # errors.add(:numero_affiliation, "L'allocataire existe déjà") if Allocataire.where(numero_allocataire: numero_affiliation).exists?
  
      if BaseReversionSalary.where(numero_affiliation: numero_affiliation).
          where.not(workflow_state: :dossier_rejete).exists?
        errors.add(:numero_affiliation, "Un dossier avec ce numéro d'affiliation existe déjà")
      end

      if LiquidationRetraite.where(numero_affiliation: numero_affiliation).
        where.not(workflow_state: :dossier_rejete).exists?
        errors.add(:numero_affiliation, "Un dossier de liquidation avec ce numéro d'affiliation existe déjà")
      end

      if conjoints_id.nil? and enfants_id.nil?
        errors.add("Veuillez sélectionner au moins", "un ayant droit")
      else
        if conjoints_id.nil? and enfants_id.nil?
          errors.add("Veuillez sélectionner au moins", "un ayant droit")
        end
      end
    end

    def create_carriere!
      # carrieres_prestation.destroy_all
      carrieres.each do |psrm_carriere|
        psrm_carriere.load_to_prestation
      end
    end

 
    def set_user!
      self.user = User.find_by(numero_salarie: numero_affiliation)
    end

    def validate_date
      if date_cessation_activite > Date.today
        errors.add(:date_cessation_activite, "ne peut pas être postérieure à la date d'aujourd'hui")
      end
      if date_deces < date_cessation_activite
        errors.add(:date_cessation_activite, "Ne peut pas être postérieure à la date du décés")
      end
      if date_naissance >= date_deces
        errors.add(:date_naissance, "Ne peut pas être postérieure à la date du décés")
      end
    end

    def documents_deposes_obligatoires_valide
      if documents_deposes_obligatoires.nil?
        errors.add("Erreur!!!", "Veuillez cocher les documents obligatoires")
      end
    end
end
