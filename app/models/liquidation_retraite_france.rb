class LiquidationRetraiteFrance < ApplicationRecord
  include MyTools
  include WorkflowActiverecord
  include Documentable
  include ActsAsWorkflowHistory
  include HasBankAccount

  TYPE_DOCUMENT_OBLIGATOIRE = {
    formulaire_demande_pension: 78,
    formulaire_convention_france_senegal_CFS: 68,
    cni: 1,
    attestation_travail: 3

  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {

      acte_etat_civil: 111,
      certificat_mariage: 4,
      certificat_divorce: 5,
      passeport: 8,
      carte_consulaire: 9,
      rib: 10,
      certificat_medical: 19,
      certif_empl_sal: 27,
      protocole_accord_branche: 80,
      certificat_vie_individuelle: 62,
      certificat_vie_collectif: 81,
      certificat_tutelle: 25,
      certificat_charge_entretien: 82,
      attestation_administrative: 83,
      declaration_sur_honneur: 20,
      decision_engagement: 84,
      decision_radiation: 85,
      bulletin_de_salaire: 53,
      releve_navigation: 88,
      tableau_indicatif_marin: 89,
      contre_expertise: 96
    }
  ).freeze

  InvalidTransitionError = Class.new(StandardError)

  workflow_column :workflow_state

  workflow do
    state :creation, meta: { label: 'Création' } do
      event :est_soumis, transition_to: :soumis
    end

    state :soumis, meta: { label: 'Soumis' } do
      event :est_instruit, transition_to: :instruit

      event :retour_creation, transition_to: :creation
    end

    state :instruit, meta: { label: 'Instruit' } do
      event :est_carriere_soumis, transition_to: :carriere_soumis

      event :retour_soumis, transition_to: :soumis
    end

    state :carriere_soumis, meta: { label: 'Carrière soumise' } do
      event :est_carriere_valide, transition_to: :cotisation_valide

      event :retour_instruit, transition_to: :instruit
    end

    state :cotisation_valide, meta: { label: 'Cotisation validée' } do
      event :est_recap_soumis, transition_to: :recap_soumis

      event :retour_carriere, transition_to: :carriere_soumis
    end

    state :recap_soumis, meta: { label: 'Récap soumis' } do
      event :est_recap_valide, transition_to: :liquidation_valide

      event :retour_cotisation, transition_to: :cotisation_valide
    end

    state :liquidation_valide, meta: { label: 'Liquidation validée' } do
      event :est_dossier_valide, transition_to: :dossier_valide,
            if: proc { |o| o.peut_etre_valide? }
      event :est_dossier_rejete, transition_to: :dossier_rejete

      event :retour_recap, transition_to: :recap_soumis
    end

    state :dossier_valide, meta: { label: 'Valide' }
    state :dossier_rejete, meta: { label: 'Rejeté' }

    on_transition do |from, to, _triggering_event, *_event_args|
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
      puts " => traite par : #{traite_par} "
    end

    on_error do |_error, from, to, _event, *_args|
      puts "Exception(#error.class) on #{from} -> #{to}"
    end
  end

  def est_dossier_valide
    unless peut_etre_valide?
      halt! 'Ce dossier ne peut pas être validé : Paiement unique pour une retraire anticipée.'
    end
  end

  TYPE_RETRAITE = {
    retraite_normale: 1,
    retraite_anticipee_valide: 2,
    retraite_anticipee_invalide: 3,
    # accords_branche: 4,
    accords_branche_55: 5,
    accords_branche_56: 6,
    accords_branche_57: 7,
    accords_branche_58: 8,
    accords_branche_59: 9,
    regime_employes_maison: 10,
    pre_liquidation: 11
  }.freeze

  MOTIF_NOT_COMPLETED = {
    en_attente_numerisation: 1,
    ouvert_en_cip: 2,
    en_attente_documents_obligatoires: 3,
    declarations_manquantes: 4
  }.freeze

  enum type_retraite: TYPE_RETRAITE
  enum mode_paiement: MODE_PAIEMENT
  enum zone: ZONE
  enum motif_not_completed: MOTIF_NOT_COMPLETED

  SEXE = {
    homme: 1,
    femme: 2
  }.freeze
  enum sexe: SEXE

  SENS_CONVENTION = {
    resident_sn: 1,
    resident_fr: 2,
  }.freeze
  enum sens_convention: SENS_CONVENTION

  SITUATION_FAMILIALE = {
    celibataire: 1,
    marie: 2,
    veuf: 3,
    divorce: 4,
    remarie: 5,
    separe_de_corps: 6,
    separe_de_fait: 7
  }.freeze
  enum situation_familiale: SITUATION_FAMILIALE

  PRECISION_CARRIERE = {
    carriere_sn: 1,
    carriere_fr: 2,
    carriere_sn_et_fr: 3
  }.freeze
  enum precision_carriere: PRECISION_CARRIERE

  REGIME_MATRIMONIALE = {
    monogame: 1,
    polygame: 2,
    aucun: 3
  }.freeze
  enum regime_matrimoniale: REGIME_MATRIMONIALE

  NATURE_AVANTAGE_CONJ = {
    veillesse: 1,
    invalidite: 2,
    accident_de_travail: 3
  }.freeze
  enum nature_avantage_conjoint: NATURE_AVANTAGE_CONJ

  scope :traitement_en_cours, -> { where(workflow_state: [:instruit]) }
  scope :en_attente, -> { where(workflow_state: [:soumis]) }

  scope :can_affecte, -> { where(workflow_state: %i[instruit carriere_soumis cotisation_valide]) }
  scope :visible_for_admins, -> { where(workflow_state: %i[creation soumis instruit carriere_soumis cotisation_valide liquidation_valide recap_soumis dossier_valide]) }
  scope :en_attente_allocation, -> { where(workflow_state: %i[instruit carriere_soumis cotisation_valide]).where(affectation_allocataire: nil) }
  scope :en_attente_cotisation, -> { where(workflow_state: [:instruit]).where(affectation_salarie: nil) }

  scope :demandes_affectees, -> { where(workflow_state: %i[instruit carriere_soumis cotisation_valide]).where.not(affectation_salarie: nil) }

  scope :non_affecter, -> { where(affectation_allocataire: nil) }
  scope :en_agence, ->(id) { where('ajoute_par_id = ?', id) }
  scope :mes_affectations_allocataire, ->(id) { where('affectation_allocataire = ?', id) }
  scope :mes_affectations_salarie, ->(id) { where('affectation_salarie = ?', id) }
  scope :valider_carriere, -> { where(carriere_valide: false) }
  scope :dossiers_retournes, -> { where(workflow_state: %i[creation soumis instruit carriere_soumis cotisation_valide liquidation_valide recap_soumis]).where.not(motif: nil) }
  scope :non_retourner, -> { where(motif: nil) }
  scope :dossiers_incomplets, -> { where(not_completed: true) }

  belongs_to :user, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  belongs_to :rejet_allocataire_par, class_name: 'User', foreign_key: :rejet_allocataire_par_id, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :instruit_par, class_name: 'User', foreign_key: :instruit_par_id, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
  belongs_to :update_fullname_par, class_name: 'User', foreign_key: :update_fullname_id, optional: true

  belongs_to :soumission_carriere_par, class_name: 'User', foreign_key: :soumission_carriere_par, optional: true
  belongs_to :validation_carriere_par, class_name: 'User', foreign_key: :validation_carriere_par, optional: true
  belongs_to :soumission_validation_par, class_name: 'User', foreign_key: :soumission_validation_par, optional: true
  belongs_to :validation_liquidation_par, class_name: 'User', foreign_key: :validation_liquidation_par, optional: true

  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affectation_allocataire, optional: true
  belongs_to :affecter_salarie, class_name: 'User', foreign_key: :affectation_salarie, optional: true
  belongs_to :allocataire, optional: true
  belongs_to :nationalite, optional: true, :class_name => 'Admin::Country', foreign_key: :nationalite_id

  # has_many :document_liquidation_retraites, dependent: :destroy
  has_many :enfants, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  # has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :cfs_conjoints, foreign_key: :numero_securite_sociale, primary_key: :numero_securite_sociale, dependent: :destroy
  has_many :carrieres_prestation, class_name: 'Carriere', foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :carrieres, class_name: 'Psrm::Carriere', foreign_key: :matric, primary_key: :numero_affiliation

  has_many :carrieres_exterieures, dependent: :destroy
  has_many :periode_assurances, dependent: :destroy
  has_many :revenu_conjoints, dependent: :destroy
  has_many :bien_pers_conjoints, dependent: :destroy
  has_many :donation_conjoints, dependent: :destroy
  # has_many :cfs_conjoints, dependent: :destroy
  has_many :cfs_enfants, dependent: :destroy
  has_many :cfs_correspondances, dependent: :destroy

  belongs_to :participant, class_name: 'Psrm::Participant',
             foreign_key: :numero_affiliation,
             primary_key: :matric,
             optional: true

  # has_many :workflow_histories, foreign_key: :dossier_id

  belongs_to :admin_region, class_name: 'Admin::Region', foreign_key: :admin_region_id, optional: true
  belongs_to :admin_agence, class_name: 'Admin::Agence', foreign_key: :admin_agence_id, optional: true
  belongs_to :agence_creation, class_name: 'Admin::Agence', foreign_key: :agence_creation_id, optional: true

  validates :motif_rejet, presence: true, if: :dossier_rejete?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :num_dossier, uniqueness: true

  # validates :precision_carriere, :sexe, :prenom, :nom, :date_naissance, :lieu_naissance,
  #           :type_retraite, :situation_familiale, :mode_paiement, presence: true
  validates :numero_securite_sociale, :date_ouverture, :sens_convention, :sexe, :prenom, :nom,
            :type_retraite, presence: true
  # validates  :date_naissance, presence: true
  # validates :adresse_reception_allocation, :prenom_pere, :nom_pere, :prenom_mere, :nom_mere,
  #           :date_ouverture, :sens_convention, presence: true
  # validates :numero_affiliation, :date_cessation_activite, presence: true,
  #           if: :carriere_sn? or :carriere_sn_et_fr?
  # validates :num_immatric_cfs, :date_cess_act_fr, :total_an_carriere_fr, presence: true,
  #           if: :carriere_fr? or :carriere_sn_et_fr?

  before_validation :set_numero_affiliation!

  validate :validate_numero_affiliation, on: :create
  validate :type_retraite_validation
  validate :date_cessation_activite_validation
  # validate :carriere_and_sensConvention_validation
  validate :documents_deposes_obligatoires_valide, on: :create

  validates :admin_agence_id,
            presence: true,
            if: -> { caisse_ipres? || paiement_a_domicile? },
            on: :create

  validates :adresse_paiement,
            presence: true,
            if: -> { paiement_a_domicile? },
            on: :create

  before_create :set_user!, :set_numero_dossier!, :set_agence_creation!, :set_date_ouverture!
  after_create :create_carriere!
  after_save :generate_allocataire!

  def full_name
    "#{prenom unless prenom.nil?} #{nom unless nom.nil?}"
  end

  def full_name_mere
    "#{prenom_mere unless prenom_mere.nil?} #{nom_mere unless nom_mere.nil?}"
  end

  def full_name_pere
    "#{prenom_pere unless prenom_pere.nil?} #{nom_pere unless nom_pere.nil?}"
  end

  def date_validation
    valider_le || workflow_histories.where(to: 'dossier_valide').maximum(:created_at) || Date.today
  end

  def peut_etre_valide?
    !(retraite_anticipee_valide? && versement_unique?)
  end

  def traite?
    dossier_valide? || dossier_rejete?
  end

  def etat_civil_demandeur_valide!(est_valide = true)
    update(etat_civil_demandeur_valide: est_valide)
  end

  def update_numero_trouve!(trouve = true)
    update(numero_trouve: trouve)
  end

  def update_affiliation!(trouve = true)
    update(affiliation: trouve)
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

  def activite_prof_valide!(est_valide = true)
    update(activite_prof_valid: est_valide)
  end

  def assur_residence_valide!(est_valide = true)
    update(assur_residence_valid: est_valide)
  end

  def assur_second_pays_valide!(est_valide = true)
    update(assur_second_pays_valid: est_valide)
  end

  def ressources_conjoint_valide!(est_valide = true)
    update(ressources_conjoint_valid: est_valide)
  end

  def charge_second_pays_valide!(est_valide = true)
    update(charge_second_pays_valid: est_valide)
  end

  def recap_point_valide!(est_valide = true)
    update(recap_point_valide: est_valide)
  end

  def documents_valide!(est_valide = true)
    if est_valide
      if documents.where(type_document: [:formulaire_demande_pension]).empty?
        return false
      end
      if documents.where(type_document: %i[cni passeport carte_consulaire]).empty?
        return false
      end
      if documents.where(type_document: [:attestation_travail]).empty?
        return false
      end
      if accord_branche_valide? && documents.where(type_document: [:protocole_accord_branche]).empty?
        return false
      end # type_retraite
      return false if virement? && documents.rib.empty?

      update(documents_valide: est_valide)
    else
      update(documents_valide: est_valide)
    end
    true
  end

  def pret_pour_soumission?
    # etat_civil_demandeur_valide && epouses_valide && enfants_valide && documents_valide && activite_prof_valid && assur_residence_valid && ressources_conjoint_valid && !not_completed?
    etat_civil_demandeur_valide && epouses_valide && enfants_valide && documents_valide && !not_completed?
  end

  def traitement_en_cours?
    current_state.between? :instruit, :carriere_soumis
  end

  def can_affecte_gestionnaire?
    current_state >= :instruit
  end

  def can_update_fullname?
    current_state <= :soumis
  end

  def can_affecte_ges_salarie_again?
    (current_state >= :instruit) && (current_state < :carriere_soumis)
  end

  def can_affecte_ges_allocataire_again?
    (current_state >= :instruit) && (current_state < :recap_soumis)
  end

  def pret_pour_validation?
    carriere_valide && recap_point_valide
  end

  def affecter_allocatation?
    !affecter_allocataire.nil?
  end

  def affecter_cotisation?
    !affecter_salarie.nil?
  end

  def age_retraite
    age = date_cessation_activite.year - date_naissance.year
    age -= 1 if date_cessation_activite < date_naissance + age.years
    age
  end

  def age_ouverture_demande
    date_fin = (date_soumission || date_ouverture || Date.today).to_date # 2021 - 1977 = 44
    age = date_fin.year - date_naissance.year #
    age -= 1 if date_fin < date_naissance + age.years
    age
  end

  def age_ouverture_demande_en_mois
    date_fin = (date_soumission || Date.today).to_date
    ((date_fin - date_naissance) / 30.437).ceil
  end

  def enfants_majoration
    enfants.valide.mineurs
           .where('date_naissance <= ?', instruit_le || DateTime.now)
           .order('date_naissance DESC, created_at')
           .limit(3)
  end

  def taux_majoration
    nombre_enfants_mineurs = enfants.valide.mineurs.where(origine_enfant: %i[mariage adulterin])
                                    .where('date_naissance <= ?', instruit_le || DateTime.now).count
    taux = [15, 5 * nombre_enfants_mineurs].min
    (1.0 * taux)
  end

  def taux_minoration_rc
    if retraite_normale? || retraite_anticipee_invalide? || regime_employes_maison?
      return 0
    end

    if retraite_anticipee_valide?
      if age_ouverture_demande_en_mois >= 12
        coefficient_minoration = 1.0 * [20, (60 - age_ouverture_demande) * 4].min
      else
        nb_mois = age_ouverture_demande_en_mois
        n_semestres = (nb_mois / 3.0).ceil
        coefficient_minoration = 1.0 * [20, n_semestres * 1.0].min
      end
      (1.0 * coefficient_minoration)

    elsif accord_branche_valide?
      if age_ouverture_demande_en_mois >= 12
        calcul_age = [0, (get_age_retrait_accord - age_ouverture_demande)].max
        coefficient_minoration = 1.0 * [20, calcul_age * 4].min
      else
        nb_mois = age_ouverture_demande_en_mois
        n_semestres = (nb_mois / 3.0).ceil
        coefficient_minoration = 1.0 * [20, n_semestres * 1.0].min
      end
      (1.0 * coefficient_minoration)
    end
  end

  def taux_minoration_rg
    if retraite_normale? || retraite_anticipee_invalide? || regime_employes_maison?
      return 0
    end

    if retraite_anticipee_valide?
      if age_ouverture_demande_en_mois >= 12
        coefficient_minoration = 1.0 * [25, (60 - age_ouverture_demande) * 5].min
      else
        nb_mois = age_ouverture_demande_en_mois
        n_semestres = (nb_mois / 3.0).ceil
        coefficient_minoration = 1.0 * [25, n_semestres * 1.5].min
      end
      (1.0 * coefficient_minoration)
    elsif accord_branche_valide?
      if age_ouverture_demande_en_mois >= 12
        calcul_age = [0, (get_age_retrait_accord - age_ouverture_demande)].max
        coefficient_minoration = 1.0 * [25, calcul_age * 5].min
      else
        nb_mois = age_ouverture_demande_en_mois
        n_semestres = (nb_mois / 3.0).ceil
        coefficient_minoration = 1.0 * [25, n_semestres * 1.5].min
      end
      (1.0 * coefficient_minoration)
    end
  end

  def nb_jours_travail
    carrieres_prestation.valide.map(&:nb_jours_travail).sum
  end

  def nb_mois_travail
    (nb_jours_travail / 30.437).ceil
  end

  def nb_trimestre_travail
    ((nb_jours_travail / 30.437) / 3).ceil
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

  def calcul_points_complementaires
    0
  end

  def calcul_points_minoration_regime_general
    if retraite_normale? || retraite_anticipee_invalide? || regime_employes_maison?
      return 0
    end

    carrieres_prestation.valide.regime_general.map do |carriere|
      (1.0 * (carriere.points + carriere.points_gratuits) * taux_minoration_rg / 100)
    end.sum.round
  end

  def calcul_points_minoration_regime_cadre
    if retraite_normale? || retraite_anticipee_invalide? || regime_employes_maison?
      return 0
    end

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

  def versement_unique?
    !versement_mensuel?
  end

  def versement_mensuel?
    if regime_employes_maison? && (calcul_points_base_regime_general >= 500)
      return true
    end
    return true if regime_employes_maison? && (nb_mois_travail >= 60)

    if regime_employes_maison? && (calcul_points_base_regime_general >= 1_000)
      return true
    end
    return true if calcul_points_base_regime_general >= 1_000
    # return true if participant.nombre_annee_cotisation >= 10
    return true if nb_mois_travail >= 120

    false
  end

  def calcul_allocation_regime_general(date = Date.today)
    if versement_mensuel?
      valeur_point = Admin::BaremePension.valeur_mensuelle_general_du(date)
      (calcul_points_servis_regime_general * valeur_point).ceil
    else
      salaire_reference = Admin::Bareme.salaire_reference_general_du(date.last_year)
      (calcul_points_servis_regime_general * salaire_reference).ceil
    end
  end

  def calcul_allocation_regime_cadre(date = Date.today)
    if versement_mensuel?
      valeur_point = Admin::BaremePension.valeur_mensuelle_cadre_du(date)
      (calcul_points_servis_regime_cadre * valeur_point).ceil
    else
      salaire_reference = Admin::Bareme.salaire_reference_cadre_du(date.last_year)
      (calcul_points_servis_regime_cadre * salaire_reference).ceil
    end
  end

  def calcul_allocation(date = Date.today)
    calcul_allocation_regime_general(date) + calcul_allocation_regime_cadre(date)
  end

  def calcul_allocation_point_base_rg(date = Date.today)
    if versement_mensuel?
      valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_general_du(date)
      (calcul_points_base_regime_general * valeur_point_mensuelle).ceil
    else
      salaire_reference = Admin::Bareme.salaire_reference_general_du(date.last_year)
      (calcul_points_base_regime_general * salaire_reference).ceil
    end
  end

  def calcul_allocation_point_base_rc(date = Date.today)
    if versement_mensuel?
      valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_cadre_du(date)
      (calcul_points_base_regime_cadre * valeur_point_mensuelle).ceil
    else
      salaire_reference = Admin::Bareme.salaire_reference_cadre_du(date.last_year)
      (calcul_points_base_regime_cadre * salaire_reference).ceil
    end
  end

  def calcul_allocation_point_base(date = Date.today)
    calcul_allocation_point_base_rg(date) + calcul_allocation_point_base_rc(date)
  end

  def calcul_date_jouissance
    da = date_ouverture || created_at || Date.today
    dj = da
    if da.beginning_of_month == date_cessation_activite.beginning_of_month
      dj = (da + 1.day)
    end
    dj = da.beginning_of_bimester if da > date_cessation_activite

    if date_cessation_activite.beginning_of_month == dj.beginning_of_month
      dj = date_cessation_activite + 1.day
    end

    date_anniversaire = if retraite_normale?
                          if date_cessation_activite > Date.new(2016, 0o7, 0o1)
                            date_naissance + 60.years
                          else
                            date_naissance + 55.years
                          end
                        elsif retraite_anticipee_valide?
                          date_naissance + 55.years
                        elsif retraite_anticipee_invalide?
                          date_naissance + 55.years
                        elsif accord_branche_valide?
                          date_naissance + get_age_retrait_accord.years
                        else
                          Date.new(date_cessation_activite.year, date_naissance.month, date_naissance.day)
                        end

    dj = date_anniversaire + 1.day if dj < date_anniversaire

    [dj, date_cessation_activite + 1.day].max
  end

  def calcul_subvention(date = Date.today)
    versement_mensuel? ? 35_000 - [35_000, calcul_allocation_point_base(date)].min : 0
  end

  def calcul_pourcentage
    return 10 if creation?
    return 20 if soumis?
    return 45 if instruit?
    return 50 if carriere_soumis?
    return 60 if cotisation_valide?
    return 75 if recap_soumis?
    return 90 if liquidation_valide?
    return 100 if dossier_valide?
    return 100 if dossier_rejete?

    0
  end

  # calcul remboursement de cotisation
  #

  def montant_valeur_point_rc
    Admin::BaremePension.valeur_mensuelle_cadre_du(date_soumission || Date.today)
  end

  def montant_valeur_point_rg
    Admin::BaremePension.valeur_mensuelle_general_du(date_soumission || Date.today)
  end

  # def calcul_montant_rappel
  #   return 0 if versement_unique?
  #   montant_net = calcul_allocation + calcul_subvention
  #   nombre_mois = (date_validation.year * 12 + date_validation.month) - (calcul_date_jouissance.year * 12 + calcul_date_jouissance.month)
  #   nombre_jours = (calcul_date_jouissance.end_of_month.day - calcul_date_jouissance.day).to_i
  #
  #   (([nombre_jours, 30].min * montant_net) / 30).ceil + montant_net * (nombre_mois + 1)
  # end

  def calcul_montant_rappel(_date = Date.today)
    return 0 if versement_unique?

    d_jouissance = calcul_date_jouissance
    d_validation = date_validation

    montant = 0
    nombre_mois = (d_validation.year * 12 + d_validation.month) - (d_jouissance.year * 12 + d_jouissance.month) # + 1

    1.upto nombre_mois + 1 do |i|
      d = d_jouissance + i.month
      montant += calcul_allocation(d) + calcul_subvention(d)
    end

    m_jouissance = calcul_allocation(d_jouissance) + calcul_subvention(d_jouissance)
    nombre_jours = (d_jouissance.end_of_month.day - d_jouissance.day).to_i

    (([nombre_jours, 30].min * m_jouissance) / 30).ceil + montant
  end

  def retourner_all_carrieres(carrieres)
    carrieres&.each do |carriere|
      carriere.etat = :en_attente
      carriere.save
    end
  end

  def can_make_not_incomplet?(current_user)
    (current_user.gestionnaire_compte_allocataire? && creation? && ajoute_par == current_user) ||
      (current_user.gestionnaire_compte_salarie? && instruit? && affecter_salarie == current_user)
  end

  def can_integrate_carrieres?(current_user)
    current_user.gestionnaire_compte_salarie? && instruit? && affecter_salarie == current_user
  end

  def tableau_rappel
    d_jouissance = calcul_date_jouissance
    montant_d_jouissance = calcul_allocation(d_jouissance) + calcul_subvention(d_jouissance)
    nombre_mois = (date_validation.year * 12 + date_validation.month) - (d_jouissance.year * 12 + d_jouissance.month)

    nombre_jours = (d_jouissance.end_of_month.day - d_jouissance.day).to_i

    r_tableau_rappel = []

    r_montant_first_month = (([nombre_jours, 30].min * montant_d_jouissance) / 30).ceil

    r_montant_total_rappel = r_montant_first_month

    r_date_prochain_rappel = d_jouissance + 1.month

    r_tableau_rappel << ["#{d_jouissance.strftime('%d/%m/%Y')} - #{d_jouissance.end_of_month.strftime('%d/%m/%Y')}", r_montant_first_month]

    (1..nombre_mois + 1).each do
      montant = calcul_allocation(r_date_prochain_rappel) + calcul_subvention(r_date_prochain_rappel)
      r_tableau_rappel << ["#{r_date_prochain_rappel.beginning_of_month.strftime('%d/%m/%Y')} - #{r_date_prochain_rappel.end_of_month.strftime('%d/%m/%Y')}", montant]
      r_montant_total_rappel += montant
      r_date_prochain_rappel += 1.month
    end
    [r_tableau_rappel, r_montant_total_rappel, r_date_prochain_rappel]
  end

  def verification_affiliation

  end

  def generate_allocataire!
    if dossier_valide? && !Allocataire.exists?(numero_allocataire: numero_affiliation)
      GenerateAllocataireFromLiquidationFranceJob.perform_later(self)
    end
  end

  def generate_allocataire
    with_lock do
      if dossier_valide? && !Allocataire.exists?(numero_allocataire: numero_affiliation)
        allocataire = Allocataire.new(
          numero_allocataire: numero_affiliation,
          ipres_ancien_matric: participant.ipres_ancien_matric,
          css_ancien_matric: participant.css_ancien_matric,
          nom: nom,
          prenom: prenom,
          email: email,
          sexe: participant.homme? ? :homme : :femme,
          date_naissance: date_naissance,
          categorie: :retraite,
          etat: :inactif,
          nombre_epouses: cfs_conjoints.valide.count,
          nombre_enfants: enfants.valide.count,
          adresse_rue: adresse_reception_allocation,
          code_pays: 'SN',
          telephone: telephone,
          numero_identification_nationale: participant.try(:numero_piece),

          mode_paiement: mode_paiement,
          admin_banque_agence: admin_banque_agence,
          compte_bancaire_numero_compte: compte_bancaire_numero_compte,
          compte_bancaire_cle_rib: compte_bancaire_cle_rib,

          regime: carrieres.regime_cadre.any? ? 2 : 1, # 1 : général, 2 : cadre
          age_revolu: age_ouverture_demande,

          enfant1: enfants_majoration.first,
          enfant2: enfants_majoration.second,
          enfant3: enfants_majoration.third,
          date_fin_enfant1: enfants_majoration.first.try(:date_fin_mineur),
          date_fin_enfant2: enfants_majoration.second.try(:date_fin_mineur),
          date_fin_enfant3: enfants_majoration.third.try(:date_fin_mineur),

          versement_unique: !versement_mensuel?,
          date_jouissance: calcul_date_jouissance,

          moyenne: 0,
          mois_gratuis: 0,
          points: calcul_points,
          points_base: calcul_points_base,
          point_minoration: calcul_points_minoration,
          pourcentage_majoration: taux_majoration,
          point_majoration: calcul_points_majoration,
          points_complementaires: 0,
          points_servis: calcul_points_servis,
          montant_imposable: 0,

          moyenne_rg: 0,
          mois_gratuis_rg: 0,
          points_rg: calcul_points_regime_general,
          points_base_rg: calcul_points_base_regime_general,
          pourcentage_minoration_rg: taux_minoration_rg,
          point_minoration_rg: calcul_points_minoration_regime_general,
          pourcentage_majoration_rg: taux_majoration,
          point_majoration_rg: calcul_points_majoration_regime_general,
          points_complementaires_rg: nil,
          points_servis_rg: calcul_points_servis_regime_general,
          montant_brut_rg: calcul_allocation_regime_general,
          montant_imposable_rg: 0,

          moyenne_rc: 0,
          mois_gratuis_rc: 0,
          points_rc: calcul_points_regime_cadre,
          points_base_rc: calcul_points_base_regime_cadre,
          pourcentage_minoration_rc: taux_minoration_rc,
          point_minoration_rc: calcul_points_minoration_regime_cadre,
          pourcentage_majoration_rc: taux_majoration,
          point_majoration_rc: calcul_points_majoration_regime_cadre,
          points_complementaires_rc: 0,
          points_servis_rc: calcul_points_servis_regime_cadre,
          montant_brut_rc: calcul_allocation_regime_cadre,
          montant_imposable_rc: 0,

          montant_net: calcul_allocation + calcul_subvention,
          montant_minimum_fiscal: 0,
          montant_igr: 0,
          montant_rappel: calcul_montant_rappel,
          montant_premier_paiement: 0,
          montant_subvention: calcul_subvention,

          admin_region: admin_region,
          zone: zone,
          admin_agence: admin_agence
        )

        if allocataire.save
          migrate_user_to_allocataire!
          self.allocataire = allocataire
          save
        end
      end
    end
  end

  private

  def migrate_user_to_allocataire!
    user = User.salarie.find_by(numero_salarie: numero_affiliation)
    user&.allocataire!
  end

  def create_carriere!
    # carrieres_prestation.destroy_all
    carrieres.each(&:load_to_prestation)
  end

  def set_numero_affiliation!
    self.numero_affiliation = user.numero_salarie unless user.nil?
  end

  def validate_numero_affiliation
    return if numero_affiliation.blank?

    p = Psrm::Participant.find_by(matric: numero_affiliation)
    # if p.nil?
    #   errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable")
    # else
    #   if Allocataire.where(numero_allocataire: p.ipres_ancien_matric).exists?
    #     errors.add(:numero_affiliation, "L'allocataire existe déjà (ancien numéro IPRES : #{p.ipres_ancien_matric})")
    #   end
    # end

    unless p.nil?
      if Allocataire.where(numero_allocataire: p.ipres_ancien_matric).exists?
        errors.add(:numero_affiliation, "L'allocataire existe déjà (ancien numéro IPRES : #{p.ipres_ancien_matric})")
      end
    end

    if Allocataire.where(numero_allocataire: numero_affiliation).exists?
      errors.add(:numero_affiliation, "L'allocataire existe déjà")
    end

    if LiquidationRetraiteFrance.where(numero_affiliation: numero_affiliation)
                                .where.not(workflow_state: :dossier_rejete).exists?
      errors.add(:numero_affiliation, "Un dossier avec ce numéro d'affiliation existe déjà")
    end

    if LiquidationRetraite.where(numero_affiliation: numero_affiliation)
                          .where.not(workflow_state: :dossier_rejete).exists?
      errors.add(:numero_affiliation, "Un dossier de liquidation Prestations Locales avec ce numéro d'affiliation existe déjà")
    end

    if BaseReversionSalary.where(numero_affiliation: numero_affiliation)
                          .where.not(workflow_state: :dossier_rejete).exists?
      errors.add(:numero_affiliation, "Un dossier avec ce numéro d'affiliation existe déjà")
    end
  end

  def set_user!
    self.user = User.find_by(numero_salarie: numero_affiliation)
  end

  def set_agence_creation!
    self.agence_creation = ajoute_par.try(:admin_agence)
  end

  def set_date_ouverture!
    self.date_ouverture = DateTime.now if date_ouverture.nil?
  end

  def type_retraite_validation
    return unless type_retraite

    if retraite_normale?
      if date_cessation_activite > Date.new(2016, 0o7, 0o1)
        if age_ouverture_demande < 60
          errors.add(:type_retraite, "Votre age de retraite (#{age_ouverture_demande} ans) ne vous permet pas d'être à la retraite normale. Il faut avoir minimum 60 ans à la retraite")
        end
      end
      if date_cessation_activite < Date.new(2016, 0o7, 0o1)
        if age_ouverture_demande < 55
          errors.add(:type_retraite, "Votre age de retraite (#{age_ouverture_demande} ans) ne vous permet pas d'être à la retraite normale. Il faut avoir minimum 55 ans à la retraite")
        end
      end
      return
    elsif regime_employes_maison?
      if (date_cessation_activite > Date.new(2016, 0o7, 0o1)) && (age_ouverture_demande >= 60)
        errors.add(:type_retraite, 'Vous devez choisir la retraite normale. Vous avez plus de 60 ans') && return
      end
      if (date_cessation_activite < Date.new(2016, 0o7, 0o1)) && (age_ouverture_demande >= 55)
        errors.add(:type_retraite, 'Vous devez choisir la retraite normale. Vous avez plus de 55 ans') && return
      end
    end

    if (retraite_anticipee_valide? || retraite_anticipee_invalide?) && (date_cessation_activite < Date.new(2016, 0o7, 0o1))
      errors.add(:type_retraite, "Ce type de retraite n'était pas disponible avant le 01/07/2016")
      return
    end

    if retraite_anticipee_valide?
      if (age_ouverture_demande < 55) && (date_cessation_activite > Date.new(2016, 0o7, 0o1))
        errors.add(:type_retraite, "Votre age de retraite (#{age_ouverture_demande} ans) ne vous permet pas d'être à la retraite anticipée pour un valide. Il faut avoir minimum 55 ans à la retraite")
      end
      return
    end

    if retraite_anticipee_invalide?
      if (age_ouverture_demande < 55) && (date_cessation_activite > Date.new(2016, 0o7, 0o1))
        errors.add(:type_retraite, "Votre age de retraite (#{age_ouverture_demande} ans) ne vous permet pas d'être à la retraite anticipée pour un invalide. Il faut avoir minimum 55 ans à la retraite")
      end
    end
  end

  def date_cessation_activite_validation
    return if date_cessation_activite.nil? or numero_affiliation.nil?

    if date_cessation_activite > Date.today
      errors.add(:date_cessation_activite, "ne peut pas être supérieure à la date d'aujourd'hui")
    end
  end

  def carriere_and_sensConvention_validation
    return if precision_carriere.nil? or sens_convention.nil?

    if resident_sn? and carriere_sn?
      errors.add(:sens_convention, "Ouverture dossier impossible : à faire dans Prestations Locales")
    end
    if resident_fr? and carriere_fr?
      errors.add(:sens_convention, "Ouverture dossier impossible")
    end
  end

  def date_cessation_activite_CFS_validation
    return if date_cessation_activite.nil? or numero_affiliation.nil?

    if date_cessation_activite > Date.today
      errors.add(:date_cessation_activite, "ne peut pas être supérieure à la date d'aujourd'hui")
    end
  end

  def documents_deposes_obligatoires_valide
    if documents_deposes_obligatoires.nil?
      errors.add('Erreur!!!', 'Veuillez cocher les documents obligatoires')
    end
  end

  def set_numero_dossier!
    unless numero_securite_sociale.nil?
      # numero_ordre = LiquidationRetraiteFrance.maximum(:num_dossier)
      #                                         .try(:split, '-')
      #                                         .try(:last)
      #                                         .try(:next) || 1
      #
      # # annee = Date.today.year
      # self.num_dossier = "CFS - #{numero_ordre}"

      numero_ordre = LiquidationRetraiteFrance.maximum(:num_dossier)
      self.num_dossier = numero_ordre.try(:next) || "CFS - 1"
    end
  end

  def accord_branche_valide?
    accords_branche_55? || accords_branche_56? || accords_branche_57? || accords_branche_58? || accords_branche_59?
  end

  def get_age_retrait_accord
    return 55 if accords_branche_55?
    return 56 if accords_branche_56?
    return 57 if accords_branche_57?
    return 58 if accords_branche_58?
    return 59 if accords_branche_59?

    0
  end
end
