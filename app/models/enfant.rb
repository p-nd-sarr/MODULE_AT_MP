class Enfant < ApplicationRecord
  include Documentable
  include ::SetDate

  ETAT = {
      creation: 1,
      valide: 2,
      rejete: 3,
      deces: 4,
      soumis: 5
  }.freeze

  ORIGINE_ENFANT = {
      mariage: 1,
      adulterin: 2,
      naturel: 3,
      adoption: 4,
  }.freeze

  TYPE_PIECE = {
      extrait_naissance: 1,
      cni: 2,
      autre: 3
      #bulletin_naissance: 3
  }.freeze

  SEXE = {
    masculin: 1,
    feminin: 2,
    inconnu: 3
  }.freeze

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

  enum etat: ETAT
  enum sexe: SEXE
  enum origine_enfant: ORIGINE_ENFANT
  enum type_piece: TYPE_PIECE

  belongs_to :user, optional: true
  belongs_to :allocataire_pf, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  #belongs_to :conjoint, class_name: 'Conjoint', foreign_key: :conjoint_id, optional: true
  belongs_to :participant, :class_name => 'Psrm::Participant', foreign_key: :numero_affiliation, primary_key: :matric #, optional: true
  belongs_to :conjoint, optional: true # père ou mère
  has_many :allocation_postnatales
  has_many :allocation_familiales
  has_many :allocations_postnatales_migrees, primary_key: 'old_id'
  has_many :beneficiary_associations_to_dps
  has_one_attached :extrait_naissance
  has_many :css_fiabilisation_historics
  has_many :echeance_veuves_caisse_enfants

  validates :prenom, :nom, :date_naissance, :numero_affiliation, :origine_enfant,
            presence: true, unless: -> { incomplete? }
  validates :extrait_naissance, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, unless: -> { est_repris? }

  validate :validate_numero_affiliation, unless: -> { incomplete? }

  #validate :valider_legitimite

  validate :valider_enfant_name

  validate :valider_date_delivrance_piece, unless: -> { incomplete? }

  validate :valider_uniq_cni, on: :create

  validate :valider_num_registre_and_code_etat_civil, unless: -> { incomplete? }

  validate :valider_date_naissance_enfant, unless: -> { incomplete? }

  validate :valider_nin, unless: -> { incomplete? }

  validate :valider_legitimiter, unless: -> { incomplete? }
  #validates :numero_piece, uniqueness: true, length: { in: 13..14 }, presence: false

  before_create :set_user!

  before_save :set_numero_register

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

  def enfant_exist?
    not numero_affiliation.nil? and not numero_piece.nil? and Enfant.exists?(numero_affiliation: numero_affiliation, numero_piece: numero_piece, incomplete: false)
  end

  def can_be_completed?
    incomplete? and not numero_affiliation.nil? and not numero_affiliation.empty? and not numero_affiliation.eql?('?') and not prenom.eql?('?') and not prenom.nil? and not prenom.empty? and not nom.eql?('?') and not nom.nil? and not nom.empty? and date_naissance > Date.new(1900, 1, 1) and not inconnu?
  end

  def save_css_fiabilisation_historic
    return unless est_repris?
    enfant = Enfant.find(self.id)
    return unless enfant.incomplete?
    css_f_historic = CssFiabilisationHistoric.new
    css_f_historic.dossier = self
    css_f_historic.numero_affiliation = enfant.numero_affiliation
    css_f_historic.prenom = enfant.prenom
    css_f_historic.nom = enfant.nom
    css_f_historic.sexe = enfant.sexe
    css_f_historic.date_naissance = enfant.date_naissance
    css_f_historic.ajoute_par = User.current
    puts 'erroorrrrrr', css_f_historic.errors.full_messages unless css_f_historic.save
  end

  def turn_to_complete!(ipt = false)
    self.incomplete = ipt
    self.save(validate: false)
  end

  def document_expired_at_term?(year, trimester)
    date_ref = Date.new(year, trimester * 3, 1).end_of_month
    expired = false
    documents = Document.where(documentable: self).order(created_at: :desc).group_by(&:type_document).transform_values { |x| x.first }.values
    if documents.length == 0
      expired = true
    end
    unless documents.select { |x| x.date_expiration < date_ref }.length == 0
      expired = true
    end
    if migrated_document_exp_date? and migrated_document_exp_date >= date_ref
      expired = false
    end
    expired
  end

  def document_expired?
    expired = false
    documents = Document.where(documentable: self).order(created_at: :desc).group_by(&:type_document).transform_values { |x| x.first }.values
    if documents.length == 0
      expired = true
    end
    unless documents.select { |x| x.date_expiration < Date.today + 3.months }.length == 0
      expired = true
    end
    expired
  end

  def get_expired_documents
    documents = Document.where(documentable: self).order(created_at: :desc).group_by(&:type_document).transform_values { |x| x.first }.values
    documents = documents.select { |x| x.date_expiration < Date.today + 3.months }
  end

  def has_allocation_for_period(trimestre, annee)
    AllocationFamiliale.where(enfant_id: self.id, trimestre: trimestre, annee: annee).exists?
  end

  def document_not_added(value)
    is_added = false
    documents = Document.where(documentable: self)
    unless documents.where(type_document: value).exists?
      is_added = true
    end
    is_added
  end

  def can_be_edited?
    creation?
  end

  def full_name
    "#{prenom} #{nom}"
  end

  def eligible_for_volet_postnatale?
    3.years.ago <= date_naissance
  end

  def age
    age = Date.today.year - date_naissance.year
    age -= 1 if Date.today < date_naissance + age.years
    age
  end

  def volets_eligibles
    return {} unless valide? || deces?

    volets = {
      volet4: 4,
      volet5: 5,
      volet6: 6,
      volet7: 7,
      volet8: 8
    }

    volets.except!(:volet4) unless allocation_postnatales.volet4.existes.empty? and allocations_postnatales_migrees.where.not(enfant_id: nil).find_by(volet: 4).nil?
    volets.except!(:volet5) unless allocation_postnatales.volet5.existes.empty? and allocations_postnatales_migrees.where.not(enfant_id: nil).find_by(volet: 5).nil?
    volets.except!(:volet6) unless allocation_postnatales.volet6.existes.empty? and allocations_postnatales_migrees.where.not(enfant_id: nil).find_by(volet: 6).nil?
    volets.except!(:volet7) unless allocation_postnatales.volet7.existes.empty? and allocations_postnatales_migrees.where.not(enfant_id: nil).find_by(volet: 7).nil?
    volets.except!(:volet8) unless allocation_postnatales.volet8.existes.empty? and allocations_postnatales_migrees.where.not(enfant_id: nil).find_by(volet: 8).nil?

    # unless (date_naissance + 6.months).beginning_of_month <= Date.today and Date.today <= (date_naissance + 18.months).end_of_month
    #   volets.except!(:volet5)
    # end
    #
    # unless (date_naissance + 12.months).beginning_of_month <= Date.today and Date.today <= (date_naissance + 24.months).end_of_month
    #   volets.except!(:volet6)
    # end
    #
    # unless (date_naissance + 18.months).beginning_of_month <= Date.today and Date.today <= (date_naissance + 30.months).end_of_month
    #   volets.except!(:volet7)
    # end
    #
    # unless (date_naissance + 24.months).beginning_of_month <= Date.today and Date.today <= (date_naissance + 36.months).end_of_month
    #   volets.except!(:volet8)
    # end

    volets
  end

  def valider_legitimite
    enfant = Enfant.find_by(numero_affiliation: self.numero_affiliation)
    return if enfant.nil?

    conjoints = Conjoint.find_by(numero_affiliation: self.numero_affiliation)
    return if conjoints.nil?

    if mariage? and date_naissance? and date_naissance < conjoints.date_mariage
      errors.add(:enfant, " La date de mariage doit être antérieur à la date de naissance ")
    end
  end

  def valider_enfant_name
    salarie = Psrm::Participant.find_by(matric: self.numero_affiliation)
    return if salarie.nil?

    enfant = Enfant.find_by(numero_affiliation: self.numero_affiliation)
    return if enfant.nil?

    conjoint = Conjoint.find_by(id: self.conjoint_id)
    return if conjoint.nil?

    if salarie.homme? and self.mariage? and salarie.nom.strip.upcase != self.nom.strip.upcase
      errors.add(:enfant, "doit avoir le nom de son père")
    elsif salarie.femme? and self.mariage? and conjoint.nom.strip.upcase != self.nom.strip.upcase
      errors.add(:enfant, "doit avoir le nom de son père")
    end
  end

  def valider_date_delivrance_piece
    if date_delivrance_piece.nil? and not est_repris?
      errors.add(:base, "La date de délivrance est obligatoire.")
    end
    if date_delivrance_piece? and date_delivrance_piece > Date.today.to_date
      errors.add(:date_delivrance_piece, "La date de délivrance de la pièce ne peut être postérieur à la date du jour.")
    elsif date_naissance? and date_delivrance_piece? and date_delivrance_piece < date_naissance
      errors.add(:date_delivrance_piece, ': La date de délivrance de la pièce ne peut être antérieur à la date de naissance')
    end
  end

  def valider_num_registre_and_code_etat_civil
    if extrait_naissance? and numero_registre.nil?
      errors.add(:numero_registre, 'Le numéro de registre est obligatoire')
    elsif extrait_naissance? and code_etat_civil.length < 1
      errors.add(:numero_registre, 'Le code d\'état civile est obligatoire')
    end
  end

  def valider_uniq_cni
    if numero_piece?
      if Conjoint.all.pluck(:numero_piece).include? numero_piece
        errors.add(:numero_piece, 'NIN déja enregistré  ou conoint déja en union.')

      elsif Enfant.all.pluck(:numero_piece).include? numero_piece
        errors.add(:numero_piece, 'NIN déja enregistré. ')

      elsif AscendantsSalarie.all.pluck(:numero_piece_mere).include? numero_piece
        errors.add(:numero_piece, 'NIN déja enregistré. ')

      elsif AscendantsSalarie.all.pluck(:numero_piece_pere).include? numero_piece
        errors.add(:numero_piece, 'NIN déja enregistré. ')
      end
    end

    if extrait_naissance?
      enfants = Enfant.where(numero_registre: numero_registre, code_etat_civil: code_etat_civil)
      return if enfants.nil?
      enfants.each do |enfant|
        in_coming_enfant_year = date_transcription? ? date_transcription.year : date_naissance.year
        enfant_year = enfant.date_transcription? ? enfant.date_transcription.year : enfant.date_naissance.year
        if in_coming_enfant_year == enfant_year
          errors.add(:base, " Il existe déja un enfant enregistrer sur ce numéro de pièce.")
          return
        end
      end
    end
  end

  def valider_date_naissance_enfant
    if AllocationFamiliale.where(enfant_id: id).select { |af| af.get_end_allocation < date_naissance + 2.years }.length > 0
      errors.add(:date_naissance, ': Modification impossible : allocation(s) familiales antérieures')
    end
    if date_naissance? and date_naissance > Date.today.to_date
      errors.add(:date_naissance, ': La date de naissance ne peut être postérieur à la date du jour')
    elsif mariage? and date_naissance? and conjoint_id? and date_naissance.to_date <= conjoint.date_mariage.to_date
      errors.add(:date_naissance, ": La date de naissance ne peut être antérieure à la date de mariage des parents.")
    end
  end

  def valider_nin
    if cni?
      first_char = !numero_piece.first.match(/\A[a-zA-Z]*\z/).nil?

      if numero_piece.length < 13 || numero_piece.length > 14
        errors.add(:base, "Le NIN doit être compris entre 13 et 14 caractère")
      end

      if feminin? and numero_piece[0].to_i == 1 || first_char
        errors.add(:numero_piece, ': Le NIN doit commencer par (2) pour le genre féminin ')
      elsif masculin? and numero_piece[0].to_i == 2 || first_char
        errors.add(:numero_piece, ': Le NIN doit commencer par (1) pour le genre maculin ')
      end

    end

  end

  def set_date_expiration_piece
    return if type_piece.nil? or date_delivrance_piece.nil? or autre?
    self.date_expiration_piece = date_delivrance_piece + if cni?
                                                           10.years
                                                         elsif extrait_naissance?
                                                           3.month
                                                         elsif passeport? or carte_consulaire?
                                                           5.years
                                                         end
  end

  def set_numero_register
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

  def valider_legitimiter
    if (mariage? or adulterin?) and conjoint_id.nil?
      errors.add(:base, " Le conjoint est obligatoire.")
    end
  end

  def date_fin_mineur
    date_naissance + 21.years
  end

  # @return [Allocataire]
  def allocataire_retraire
    Allocataire.retraite.find_by("enfant1_id = ? OR enfant2_id = ? OR enfant3_id = ?", id, id, id)
  end

  def can_update?
    !(AllocationPostnatale.exists?(enfant_id: id))
  end

  def set_missed_allocations
    participant = self.participant
    dossier_prestation = participant.dossier_prestations.where(conjoint_id: nil).first
    unless dossier_prestation.nil?
      carriers = dossier_prestation.carriere_dossier_prestations.where('created_at < ?', self.created_at).select { |cr| (Date.new(cr.annee, cr.read_attribute_before_type_cast(:trimestre) * 3, 1).end_of_month + 1.year) >= Date.today }

      return if carriers.nil?

      carriers.each do |cr|
        period = set_period_for_allocation_f(cr.read_attribute_before_type_cast(:trimestre), cr.annee)
        eligible_children = participant.enfants.eligible_for_alloc_familiale(period, participant.matric)
        date = Date.new(cr.annee, cr.read_attribute_before_type_cast(:trimestre) * 3, 19)

        given_allocations = dossier_prestation.allocation_familiales.where(annee: cr.annee, trimestre: cr.trimestre)

        return if given_allocations.length >= 6

        if eligible_children.include?(self)
          allocation = AllocationFamiliale.new
          allocation.enfant_id = self.id
          allocation.dossier_prestation_id = dossier_prestation.id
          allocation.trimestre = cr.read_attribute_before_type_cast(:trimestre)
          allocation.annee = cr.annee
          allocation.date_ouverture_droit = Date.today
          allocation.ajoute_par = User.current
          allocation.etat = :creation
          allocation.date_debut_validite = date
          allocation.date_fin_validite = date.end_of_month + 1.year
          puts 'errororrr', allocation.errors.full_messages unless allocation.save
        end
      end
    end

  end

  def has_document_valid?(annee, trimestre)
    date_ref = Date.new(annee, trimestre * 3, 1).end_of_month
    is_valid = false
    documents = Document.where(documentable: self)

    if self.migrated_document_exp_date?
      is_valid = self.migrated_document_exp_date >= date_ref
    end
    if documents.where("date_expiration >= ?", date_ref).exists?
      is_valid = true
    end
    is_valid
  end

  private

  def validate_numero_affiliation
    return if numero_affiliation.nil? or numero_affiliation.empty?
    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Psrm::Participant.where(matric: numero_affiliation).exists? #or Allocataire.where(numero_allocataire: numero_affiliation).exists?
  end

  def set_user!
    self.user = User.find_by(numero_salarie: numero_affiliation)
  end
end
