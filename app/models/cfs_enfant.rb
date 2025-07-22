class CfsEnfant < ApplicationRecord
  include Documentable
  include ::SetDate

  FILIATION = {
    direct: 1,
    indirect: 2
  }.freeze
  enum filiation: FILIATION


  ETAT = {
    creation: 1,
    valide: 2,
    rejete: 3,
    deces: 4,
    soumis: 5
  }.freeze
  enum etat: ETAT

  ORIGINE_ENFANT = {
    mariage: 1,
    adulterin: 2,
    naturel: 3,
    adoption: 4,
  }.freeze
  enum origine_enfant: ORIGINE_ENFANT

  TYPE_PIECE = {
    extrait_naissance: 1,
    cni: 2,
    autre: 3
  }.freeze
  enum type_piece: TYPE_PIECE

  SEXE = {
    masculin: 1,
    feminin: 2,
    inconnu: 3
  }.freeze
  enum sexe: SEXE

  TYPE_DOCUMENT_OBLIGATOIRE = {

  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      # certificat_medical: 19,
      certificat_scolarite: 36,
      certificat_infirmite: 66,
      certificat_apprentissage: 67,
    }
  ).freeze

  TYPE_DOCUMENT_1 = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      certificat_medical: 19,
      certificat_scolarite: 36
    }
  ).freeze


  belongs_to :liquidation_retraite_france
  belongs_to :cfs_conjoint, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  belongs_to :participant, :class_name => 'Psrm::Participant', foreign_key: :numero_affiliation, primary_key: :matric, optional: true

  has_one_attached :extrait_naissance

  validates :prenom, :nom, :date_naissance, :origine_enfant, presence: true, unless: -> { incomplete? }
  validates :extrait_naissance, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, unless: -> { est_repris? }

  # validate :validate_numero_affiliation, unless: -> { incomplete? }
  validates :date_deces, presence: true, if: :situation?


  before_create :set_user!

  before_save :set_numero_registre

  before_save :set_nin_generer, unless: :incomplete?

  before_save :set_date_expiration_piece

  after_create :set_missed_allocations

  before_save :save_css_fiabilisation_historic

  scope :not_deleted, -> { where(deleted: false) }

  scope :not_incomplete, -> { where(incomplete: false) }

  scope :mineurs, -> { where("date_naissance >= ?", 21.years.ago) }

  scope :eligible, -> { where("date_naissance >= ?", 2.years.ago) }

  scope :eligible_for_allocation_f, -> { where("date_naissance <= ? and date_naissance >= ?", 2.years.ago, 21.year.ago) }

  scope :eligible_for_allocation_f_by_period, ->(period) { where('date_naissance BETWEEN ? AND ?', period - 21.years, period - 2.years) }

  scope :non_eligible, -> { where("date_naissance >= ?", 14.years.ago) }

  scope :eligible_allocation_familiale, -> { where('date_naissance BETWEEN ? AND ?', 21.years.ago, 2.years.ago.at_beginning_of_month.next_month).where.not(conjoint: nil).not_deleted.not_incomplete }

  scope :eligible_for_alloc_familiale, ->(period, num_af) { (eligible_children.eligible_allocation_f_by_period(period).dead_children(period).not_deleted.not_incomplete) }

  scope :eligible_allocation_f_by_period, ->(period) { where('enfants.date_naissance BETWEEN ? AND ?', ((period - 3.months) - 21.years), (period - 2.years)) }

  scope :eligible_children, -> { (eligible_children_from_m_salary.or(eligible_children_from_f_salary).or(where(origine_enfant: [:mariage, :adulterin]))).joins(:participant) }

  scope :eligible_children_from_m_salary, -> { where(enfants: { origine_enfant: :naturel }).where(numero_affiliation: Conjoint.marie.pluck(:numero_affiliation)).where(psrm_participants: { genre: 'HOMME' }) }

  scope :eligible_children_from_f_salary, -> { where(enfants: { origine_enfant: :naturel }).where(psrm_participants: { genre: 'FEMME' }) }

  scope :dead_children, ->(period) { where(enfants: { date_deces: nil }).or(where('enfants.date_deces IS NOT NULL').where('enfants.date_deces >= ?', (period - 3.months))) }

  scope :eligible_plus, -> { order(:date_naissance).limit(6) }

  scope :est_cadet, -> { order('date_naissance  DESC').limit(1) }

  scope :not_chosen_yet, ->(dossier) { where.not(id: dossier.beneficiary_associations_to_dps.pluck(:enfant_id)) }


  def full_name
    "#{prenom unless prenom.nil?} #{nom unless nom.nil?}"
  end

  def set_numero_registre
    return if extrait_naissance? and numero_registre.nil?

    while numero_registre.length < 6
      self.numero_registre = '0' + self.numero_registre
    end
  end

  def set_nin_generer
    return if est_repris

    sex = self.masculin? ? 1 : 2

    annee_naissance = nil
    if date_transcription?
      annee_naissance = date_transcription.year.to_s
    else
      annee_naissance = date_naissance.year.to_s
    end
    code_etat_civil = self.code_etat_civil
    numero_registre = self.numero_registre

    if code_etat_civil.length == 1
      code_etat_civil = '00' + code_etat_civil.to_s
    elsif code_etat_civil.length == 2
      code_etat_civil = '0' + code_etat_civil.to_s
    end

    if self.extrait_naissance? and self.numero_piece != nil
      self.nin_generer = sex.to_s + ' ' + code_etat_civil + ' ' + annee_naissance + ' ' + numero_registre
    end
  end

  private

  def set_user!
    return unless liquidation_retraite_france.numero_trouve?
    self.user = User.find_by(numero_salarie: numero_affiliation)
  end
end
