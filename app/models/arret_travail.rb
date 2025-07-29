class ArretTravail < ApplicationRecord
  CONFIG = YAML.safe_load(File.read('app/data/arret_travail.config.yml'))

  include Documentable
  include WorkflowActiverecord

  TYPE_DOCUMENT_OBLIGATOIRE = {
    bulletin_de_salaire: 53,
    certificat_medical_genre_de_mort: 71,
    cni_extrait: 72,
    formulaire_declaration_at: 73,
  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      last_bul_salaire: 31,
      bulletin_de_salaire_journalier: 46,
      relation_ecrite_temoin: 51,
      ordre_de_mission: 54,
      contrat_travail: 48,
      pv_police_gendarmerie: 56,
      rapport_sortie_sapeurs_pompiers: 57,
      pv_huissiers: 58,
      certificat_guerison: 60,
      relation_ecrite_premiere_avisee: 74,
      questionnaire_trajet: 75,
      certificat_travail_prolongation: 94,
    }
  ).freeze

  InvalidTransitionError = Class.new(StandardError)

  workflow_column :workflow_state

  workflow do
    state :creation do
      event :est_en_instruction, transition_to: :en_instruction
      event :est_soumis_chefService, transition_to: :soumis_chefService
    end

    state :en_instruction do
      event :est_soumis_chefService, transition_to: :soumis_chefService
      event :retour_creation, transition_to: :creation
    end

    state :soumis_chefService do
      event :est_affecte_redacteur, transition_to: :affecte_redacteur
      event :retour_creation, transition_to: :creation
      event :retour_en_instruction, transition_to: :en_instruction
    end

    state :affecte_redacteur do
      event :est_avis_redacteur, transition_to: :avis_redacteur
      event :retour_soumis_chefService, transition_to: :soumis_chefService
      event :retour_creation, transition_to: :creation
      event :retour_en_instruction, transition_to: :en_instruction
    end

    state :avis_redacteur do
      event :est_avis_dajc, transition_to: :avis_dajc
      event :retour_soumis_chefService, transition_to: :soumis_chefService
    end

    state :avis_dajc do
      event :est_avis_chefService, transition_to: :avis_chefService
      event :retour_avis_redacteur, transition_to: :avis_redacteur
    end

    state :avis_chefService do
      event :est_soumis_directeur, transition_to: :soumis_directeur
      event :retour_creation, transition_to: :creation
      event :retour_en_instruction, transition_to: :en_instruction
    end

    state :soumis_directeur do
      event :est_accepte, transition_to: :accepte
      event :est_soumis_comite, transition_to: :soumis_comite
      event :retour_avis_chefService, transition_to: :avis_chefService
    end

    state :soumis_comite do
      event :est_avis_comite, transition_to: :avis_comite
      event :retour_soumis_directeur, transition_to: :soumis_directeur
    end
    state :avis_comite do
      event :est_accepte, transition_to: :accepte
      event :est_dossier_rejete, transition_to: :dossier_rejete
    end

    state :accepte do
      event :est_liquidation_soumis, transition_to: :liquidation_soumis
      event :est_guerison_soumis, transition_to: :guerison_soumis
      event :retour_soumis_directeur, transition_to: :soumis_directeur
      event :est_gueris, transition_to: :gueris
    end

    state :liquidation_soumis do
      event :est_validation_medecin, transition_to: :validation_medecin
      event :est_liquidation_valide, transition_to: :liquidation_valide
      event :retour_accepte, transition_to: :accepte
    end

    state :validation_medecin do
      event :est_liquidation_valide, transition_to: :liquidation_valide
      event :retour_liquidation_soumis, transition_to: :liquidation_soumis
    end

    state :liquidation_valide do
      event :est_validation_comptable, transition_to: :validation_comptable
      event :retour_validation_medecin, transition_to: :validation_medecin
      event :retour_liquidation_soumis, transition_to: :liquidation_soumis
    end

    state :validation_comptable do
      event :retour_liquidation_valide, transition_to: :liquidation_valide
    end

    state :guerison_soumis do
      event :est_guerison_valide, transition_to: :guerison_valide
    end

    state :gueris do
      event :est_rechute, transition_to: :rechute
      event :est_annulation_guerison_soumise, transition_to: :annulation_guerison_soumise
    end

    state :annulation_guerison_soumise do
      event :est_accepte, transition_to: :accepte
    end

    state :rechute do
      event :est_gueris, transition_to: :gueris
    end

    state :dossier_rejete

    on_transition do |from, to, triggering_event, *event_args|
      puts "#{from} -> #{to}"
    end

    #  use after transition for historisation
    after_transition do
      #puts "=> traite par : #{self.traite_par}"
    end

    on_error do |error, from, to, event, *args|
      puts "Exception(#error.class) on #{from} -> #{to}"
    end
  end

  MAX_NOMBRE_JOUR = 28

  MONTH_IN_FR = {
    january: 'janvier',
    february: 'fevrier',
    march: 'mars',
    april: 'avril',
    may: 'mai',
    june: 'juin',
    july: 'juillet',
    august: 'aout',
    september: 'septembre',
    october: 'octobre',
    november: 'novembre',
    december: 'decembre'
  }.freeze

  REQUIRED_AVIS = ['redacteur', 'chef_division_at', 'dajc']
  OPTIONAL_AVIS = ['dprp']
  OPTIONAL_AVIS_1 = ['medecin_conseil']

  PLAFOND = {
    inf: 1070.48,
    sup: 7560
  }.freeze

  ETAT = {
    instruction: 1,
    accepte: 2,
    rejete: 3,
    gueris: 4,
    rechute: 5,
    decede: 6,

  }.freeze

  CONSEQUENCE_ACCIDENT_TRAVAIL = {
    arret_travail: 1,
    deces: 2,
    sans_arret_travail: 3
  }
  INCAPACITE_PERMANENTE = {
    partielle: 1,
    totale: 2
  }

  SEXE = {
    homme: 1,
    femme: 2
  }.freeze

  TYPE_DE_PIECE = {
    cni: 1,
    carte_cedeao: 2,
    carte_consulaire: 3,
    passeport: 4,
    extrait_de_naissance: 5
  }.freeze

  QUALIFICATION_PROFESSIONNELLE = {
    cadre: 1,
    technicien: 2,
    agent_de_maitrise: 3,
    employes: 4,
    apprentis: 5,
    manoeuvres: 6,
    ouvriers_specialises: 7,
    ouvrier_qualifie: 8,
    divers: 9
  }

  LIEU_ACCIDENT = {
    lieu_travail: 1,
    deplacement_pendant_hr_travail: 2,
    entre_domicile_et_bureau: 3,
    deplacement_pendant_hr_pause: 4,
    en_mer: 5,
    voyage_et_mission: 6,
    non_precise: 7
  }

  AGENT_MATERIEL = {
    accident_de_plein_pied: 1,
    chute_dun_niveau: 2,
    objets_en_cours_de_manutention_manuelle: 3,
    objets_ou_masse_en_mouvement: 4,
    particules_ou_petits_elements_de_matieres: 5,
    appareils_de_levage_amarrage_prehension: 6,
    vehicule: 7,
    machine_productrice_transformation_energie: 8,
    organe_transmission: 9,
    machine_transmission: 10,
    machine_a_broyer_concasser_pulveriser_diviser: 11,
    machine_a_malaxer_melanger: 12,
    machine_a_cribler_tamiser_separer: 13,
    presses_mecaniques_pilons: 14,
    machine_a_presser_mouler_injecter: 15,
    machine_cylind_laminer_etirer_planer_imprimer_melanger: 16,
    machine_a_couper_trancher_derouler_defibrer: 17,
    scies: 18,
    machine_a_tourner_percer_aleser_fraiser_raboter: 19,
    machine_a_percer_tourner_tourpiller_raboter: 20,
    machine_a_meuler_poncer_polir: 21,
    materiel_et_machines_a_souder: 22,
    machine_a_riveter_coudre_agrafer_mettre_oeillets: 23,
    mach_a_remplir_condition_empaquer_emballer_clouer: 24,
    machine_a_effilocher_ouvrer_battre_carder: 25,
    mach_a_filature_de_tissage_de_cablerie_et_d_appret: 26,
    materiel_engins_de_terrassement_et_travaux_annexes: 27,
    machine_diverses: 28,
    outils_mecaniques_tenus_ou_guides_a_la_main: 29,
    outils_a_main: 30,
    appareil_a_pression: 31,
    appareil_usten_util_prod_caustique_corro_toxi: 32,
    appareillage_et_installation_frigorifique: 33,
    vapeur_gaz_et_poussiere_deletere: 34,
    matiere_explosive: 35,
    electricite: 36,
    mat_divers: 37,
  }

  DECLARANT = {
    ayant_droit: 1,
    employeur: 2,
    salarie: 3
  }

  TYPE_DECLARATION = {
    accident_travail: 1,
    accident_trajet: 2
  }

  SITUATION_MATRIMONIALE = {
    marie: 1,
    divorce: 2,
    celibataire: 3,
    veuf: 4
  }

  NATIONALITE_SALARIE = {
    senegalais: 1,
    etranger: 2
  }

  TYPE_DE_CONTRAT_TRAVAIL = {
    permanent: 1,
    journalier: 2,
    saisonier: 3,
    autres_cdd: 4
  }

  NATURE_ACCIDENT = {
    nouveau_accident: 1,
  }

  enum etat: ETAT
  enum situation_matrimoniale_salarie: SITUATION_MATRIMONIALE
  enum nationalite_salarie: NATIONALITE_SALARIE
  enum type_de_contrat_travail_salarie: TYPE_DE_CONTRAT_TRAVAIL
  enum qualification_professionnelle_salarie: QUALIFICATION_PROFESSIONNELLE
  enum agent_materiel: AGENT_MATERIEL
  enum nature_accident: NATURE_ACCIDENT
  enum sexe: SEXE
  enum type_de_piece: TYPE_DE_PIECE
  enum type_declaration: TYPE_DECLARATION
  enum consequence_accident_travail: CONSEQUENCE_ACCIDENT_TRAVAIL
  enum incapacite_permanente: INCAPACITE_PERMANENTE
  enum declarant: DECLARANT
  attr_accessor :total_indemnite
  has_many :at_lesions
  has_many :at_carnets
  has_many :at_salaires
  has_many :at_documents, dependent: :destroy
  has_many :at_incapacites
  has_many :at_frais_engages
  has_many :at_code_prime_salaires
  accepts_nested_attributes_for :at_code_prime_salaires, :allow_destroy => true
  has_many :at_decomptes
  has_many :at_avis
  has_many :at_events
  has_many :enfants, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :carrieres_prestation, class_name: 'Carriere', foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :carrieres, class_name: 'Psrm::Carriere', foreign_key: :matric, primary_key: :numero_affiliation
  has_one :at_consolidation
  has_one :at_rente_famille
  has_one :at_rechute
  has_one :at_guerison
  has_many :ordre_paiements, as: :dossier, dependent: :destroy
  has_many :compta_transactions, through: :ordre_paiements
  belongs_to :user
  belongs_to :admin_agence, optional: true, :class_name => 'Admin::Agence', foreign_key: :admin_agence_id
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  belongs_to :instruit_par, class_name: 'User', foreign_key: :instruit_par_id, optional: true
  belongs_to :soumis_chef_div_at_par, class_name: 'User', foreign_key: :soumis_chef_div_at_par, optional: true
  belongs_to :affecter_tech, class_name: 'User', foreign_key: :affectation_at, optional: true
  belongs_to :affecter_redacteur, class_name: 'User', foreign_key: :affecte_a, optional: true
  belongs_to :cloture_soumise_par, class_name: 'User', foreign_key: :cloture_soumise_par, optional: true
  belongs_to :reouverture_soumise_par, class_name: 'User', foreign_key: :reouverture_soumise_par, optional: true
  has_one_attached :certificat_guerison
  has_one_attached :certificat_medical

  validates :certificat_guerison, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } if defined?(certificat_guerison)
  validates :certificat_medical, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } if defined?(certificat_medical)
  validate :validate_numero_affiliation, on: :create
  validate :validate_start_at_date
  accepts_nested_attributes_for :at_lesions

  scope :not_affected, -> { en_instruction.where(affecte_a: nil).or(en_attente_information.where(affecte_a: nil)).or(accepte.where(affecte_a: nil)) }
  scope :affected_tech, -> { where.not(affectation_at: nil) }
  scope :affected_redacteur, -> { where.not(affecte_a: nil) }
  scope :not_deleted, -> { where(deleted: [false, nil]) }
  scope :en_creation, -> { where(workflow_state: [:creation]).where.not(motif: nil) }
  scope :en_attente_soumis_chef_agence, -> { where(workflow_state: [:en_instruction]) }
  scope :en_attente_instruction, -> { where(workflow_state: [:soumis_chef_agence]) }
  scope :en_attente_information, -> { where(workflow_state: [:en_instruction]) }
  scope :en_attente_affectation_redacteur, -> { where(workflow_state: [:soumis_chefService]) }
  scope :en_attente_avis_redacteur, -> { where(workflow_state: [:affecte_redacteur]) }
  scope :en_attente_avis_dajc, -> { where(workflow_state: [:avis_redacteur]) }
  scope :en_attente_avis_chef_service_at, -> { where(workflow_state: [:avis_dajc]) }
  scope :en_attente_soumission_dir_at, -> { where(workflow_state: [:avis_chefService]) }
  scope :en_attente_acceptation, -> { where(workflow_state: [:soumis_directeur]) }
  scope :en_attente_affectation_technicien_agence, -> { where(workflow_state: [:accepte]).where(creer_par_ag_direction_at: false) }
  scope :en_attente_affectation_technicien_direction, -> { where(workflow_state: [:accepte]).where(creer_par_ag_direction_at: true) }
  scope :en_attente_validation_ij, -> { ArretTravail.joins(:at_decomptes).where(at_decomptes: { etat: :liquide }).distinct }
  scope :en_attente_validation_frais, -> { ArretTravail.joins(:at_frais_engages).where(at_frais_engages: { etat: :liquide }).distinct }
  scope :en_attente_validation_mc_ij, -> { ArretTravail.joins(:at_decomptes).where(at_decomptes: { etat: :soumission_medecin }).where(at_decomptes: { validation_medecin_obligatoire: true }).distinct }
  scope :en_attente_validation_mc_frais, -> { ArretTravail.joins(:at_frais_engages).where(at_frais_engages: { etat: :valide }).distinct }
  scope :en_attente_validation_comptable_scope, -> { ArretTravail.joins(:at_decomptes).where(at_decomptes: { etat: :valide }).distinct }
  scope :en_attente_validation_comptable_ij, -> { ArretTravail.joins(:at_decomptes).where(at_decomptes: { etat: :valide }).where(at_decomptes: { validation_medecin_obligatoire: false }).distinct }
  scope :en_attente_validation_comptable_frais, -> { ArretTravail.joins(:at_frais_engages).where(at_frais_engages: { etat: :validation_medecin }).distinct }

  # En attente validation liquidation par le technicien en agence
  scope :en_attente_validation_liquidation_agence, -> { ArretTravail.joins(:at_frais_engages).where(at_frais_engages: { etat: :validation_medecin }).where(creer_par_ag_direction_at: false).distinct }

  #  En attente validation liquidation par le technicien à la direction
  scope :en_attente_validation_liquidation, -> { ArretTravail.joins(:at_frais_engages, :at_decomptes).where(at_frais_engages: { etat: :validation_medecin }).where(at_decomptes: { etat: :liquidation }).where(creer_par_ag_direction_at: false).distinct }

  # En attente validation frais et ij par le medecin conseil
  scope :en_attente_validation_medecin_scope, -> { ArretTravail.joins(:at_decomptes, :at_frais_engages).where(at_frais_engages: { etat: :liquidation }).where(at_decomptes: { etat: :liquidation }).where(creer_par_ag_direction_at: true).distinct }

  # En attente validation  ij par chef service AT
  scope :en_attente_validation_liquidation_ij, -> { ArretTravail.joins(:at_decomptes).where(at_decomptes: { etat: :liquidation }).distinct }

  # En attente validation frais et ij par chef service AT
  scope :en_attente_validation_liquidation_scope, -> { ArretTravail.joins(:at_frais_engages, :at_decomptes).where(at_frais_engages: { etat: :validation_medecin }).where(at_decomptes: { etat: :validation_medecin }).distinct }

  # En attente validation frais et ij par le comptable

  scope :soumis_commission_rejet, -> { where(workflow_state: [:soumis_comite]) }
  scope :retour_commission_saisi, -> { where(workflow_state: [:avis_comite]) }
  scope :en_attente_liquidation_scope, -> { ArretTravail.joins(:at_frais_engages).where(at_frais_engages: { etat: :validation_medecin }).distinct }
  scope :en_attente_validation_reouverture_dossier, -> { where(workflow_state: [:demande_reouverture_confirmee]) }
  scope :soumission_rechutes, -> { where(workflow_state: [:rechute_soumise]) }
  scope :en_attente_validation_rechutes_mc, -> { where(workflow_state: [:soumission_rechute_mc]) }
  scope :en_attente_validation_rechutes, -> { where(workflow_state: [:validation_rechute_mc]) }
  scope :en_attente_reouverture_dossier, -> { where(workflow_state: [:rechute_validee]) }
  scope :en_attente_validation_cloture_dossier, -> { where(workflow_state: [:guerison_soumis]) }
  scope :en_attente_validation_cloture_dossier_tech, -> { where(workflow_state: [:guerison_valide]) }
  scope :en_attente_cloture_dossier, -> { where(workflow_state: [:validation_comptable]) }
  scope :dossiers_clotures, -> { where(workflow_state: [:guerison_valide]) }
  scope :dossiers_reouverts, -> { where(workflow_state: [:dossier_reouvert]) }
  scope :dossiers_rct, -> { where(accident_cause_par_tiers: true) }
  scope :en_attente_avis_dprp, -> { where(active_enquete_dprp: true) }
  scope :en_attente_avis_medecin, -> { where(active_avis_medecin: true) }
  scope :avis_redacteur, -> { select { |p| p.avis_redacteur_done == true } }
  scope :dossiers_rejetes, -> { where(workflow_state: [:dossier_rejete]) }
  scope :en_attente_annulation_guerison, -> { where(workflow_state: [:annulation_guerison_soumise]) }

  # arret_travail.rb pour gerer les deux enregistrement AT/MP
  scope :maladies_professionnelles, -> { where(est_maladie_professionnelle: true) }
  scope :accidents_de_travail, -> { where(est_maladie_professionnelle: false) }

  scope :en_attente_affectation_rechute_agence, -> { where(workflow_state: [:rechute]) }
  scope :en_attente_affectation_rechute_dir, -> { where(workflow_state: [:rechute]).where(creer_par_ag_direction_at: true) }
  scope :en_attente_liquidation_dossoer_rechute, -> { where(workflow_state: [:rechute]).where.not(affectation_at: nil) }

  validates :numero_affiliation, presence: true, if: :salaire_exist?
  validates :prenom_salarie, :nom_salarie, :date_de_naissance_salarie, :sexe, :type_de_piece, :nin_salarie, :adresse, :nationalite_salarie, :date_accident, presence: true
  validates :nin_salarie, length: { in: 13..14 }, if: :is_nin_cni?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email?
  validates :telephone, :presence => true,
            :numericality => true,
            :length => { :minimum => 10, :maximum => 15 }, if: :telephone_changed?
  before_create :set_declarant!, :set_document_number!
  #before_create :set_nomero_temporaire!, unless: :has_numero_affiliation?
  #before_create :set_num_dossier!, if: :has_numero_affiliation?
  after_create :create_event

  def full_name
    "#{prenom_salarie} #{nom_salarie}"
  end

  def create_event
    at_event = AtEvent.new
    description = "Création du dossier AT n° #{self.num_dossier} par #{User.current.email} (#{User.current.type_profil})"
    at_event.arret_travail_id = self.id
    at_event.description = description
    at_event.done_by = User.current.email
    at_event.save!
  end

  def pret_pour_liquidation_frais_engages(current_user)
    (at_frais_engages.size > 0 or at_decomptes.size > 0) &&
      at_frais_engages.size == at_frais_engages.liquide.size &&
      at_decomptes.size == at_decomptes.a_liquider.size &&
      (current_user.technicien_direction_at? or current_user.technicien_at?) &&
      accepte?
  end

  def require_validation_medecin?
    puts "==TEST", nb_arret_need_validation_medecin
    at_frais_engages.size >= 1 or nb_arret_need_validation_medecin >= 1
  end

  def pret_pour_validation_liquidation(current_user)
    at_frais_engages.size == at_frais_engages.a_valider.size &&
      at_decomptes.size == at_decomptes.a_valider.size &&
      (current_user.chef_division_at? or current_user.chef_agence?) &&
      (validation_medecin? or liquidation_soumis?)
  end

  def pret_pour_validation_medecin(current_user)
    at_frais_engages.size == at_frais_engages.a_valide_medecin.size &&
      current_user.medecin_conseil? &&
      liquidation_soumis?
  end

  def pret_pour_validation_comptable(current_user)
    at_frais_engages.size == at_frais_engages.a_valide_comptable.size &&
      at_decomptes.size == at_decomptes.a_valide_comptable.size &&
      current_user.comptable? &&
      liquidation_valide?
  end

  def peut_tout_liquide?(current_user)
    current_state >= :accepte &&
      (current_user.technicien_at? ||
      current_user.technicien_direction_at?) &&
      (at_decomptes.creation.length > 0 or at_decomptes.validation_medecin.length > 0)
  end

  def avec_nbr_heure_paye_jrnalier?(current_user)
    self.est_journalier &&
    !self.est_repris &&
    meme_agence?(current_user) &&
    at_decomptes.where(etat: :validation_comptable).count == 0 &&
    (current_user.technicien_direction_at? ||
    current_user.technicien_at?)
  end

  def peut_modification_exceptionnelle?(current_user)
    self.at_decomptes.where(etat: :validation_comptable).count == 0 &&
    self.at_frais_engages.where(etat: :validation_comptable).count == 0 &&
    meme_agence?(current_user) &&
    (current_user.chef_division_at? ||
    current_user.chef_agence?)
  end

  def salaire_reference
    at_code_salaires = self.at_code_prime_salaires.where(prise_en_compte: true).select(:montant)
    return 0 if at_code_salaires.empty?
    salaire = at_code_salaires.map(&:montant).compact.reduce(:+) || 0
    if est_journalier? 
      salaire = ((salaire / nombre_heure_paye) * 8).round(2) unless nombre_heure_paye.nil?
    end
    return salaire
  end

  def salaire_reference_rechute
    return at_rechute.salaire_reference unless at_rechute.nil?
  end

  def salaire_journalier_reference_rechute
    return at_rechute.salaire_journalier_reference unless at_rechute.nil?
  end

  def salaire_journalier_reference
    return salaire_reference if est_journalier?
    return (salaire_reference / nombre_jours_ouvres).round(2) unless nombre_jours_ouvres.nil?
  end

  def salaire_reference_choisi
    if !at_rechute.nil?
      if salaire_reference >= salaire_reference_rechute
        return salaire_reference
      else
        return salaire_reference_rechute
      end
    end
  end

  def ij_retenu
    if !at_rechute.nil?
      if salaire_journalier_reference >= salaire_journalier_reference_rechute
        return salaire_journalier_reference
      else
        return at_rechute.salaire_journalier_reference
      end
    end
    return salaire_journalier_reference
  end

  def indemnite_journaliere
    ij = 0 if ij_retenu.nil?
    return ij if ij == 0
    ij = ij_retenu
    return PLAFOND[:inf] if ij <= PLAFOND[:inf]
    return PLAFOND[:sup] if ij >= PLAFOND[:sup]
    return ij
  end

  def indemnite_total
    ij = indemnite_journaliere
    periode = self.at_incapacites.where(est_calculer: false).select { |at| !at.validation_medecin_obligatoire? }
    return 0 if periode.empty?
    it = 0
    periode_jr = periode.map(&:nombre_jour).compact.reduce(:+)
    tab_nb_jr = nombre_jour_calcul(periode_jr)
    it = demi_salaire(ij, tab_nb_jr.first) + deux_tier_salaire(ij, tab_nb_jr.last)
    it
  end

  def self.is_required_field?(field_name)
    CONFIG.dig('arret_travail_requirements', 'require_field_status', field_name.to_s) == true
  end

  def self.designations
    CONFIG.dig('arret_travail_requirements', 'designations')
  end

  def nb_arret_need_validation_medecin
    nb_arret = 0
    unless at_decomptes.nil?
      at_decomptes.each do |decompte|
        if decompte.need_validation_medecin
          nb_arret += 1
        end
      end
    end
    return nb_arret
  end

  def pret_pour_soumission?(current_user)
    creation? &&
      info_salarie_valid &&
      info_employeur_valid &&
      detail_accident_valid &&
      document_valid &&
      meme_agence?(current_user) &&
      (current_user.agent_accueil? ||
        current_user.agent_accueil_direction_at? ||
        current_user.technicien_at? ||
        current_user.technicien_direction_at?)
  end

  def complet?
    info_salarie_valid &&
      info_employeur_valid &&
      detail_accident_valid &&
      document_valid &&
      frais_indemnité_valid
  end

  def exist_frais_engages_a_liquider?
    at_frais_engages.liquide.size > 0
  end

  def avis_redacteur_done
    avis_restant == "1/3"
  end

  def documents_valide!(est_valide = true)
    if est_valide
      return false if documents.certificat_medical_genre_de_mort.empty?
      return false if documents.cni_extrait.empty?
      #return false if documents.bulletin_de_salaire.empty?
      update(document_valid: est_valide)
    else
      update(document_valid: est_valide)
    end
    true
  end

  def self.agence_ats(current_user)
    return not_deleted if current_user.admin?
    return not_deleted.where(affecte_a: current_user.id) if current_user.redacteur?
    return not_deleted.soumis_directeur if current_user.directeur_at?

    return not_deleted.accepte if current_user.comptable?

    return not_deleted.soumis_chef_agence.where(creer_par_ag_direction_at: false).or(not_deleted.accepte.where(creer_par_ag_direction_at: false)) if current_user.chef_agence?

    return not_deleted.en_attente_information.or(not_deleted.en_instruction).or(not_deleted.accepte.where(creer_par_ag_direction_at: true)) if current_user.chef_division_at?

    return not_deleted.accepte.where(affecte_a: current_user.id) if current_user.technicien_at? || current_user.technicien_direction_at?

    if current_user.agence
      ids = not_deleted.select { |at| at.creer_par.agence == current_user.agence }.map(&:id)
      return not_deleted.where(id: ids)
    end
    ArretTravail.none
  end

  def last_events
    at_events.order(created_at: :desc).limit(30)
  end

  def avis_completer?
    s, q = avis_fraction_tab
    s == q
  end

  def avis_fraction_tab
    s = 0
    q = 1
    q = REQUIRED_AVIS.size
    s = REQUIRED_AVIS.map { |aa| at_avis.where(est_valide: false, fait_par_profil: aa).first }.compact.size
    if active_enquete_dprp
      q = q + OPTIONAL_AVIS.size
      s = s + OPTIONAL_AVIS.map { |aa| at_avis.where(est_valide: false, fait_par_profil: aa).first }.compact.size
    end
    if active_avis_medecin
      q = q + OPTIONAL_AVIS_1.size
      s = s + OPTIONAL_AVIS_1.map { |aa| at_avis.where(est_valide: false, fait_par_profil: aa).first }.compact.size
    end
    [s, q]
  end

  def total_a_payer
    total_frais_engages + total_idemnites
  end

  def total_paiement_valide
    total_frais_valide + total_idemnites_valide
  end

  def avis_restant
    s, q = avis_fraction_tab
    "#{s}/#{q}"
  end

  def avis_restant_pour_cent
    s, q = avis_fraction_tab
    "#{((s.to_f / q) * 100).round}"
  end

  def at_decomptes_valides
    at_decomptes.where(est_valide: true)
  end

  def creer_a_la_direction?
    creer_par_ag_direction_at
  end

  def creer_en_agence?
    !creer_par_ag_direction_at
  end

  def peut_etre_supprimer?
    creation?
  end

  def peut_emettre_avis?(current_user)
    case current_user.type_profil
    when 'chef_agence'
      chef_agence_peut_emettre_avis?(current_user)
    when 'redacteur'
      redacteur_peut_emettre_avis?(current_user)
    when 'chef_division_at'
      chef_at_peut_emettre_avis?
    when 'dajc'
      dajc_peut_emettre_avis?
    when 'dprp'
      active_enquete_dprp
    when 'medecin_conseil'
      est_decede? or active_avis_medecin
    when 'directeur_at'
      soumis_directeur?
    else
      false
    end
  end

  def peut_ajouter_avis? (current_user)
    at_avis.where(fait_par: current_user.id.to_s).size == 0 &&
      peut_emettre_avis?(current_user) &&
      peut_avoir_avis?(current_user)
  end

  def chef_agence_peut_emettre_avis?(current_user)
    en_instruction? &&
      !avis_completer? &&
      !affecte_a
  end

  def redacteur_peut_emettre_avis?(current_user)
    affecte_a &&
      (affecte_a == current_user.id.to_s) &&
      date_soumission_redacteur.nil? && affecte_redacteur?
  end

  def chef_at_peut_emettre_avis?
    !avis_completer? && at_avis.where(est_valide: false, fait_par_profil: ['redacteur', 'dajc']).size >= 2
  end

  def dajc_peut_emettre_avis?
    !avis_completer? &&
      at_avis.where(est_valide: false, fait_par_profil: ['redacteur']).size >= 1

  end

  def peut_avoir_avis?(current_user)
    (current_user.chef_agence? || current_user.redacteur? || current_user.dprp? || current_user.dajc? || current_user.chef_division_at? || current_user.directeur_at? || current_user.medecin_conseil?)
  end

  def peut_ajouter_avis_dprp?(current_user)
    current_user.directeur_at?
  end

  def peut_supprimer_avis?(current_user)
    case current_user.type_profil
    when 'chef_agence'
      en_instruction?
    when 'redacteur'
      date_soumission_redacteur.nil? and affecte_redacteur?
    when 'chef_division_at'
      chef_at_peut_emettre_avis?
    when 'dajc'
      date_soumission_dajc.nil?
    when 'directeur_at'
      date_acceptation.nil?
    when 'dprp'
      date_soumission_avis_dprp.nil?
    when 'medecin_conseil'
      date_soumission_avis_medecin?
    else
      false
    end
  end

  def read_only?
    !creation?
  end

  def can_update?(current_user)
    creation? && (current_user.agent_accueil? ||
      current_user.agent_accueil_direction_at? ||
      current_user.technicien_at? ||
      current_user.technicien_direction_at?)
  end

  def can_add_ij?(current_user)
    meme_agence?(current_user) &&
      (current_user.technicien_at? ||
        current_user.technicien_direction_at?) && (accepte? or rechute?) &&
      !nombre_jours_ouvres.nil?
  end

  def can_add_frais?(current_user)
    meme_agence?(current_user) &&
      (current_user.technicien_at? ||
        current_user.technicien_direction_at?) && (accepte? or rechute?) &&
      !nombre_jours_ouvres.nil?
  end

  def peut_tout_liquide_frais?(current_user)
    (current_state >= :accepte) &&
      !gueris? &&
      (current_user.technicien_at? || current_user.technicien_direction_at?) &&
      at_frais_engages.creation.length > 0
  end

  def chef_agence_peut_soumettre?(current_user)
    en_instruction? &&
      current_user.chef_agence? &&
      meme_agence?(current_user) &&
      at_avis.where(est_valide: false, fait_par_profil: ['chef_agence']).size >= 1
  end

  def chef_agence_peut_affecter?(current_user)
    (en_instruction? && current_user.chef_agence?) or
      (accepte? && current_user.chef_agence?)
  end

  def chef_division_at_peut_soumettre?(current_user)
    avis_chefService? && current_user.chef_division_at?
  end

  def redacteur_peut_soumettre?(current_user)
    en_instruction? && current_user.redacteur? && avis_completer?
  end

  def chef_division_at_peut_affecter_redacteur?(current_user)
    (soumis_chefService? && current_user.chef_division_at?) &&
      !est_affecte?
  end

  def chef_division_at_peut_affecter_tech?(current_user)
    (accepte? && current_user.chef_division_at?) &&
      est_affecte? &&
      !affectation_at

  end

  def chef_division_at_peut_affecter?(current_user)
    (soumis_chefService? && current_user.chef_division_at?) or
      (accepte? && current_user.chef_division_at?)
  end

  def directeur_peut_agir?(current_user)
    soumis_directeur? && current_user.directeur_at?
  end

  def total_frais_engages
    self.at_frais_engages.map(&:montant_en_chiffre).compact.reduce(:+) || 0
  end

  def total_frais_valide
    self.at_frais_engages.where(etat: :validation_comptable).map(&:montant_en_chiffre).compact.reduce(:+) || 0
  end

  def total_idemnites
    self.at_decomptes.map(&:montant).compact.reduce(:+) || 0
  end

  def total_idemnites_valide
    self.at_decomptes.where(etat: :validation_comptable).map(&:montant).compact.reduce(:+) || 0
  end

  def redacteur
    User.find_by(id: affecte_a.to_i)
  end

  def est_affecte?
    affecte_a.present?
  end

  def est_affecte_tech?
    affectation_at.present? && (accepte? or rechute?)
  end

  def can_affecter_tech?(current_user)
    (accepte? or rechute?) and
      (current_user.chef_agence? || current_user.chef_division_at?) &&
        !est_affecte_tech?

  end

  def creer_par
    @creer_par ||= User.find_by(id: user_id)
  end

  def creer_par_agence
    @agence ||= creer_par.agence
  end

  # def meme_agence?(current_user)
  #   return true if current_user.admin?
  #   creer_par.agence && creer_par.agence == current_user.agence
  # end

  def meme_agence?(current_user)
    return true if current_user.admin?
    admin_agence && admin_agence == current_user.agence
  end

  def validate_start_at_date
    if arret_travail? && (self.date_accident.to_date > self.debut_arret_travail.to_date || self.debut_arret_travail.to_date > DateTime.current.to_date)
      errors.add(:debut_arret_travail, 'La date d’arrêt ne doit pas être antérieure à la date de l’accident ni postérieure à la date du jour')
    end
  end

  def nb_jour_incapacite
    return date_fin.day - date_debut.day
  end

  def liquiider_all_frais_engages
    if accepte?
      unless at_frais_engages.nil?
        at_frais_engages.each do |frais|
          frais.valide!
        end
      end
    end
  end

  def retour_liquider_all_frais_engages
    unless at_frais_engages.nil?
      at_frais_engages.each do |frais|
        frais.retour_liquider
      end
    end
    unless at_decomptes.nil?
      at_decomptes.each do |decomptes|
        decomptes.retour_liquider
      end
    end
  end

  def retour_validation_all_frais_engages
    unless at_frais_engages.nil?
      at_frais_engages.each do |frais|
        frais.retour_valider
      end
    end
    unless at_decomptes.nil?
      at_decomptes.each do |decomptes|
        decomptes.retour_valider
      end
    end
  end

  def retour_validation_comptable_all_frais_engages
    unless at_frais_engages.nil?
      at_frais_engages.each do |frais|
        frais.retour_validation_comptable
      end
    end

    unless at_decomptes.nil?
      at_decomptes.each do |decomptes|
        decomptes.retour_validation_comptable
      end
    end
  end

  def infos_employeur
    if !carrieres_prestation.nil?
      last_carriere = carrieres_prestation.last
      return last_carriere.employeur unless last_carriere.nil?
    end
  end

  def controle_date_naissance
    unless self.date_de_naissance_salarie.nil?
      age = Date.today.year - self.date_de_naissance_salarie.to_date.year
      if age >= 60
        msg = "L'age du salarié est supérieur à 60 ans"
      end
    end
    return msg
  end

  def dir_at_can_accepte?(current_user)
    soumis_directeur? && current_user.directeur_at? &&
      avis_completer? && at_avis.where(est_valide: false, fait_par_profil: ['directeur_at']).size >= 1
  end

  def nombre_jours_ouvres
    joa = Admin::JourOuvrableAnnuel.where(mois: MONTH_IN_FR[mois_precedent_accident.to_sym], annee: annee_mois_precedent_accident).first
    unless joa.nil?
      return joa.nombre_jour_ouvrable
    else
      return 24
    end
  end

  def redacteur_peut_soumettre_avis?(current_user)
    affecte_redacteur? && current_user.redacteur? &&
      at_avis.where(est_valide: false, fait_par_profil: ['redacteur']).size >= 1
  end

  def chefServiceAt_peut_soumettre_avis?(current_user)
    avis_dajc? && at_avis.where(est_valide: false, fait_par_profil: ['chef_division_at']).size >= 1 && current_user.chef_division_at?
  end

  def est_decede?
    return true unless consequence_accident_travail.nil?
  end

  def can_open_guerison
    (accepte? or rechute?) and
      meme_agence?(current_user) and
      (current_user.technicien_at? ||
        current_user.technicien_direction_at?)

  end

  def can_open_rechute
    gueris? and

      meme_agence?(current_user) and
      (current_user.technicien_at? ||
        current_user.technicien_direction_at?)

  end

  private

  def arrondir_cfa(mnt)
    arr = mnt.round
    while arr % 5 != 0 do
      arr = arr.next
    end
    arr
  end

  def to_be_submit!
    self.etat = 'creation'
    self.deleted = false
  end

  def set_declarant!
    if self.declarant == 'lui_meme'
      self.prenom_declarant = self.prenom_salarie
      self.nom_declarant = self.nom_salarie
    end
    self.infirmite_anterieure_accident = false if self.infirmite_anterieure_accident.nil?
  end

  def self.only_one_open_document?(numero_affiliation)
    ArretTravail.exists?(numero_affiliation: numero_affiliation, etat: ['creation', 'soumis_chef_agence', 'en_instruction', 'soumis_chefService', 'soumis_directeur'])
  end

  def current_month
    Time.now.strftime("%B").downcase
  end

  def mois_precedent_accident
    return (date_accident - 1.month).strftime("%B").downcase
  end

  def annee_mois_precedent_accident
    return (date_accident - 1.month).year.to_s
  end

  def set_document_number!
    annee = Date.today.year
    if prev_document_exist?
      dernier_dossier_ajoute = ArretTravail.where(numero_affiliation: numero_affiliation, created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year)).order('created_at DESC').first
      self.num_dossier = dernier_dossier_ajoute.num_dossier.next
    else
      self.num_dossier = "#{numero_affiliation}#{creer_par.agence.code_site}01"
    end
  end

  def validate_nin_salarie
    if type_de_piece == "cni"
      if nin_salarie.length < 13
        errors.add(:nin_salarie, "Le numéro piéce doit etre supérieur à 14 chiffres")
      end
    end
  end

  def is_nin_cni?
    type_de_piece == "cni"
  end

  def prev_document_exist?
    ArretTravail.exists?(numero_affiliation: numero_affiliation, created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year))
  end

  #------------ Validation réouverture de dossier------------------------------------------------------------------------------------------------
  def validate_date_reouverture_dossier
    if date_reouverture_dossier.nil?
      errors.add(:date_reouverture_dossier, "est obligatoire")
    elsif date_reouverture_dossier <= date_cloture_dossier
      errors.add(:date_reouverture_dossier, " doit etre postérieure à la date de cloture")
    end
  end

  def validate_certificat_medical
    unless certificat_medical.attached?
      errors.add(:certificat_medical, " est obligatoire")
    end
  end

  def nombre_frais_engages_a_liquider
    self.at_frais_engages.where(date_liquidation: nil)
  end

  def validate_numero_affiliation
    return if numero_affiliation.nil? or numero_affiliation.empty?
    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Psrm::Participant.where(matric: numero_affiliation).exists?
  end

  def validate_date_naissance
    unless self.date_de_naissance_salarie.nil?
      age = Date.today.year - self.date_de_naissance_salarie.to_date.year
      puts "AGE", age
      if age >= 60
        errors.add(:date_de_naissance_salarie, "doit etre inférieure à 60 ans #{age}")
      end
    end
  end

  def salaire_exist?
    has_numero_affiliation == 1
  end

  def gen_num_temporaire
    num_temp = 7.times.map { rand(10) }.join
    num_temp
  end

  #def set_nomero_temporaire!
   # num_tp = loop do
   #   num_temp = gen_num_temporaire  # Supposons que cette méthode génère un numéro
   #   break num_temp unless  (Psrm::Participant.where(matric: num_temp).exists? || ArretTravail.exists?(numero_temporaire: num_temp) )  # Vérifie si le numéro existe déjà
    #end
    #self.numero_temporaire = "999#{num_tp}"
    #self.num_dossier = "#{num_tp}#{creer_par.agence.code_site}01"
    #numero_temporaire = "#{numero_temporaire }#{creer_par.agence.code_site}01" if has_numero_affiliation==0 and !numero_affiliation.blank?
  #end

  #def set_num_dossier!
  # self.num_dossier = "#{self.numero_temporaire }#{creer_par.agence.code_site}01" if !has_numero_affiliation?
  # end

end
