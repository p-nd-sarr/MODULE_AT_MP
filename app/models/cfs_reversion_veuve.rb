#class PrestationExtFrance < ApplicationRecord
class CfsReversionVeuve < ApplicationRecord
  include Documentable
  include MyTools

  include WorkflowActiverecord

  InvalidTransitionError = Class.new(StandardError)

  workflow_column :workflow_state

  workflow do
    state :creation do
      event :est_soumis, transition_to: :soumis
    end

    state :soumis do
      event :est_instruit, transition_to: :instruit
      event :retour_creation, transition_to: :creation
    end

    state :instruit do
      event :est_carriere_soumis, transition_to: :carriere_soumis
      event :retour_soumis, transition_to: :soumis
    end

    state :carriere_soumis do
      event :est_carriere_valide, transition_to: :cotisation_valide
      event :retour_instruit, transition_to: :instruit
    end

    state :cotisation_valide do
      event :est_recap_soumis, transition_to: :recap_soumis
      event :retour_carriere, transition_to: :carriere_soumis
    end

    state :recap_soumis do
      event :est_recap_valide, transition_to: :liquidation_valide
      event :retour_cotisation, transition_to: :cotisation_valide
    end

    state :liquidation_valide do
      event :est_dossier_valide, transition_to: :dossier_valide
      event :est_dossier_rejete, transition_to: :dossier_rejete
      event :retour_recap, transition_to: :recap_soumis
    end

    state :dossier_valide
    state :dossier_rejete

    on_transition do |from, to, triggering_event, *event_args|
      puts "#{from} -> #{to}"
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

  scope :can_affecte, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide]) }
  scope :visible_for_admins, -> { where(workflow_state: [:creation, :soumis, :instruit, :carriere_soumis, :cotisation_valide, :liquidation_valide, :recap_soumis, :dossier_valide]) }
  scope :en_attente_allocation, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide]).where(affectation_allocataire: nil) }
  scope :en_attente_cotisation, -> { where(workflow_state: [:instruit]).where(affectation_salarie: nil) }

  scope :non_affecter, -> { where(affectation_allocataire: nil) }
  scope :en_agence, ->(id) { where("ajoute_par_id = ?", id) }
  scope :mes_affectations_allocataire, ->(id) { where("affectation_allocataire = ?", id) }
  scope :mes_affectations_salarie, ->(id) { where("affectation_salarie = ?", id) }
  scope :valider_carriere, -> { where(carriere_valide: :false) }
  scope :traitement_en_cours, -> { where(workflow_state: [:instruit]) }

  scope :en_attente, -> { where(workflow_state: [:soumis]) }
  scope :en_attente_instruction, -> { where(workflow_state: [:soumis]) }
  scope :en_attente_salaire, -> { where(workflow_state: [:instruit]).where(affectation_salarie: nil) }
  scope :can_affecte, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide]) }
  scope :visible_for_admins, -> { where(workflow_state: [:creation, :soumis, :instruit, :carriere_soumis, :cotisation_valide, :liquidation_valide, :recap_soumis, :dossier_valide, :remboursement_regularise]) }
  scope :en_attente_allocation, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide]).where(affectation_allocataire: nil) }
  scope :en_attente_cotisation, -> { where(workflow_state: [:instruit]).where(affectation_salarie: nil) }


  TYPE_RETRAITE = {
      retraite_normale: 1,
      retraite_anticipee_valide: 2,
      retraite_anticipee_invalide: 3
  }.freeze

  enum type_retraite: TYPE_RETRAITE

  TYPE_DOCUMENT_OBLIGATOIRE = {
      copie_cni_legalise: 17,
      certificat_travail: 12,
      formulaire_convention_france_senegal_CFS:68,

      cni_defunt: 110,
      certificat_deces: 11,
      acte_etat_civil: 111,
      copie_carte_consulaire_ou_cni: 112,
      certificat_mariage: 4,
      certificat_non_divorce: 14,
      certificat_vie_collective_enf_moins_21: 77,
      certificat_travail_sn: 113,
      certificat_travail_pays_etranger: 114,
      releve_compte: 115,
      bulletin_de_salaire: 53,
      certificat_jugement_heredite: 101
  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
      {
          #rib: 10,
          certificat_non_remariage: 15,
          extrait_naissance_defunt: 16,
          certificat_deces_coepouse: 116,
          certificat_divorce_coepouse: 117
      }
  ).freeze

  SEXE = {
      masculin: 1,
      feminin: 2,
  }.freeze

  enum sexe_salarie: SEXE

  TYPE_DEMANDE = {
      retraite: 1,
      reversion: 2,
  }.freeze

  enum nature: TYPE_DEMANDE

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

  TYPE_PIECE = {
      cni: 1,
      carte_consulaire: 2,
      passeport: 3,
      extrait_naissance: 4
  }.freeze

  enum type_piece: TYPE_PIECE

  enum mode_paiement: MODE_PAIEMENT

  scope :traitement_en_cours, -> { where(workflow_state: [:instruit]) }
  scope :en_attente, -> { where(workflow_state: [:soumis]) }

  scope :can_affecte, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide]) }
  scope :visible_for_admins, -> { where(workflow_state: [:creation, :soumis, :instruit, :carriere_soumis, :cotisation_valide, :liquidation_valide, :recap_soumis, :dossier_valide]) }
  scope :en_attente_allocation, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide]).where(affectation_allocataire: nil) }
  scope :en_attente_cotisation, -> { where(workflow_state: [:instruit]).where(affectation_salarie: nil) }

  scope :non_affecter, -> { where(affectation_allocataire: nil) }
  scope :en_agence, ->(id) { where("ajoute_par_id = ?", id) }
  scope :mes_affectations_allocataire, ->(id) { where("affectation_allocataire = ?", id) }
  scope :mes_affectations_salarie, ->(id) { where("affectation_salarie = ?", id) }
  scope :valider_carriere, -> { where(carriere_valide: :false) }

  belongs_to :user, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true
  belongs_to :instruit_par, class_name: 'User', foreign_key: :instruit_par_id, optional: true
  belongs_to :valide_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affectation_allocataire, optional: true
  belongs_to :affecter_salarie, class_name: 'User', foreign_key: :affectation_salarie, optional: true
  belongs_to :allocataire, optional: true
  belongs_to :nationalite, optional: true, :class_name => 'Admin::Country', foreign_key: :nationalite_id
  has_many :enfants, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :carrieres_prestation, class_name: 'Carriere', foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :carrieres, class_name: 'Psrm::Carriere', foreign_key: :matric, primary_key: :numero_affiliation
  belongs_to :participant, :class_name => 'Psrm::Participant', foreign_key: :numero_affiliation,
             primary_key: :matric, optional: true
  has_many :carrieres_exterieures, dependent: :destroy
  has_many :periode_assurances, dependent: :destroy
  validates :prenom, :nom, :prenom_defunt, :nom_defunt, :date_naissance, :lieu_naissance, :adresse_residence, :prenom_pere, :nom_pere,
            :prenom_mere, :nom_mere, :date_ouverture_dossier, :situation_familiale, :nature, :sens_convention,
            presence: true
  validates :numero_affiliation, :num_immatric_ipres, :date_cess_act_sn, :total_an_carr_sn,
            presence: true,
            if: :resident_fr?
  validates :num_immatric_cfs, :date_cess_act_fr, :total_an_carr_fr,
            presence: true,
            if: :resident_sn?
  validates :compte_bancaire_code_banque, :compte_bancaire_nom_banque, :compte_bancaire_code_guichet, :compte_bancaire_numero_compte,
            presence: true,
            if: :virement?
  validates :motif_rejet, presence: true, if: :dossier_rejete?
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates_length_of :compte_bancaire_numero_compte, minimum: 24, maximum: 24, if: :virement?
  validate :validate_numero_affiliation, if: :resident_fr?
  #validate :type_retraite_validation, if: :resident_fr?
  before_validation :set_numero_affiliation!

  before_create :set_user!, :set_numero_dossier!
  after_create :create_carriere!
  after_save :create_allocataire!

  def full_name
    "#{prenom} #{nom}"
  end

  def traite?
    dossier_valide? or dossier_rejete?
  end

  def recap_point_valide!(est_valide = true)
    update(recap_point_valide: est_valide)
  end

  def etat_civil_demandeur_valide!(est_valide = true)
    update(etat_civil_demandeur_valid: est_valide)
  end

  def grappe_fam_valide!(est_valide = true)
    update(grappe_fam_valid: est_valide)
  end

  def valide_epouses!(est_valide = true)
    update(epouses_valide: est_valide)
  end

  def valide_enfants!(est_valide = true)
    update(enfants_valide: est_valide)
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

  def charge_second_pays_valide!(est_valide = true)
    update(charge_second_pays_valid: est_valide)
  end

  def document_valide!(est_valide = true)
    if est_valide
      return false unless required_document_uploaded?
      return false if virement? and documents.rib.empty?
    end
    update(document_valid: est_valide)
    true
  end

  def document_valid!(est_valide = true)
    if est_valide
      return false if documents.where(type_document: [:copie_cni_legalise]).empty?
      update(document_valid: est_valide)
    else
        update(document_valid: est_valide)
    end
       true
  end

  def pret_pour_soumission?
      etat_civil_demandeur_valid and 
      valide_epouses! and 
      valide_enfants! and 
      document_valid
  
  end

  def traitement_en_cours?
    self.current_state.between? :instruit, :carriere_soumis
  end

  def can_affecte_gestionnaire?
    self.current_state >= :instruit
  end

  def pret_pour_validation?
    if resident_fr?
      etat_civil_demandeur_valid and grappe_fam_valid and activite_prof_valid and assur_residence_valid and assur_second_pays_valid and charge_second_pays_valid and document_valid and recap_point_valide
    elsif resident_sn?
      etat_civil_demandeur_valid and grappe_fam_valid and assur_residence_valid and assur_second_pays_valid and charge_second_pays_valid and document_valid
    end
  end

  def affecter_allocatation?
    !affecter_allocataire.nil?
  end

  def affecter_cotisation?
    !affecter_salarie.nil?
  end

  def age_retraite
    if resident_fr?
      age = date_cess_act_sn.year - date_naissance.year
      age -= 1 if date_cess_act_sn < date_naissance + age.years
    elsif resident_sn?
      age = date_cess_act_fr.year - date_naissance.year
      age -= 1 if date_cess_act_fr < date_naissance + age.years
    end
    age
  end

  def age_ouverture_demande
    date_fin = date_soumission || Date.today
    age = date_fin.year - date_naissance.year
    age -= 1 if date_fin < date_naissance + age.years
    age
  end

  def age_ouverture_demande_en_mois
    date_fin = date_soumission || Date.today
    age = date_fin.year - date_naissance.year
    age -= 1 if date_fin < date_naissance + age.years
    age = (age / 30.437).ceil
    age
  end

  def enfants_majoration
    enfants.valide.mineurs.
        where("date_naissance <= ?", date_soumission || DateTime.now).
        order('date_naissance DESC, created_at').
        limit(3)
  end

  def taux_majoration
    nombre_enfants_mineurs = enfants.valide.mineurs.
        where("date_naissance <= ?", date_soumission || DateTime.now).count
    taux = [15, 5 * nombre_enfants_mineurs].min
    (1.0 * taux)
  end

  def taux_minoration_rc
    return 0 if retraite_normale? or retraite_anticipee_invalide?
    if retraite_anticipee_valide?
      if age_ouverture_demande_en_mois >= 12
        coefficient_minoration = 1.0 * [20, (60 - age_ouverture_demande) * 4].min
      else
        nb_mois = age_ouverture_demande_en_mois
        n_semestres = (nb_mois / 3.0).ceil
        coefficient_minoration = 1.0 * [20, n_semestres * 1.0].min
      end
      (1.0 * coefficient_minoration)
    end
  end

  def taux_minoration_rg
    return 0 if retraite_normale? or retraite_anticipee_invalide?
    if retraite_anticipee_valide?
      if age_ouverture_demande_en_mois >= 12
        coefficient_minoration = 1.0 * [25, (60 - age_ouverture_demande) * 5].min
      else
        nb_mois = age_ouverture_demande_en_mois
        n_semestres = (nb_mois / 3.0).ceil
        coefficient_minoration = 1.0 * [25, n_semestres * 1.5].min
      end
      (1.0 * coefficient_minoration)
    end
  end

  def calcul_points_regime_general
    carrieres_prestation.valide.regime_general.sum(:points)
  end

  def calcul_points_regime_cadre
    carrieres_prestation.valide.regime_cadre.sum(:points)
  end

  def calcul_points_gratuits_regime_general
    carrieres_prestation.valide.regime_general.sum(&:points_gratuits)
  end

  def calcul_points_gratuits_regime_cadre
    carrieres_prestation.valide.regime_cadre.sum(&:points_gratuits)
  end

  def calcul_points
    carrieres_prestation.valide.sum(:points)
  end

  def calcul_points_minoration_regime_general
    return 0 if retraite_normale? or retraite_anticipee_invalide?
    carrieres_prestation.valide.regime_general.map do |carriere|
      (1.0 * (carriere.points + carriere.points_gratuits) * taux_minoration_rg / 100)
    end.sum.round
  end

  def calcul_points_minoration_regime_cadre
    return 0 if retraite_normale? or retraite_anticipee_invalide?
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

  def versement_mensuel?
    return true if calcul_points_base >= 1_000
    #return true if participant.nombre_annee_cotisation >= 10
    return true if !participant.nil? && participant.nb_mois_travail >= 120
    false
  end

  def calcul_allocation_regime_general
    if versement_mensuel?
      valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_general_du(Date.today)
      (calcul_points_servis_regime_general * valeur_point_mensuelle).ceil
    else
      salaire_reference = Admin::Bareme.salaire_reference_general_du(Date.today)
      (calcul_points_base_regime_general * salaire_reference).ceil
    end
  end

  def calcul_allocation_regime_cadre
    if versement_mensuel?
      valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_cadre_du(Date.today)
      (calcul_points_servis_regime_cadre * valeur_point_mensuelle).ceil
    else
      salaire_reference = Admin::Bareme.salaire_reference_cadre_du(Date.today)
      (calcul_points_base_regime_cadre * salaire_reference).ceil
    end
  end

  def calcul_allocation
    calcul_allocation_regime_general + calcul_allocation_regime_cadre
  end

  def calcul_date_jouissance
    da = created_at || Date.today
    return (da + 1.day) if da.beginning_of_month == date_cess_act_sn.beginning_of_month
    da.beginning_of_bimester if da > date_cess_act_sn
  end

  def calcul_subvention
    35_000 - [35_000, calcul_allocation].min
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

  private

  def set_numero_affiliation!
    if resident_fr?
      self.numero_affiliation = user.numero_salarie unless user.nil?
    end
  end

  def create_carriere!
    # carrieres_prestation.destroy_all
    carrieres.each do |psrm_carriere|
      psrm_carriere.load_to_prestation
    end
  end

  def create_allocataire!
    if resident_fr? and dossier_valide? and not Allocataire.exists?(numero_allocataire: numero_affiliation)
      allocataire = Allocataire.new(
          numero_allocataire: numero_affiliation,
          nom: nom,
          prenom: prenom,
          sexe: participant.homme? ? :homme : :femme,
          date_naissance: date_naissance,
          categorie: :retraite,
          etat: :inactif,
          nombre_epouses: conjoints.valide.count,
          nombre_enfants: enfants.valide.count,
          adresse_rue: adresse_residence,
          code_pays: 'SN',

          regime: carrieres.regime_cadre.any? ? 2 : 1, # 1 : général, 2 : cadre
          age_revolu: age_ouverture_demande,

          enfant1: enfants_majoration.first,
          enfant2: enfants_majoration.second,
          enfant3: enfants_majoration.third,
          date_fin_enfant1: enfants_majoration.first.try(:date_fin_mineur),
          date_fin_enfant2: enfants_majoration.second.try(:date_fin_mineur),
          date_fin_enfant3: enfants_majoration.third.try(:date_fin_mineur),

          versement_unique: (not versement_mensuel?),
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
          montant_rappel: 0,
          montant_premier_paiement: 0,
          montant_subvention: calcul_subvention
      )

      if allocataire.save
        migrate_user_to_allocataire!
        self.allocataire = allocataire
        self.save
      end
    end
  end

  def validate_numero_affiliation
    return if numero_affiliation.nil? or numero_affiliation.empty?
    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Psrm::Participant.where(matric: numero_affiliation).exists?
  end

  def set_user!
    self.user = User.find_by(numero_salarie: numero_affiliation)
  end

  def type_retraite_validation
    return unless type_retraite

    if retraite_normale?
      if date_cess_act_sn > Date.new(2016, 07, 01)
        errors.add(:type_retraite, "Votre age de retraite (#{age_retraite} ans) ne vous permet pas d'être à la retraite normale. Il faut avoir minimum 60 ans à la retraite") if age_retraite < 60
      end
      if date_cess_act_sn < Date.new(2016, 07, 01)
        errors.add(:type_retraite, "Votre age de retraite (#{age_retraite} ans) ne vous permet pas d'être à la retraite normale. Il faut avoir minimum 55 ans à la retraite") if age_retraite < 55
      end
      return
    else
      errors.add(:type_retraite, "Vous devez choisir la retraite normale. Vous avez plus de 60 ans") and return if date_cess_act_sn > Date.new(2016, 07, 01) and age_retraite >= 60
      errors.add(:type_retraite, "Vous devez choisir la retraite normale. Vous avez plus de 55 ans") and return if date_cess_act_sn < Date.new(2016, 07, 01) and age_retraite >= 55
    end

    if retraite_anticipee_valide?
      errors.add(:type_retraite, "Votre age de retraite (#{age_retraite} ans) ne vous permet pas d'être à la retraite anticipée pour un valide. Il faut avoir minimum 55 ans à la retraite") if age_retraite < 55 and date_cess_act_sn > Date.new(2016, 07, 01)
      return
    end

    if retraite_anticipee_invalide?
      errors.add(:type_retraite, "Votre age de retraite (#{age_retraite} ans) ne vous permet pas d'être à la retraite anticipée pour un invalide. Il faut avoir minimum 55 ans à la retraite") if age_retraite < 55 and date_cess_act_sn > Date.new(2016, 07, 01)
    end
  end

  def set_numero_dossier!
    annee = Date.today.year
    #num = resident_fr? ? numero_affiliation : numero_piece
    self.numero_dossier = "E/#{numero_affiliation}/#{annee}/V"
  end
end
