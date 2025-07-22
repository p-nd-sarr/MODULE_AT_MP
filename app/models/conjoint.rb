class Conjoint < ApplicationRecord

  after_update :set_beneficiary

  ETAT = {
    creation: 1,
    valide: 2,
    rejete: 3,
    deces: 4,
    divorce: 5,
    soumis: 6
  }.freeze

  enum etat: ETAT

  ETAT_CIVIL = {
    marie: 0,
    celibataire: 1
  }.freeze

  enum etat_civil: ETAT_CIVIL

  SEXE = {
    homme: 0,
    femme: 1
  }.freeze

  enum sex: SEXE

  TYPE_PIECE = {
    cni: 1,
    carte_consulaire: 2,
    passeport: 3,
    extrait_naissance: 4,
    autre: 5
  }.freeze

  enum type_piece: TYPE_PIECE

  ETAT_CONJOINT = {
    union: 1,
    divorcer: 2,
    deceder: 3
  }.freeze

  enum etat_conjoint: ETAT_CONJOINT

  REGIME_MATRIMONIALE = {
    monogame: 1,
    polygame: 2
  }.freeze

  enum regime_matrimoniale: REGIME_MATRIMONIALE

  RANG_CONJOINT = {
    premiere: 1,
    deuxieme: 2,
    troisieme: 3,
    quatrieme: 4
  }.freeze

  enum rang_conjoint: RANG_CONJOINT

  belongs_to :user, optional: true
  belongs_to :allocataire_pf, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  has_many :enfants
  has_many :beneficiary_associations_to_dps
  has_many :ordre_paiements, as: :beneficiaire, dependent: :destroy
  has_many :css_fiabilisation_historics
  has_one_attached :piece_identite
  has_one_attached :extrait_naissance
  has_one_attached :certificat_mariage
  has_one_attached :certificat_deces
  has_one_attached :certificat_divorce

  validates :prenom, :nom, :date_naissance, :date_mariage, :numero_affiliation, :etat_conjoint, :regime_matrimoniale, :sex,
            presence: true, unless: -> { incomplete? }
  validates :piece_identite, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, attached: true
  validates :extrait_naissance, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, attached: true, unless: -> { est_repris? }
  validates :certificat_mariage, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, attached: true, unless: -> { est_repris? }

  # validate :valider_rang_conjoint, on: :create

  validate :validate_numero_affiliation

  # validates :numero_piece, uniqueness: true, length: { in: 13..14 }, presence: false

  validate :valider_conjoint_etat_matrimonial, on: :create

  validate :valider_date_naissance_mariage

  validate :valider_date_delivrance_piece, unless: -> { incomplete? }

  validate :valider_uniq_cni, on: :create

  validate :valider_union_epouse, on: :create

  validate :infos_etat_civil_required, unless: -> { incomplete? }

  # validate :valider_nin

  validate :limit_nombre_conjoint, on: :create

  validate :validate_date_mariage, unless: -> { incomplete? }

  validate :valider_date_divorce, unless: -> { incomplete? }

  validate :valider_date_deces, unless: -> { incomplete? }

  validate :valider_date_suppletif, unless: -> { incomplete? }

  # validate :validate_date_naissance_salarie

  before_create :set_user!

  before_save :set_date_expiration_piece

  before_save :set_nin_generer, unless: :incomplete?

  after_save :create_salarie

  after_save :set_regime_matrimoniale

  after_destroy :set_regime_matrimoniale

  after_save :create_conjoint_if_is_salary

  before_save :save_css_fiabilisation_historic

  scope :premiere_date_mariage, -> { order(:date_mariage).limit(1) }
  scope :marie, -> { where(etat_conjoint: :union) }
  scope :not_deleted, -> { where(deleted: false) }
  scope :not_incomplete, -> { where(incomplete: false) }

  def conjoint_exist?
    not numero_affiliation.nil? and not numero_piece.nil? and Conjoint.exists?(numero_affiliation: numero_affiliation, numero_piece: numero_piece, incomplete: false)
  end

  def can_be_completed?
    incomplete? and not numero_affiliation.nil? and not numero_affiliation.empty? and not numero_affiliation.eql?('?') and not prenom.eql?('?') and not prenom.nil? and not prenom.empty? and not nom.eql?('?') and not nom.nil? and not nom.empty? and date_naissance > Date.new(1900, 1, 1) and date_mariage > Date.new(1900, 1, 1)
  end

  def save_css_fiabilisation_historic
    return unless est_repris?
    conjoint = Conjoint.find(self.id)
    return unless conjoint.incomplete?
    css_f_historic = CssFiabilisationHistoric.new
    css_f_historic.dossier = self
    css_f_historic.numero_affiliation = conjoint.numero_affiliation
    css_f_historic.prenom = conjoint.prenom
    css_f_historic.nom = conjoint.nom
    css_f_historic.date_naissance = conjoint.date_naissance
    css_f_historic.date_mariage = conjoint.date_mariage
    css_f_historic.ajoute_par = User.current
    puts 'erroorrrrrr', css_f_historic.errors.full_messages unless css_f_historic.save
  end

  def turn_to_complete!(ipt = false)
    self.incomplete = ipt
    self.save(validate: false)
  end

  def is_beneficiary?
    est_af_beneficiaire?
  end

  def can_be_edited?
    creation?
  end

  def full_name
    "#{prenom} #{nom}"
  end

  def decedes?
    deceder?
  end

  def valider_rang_conjoint
    salarie = Psrm::Participant.find_by(matric: numero_affiliation)
    return if salarie.nil?

    if Conjoint.union.exists?(numero_affiliation: numero_affiliation, rang_conjoint: rang_conjoint) and salarie.homme?
      errors.add(:conjoints, "Vous avez déja un conjoint pour ce rang.")
    end
  end

  def valider_conjoint_etat_matrimonial
    return unless union?

    nb_conjoints = Conjoint.where(numero_affiliation: numero_affiliation).union.count
    return if nb_conjoints.zero?

    salarie = Psrm::Participant.find_by(matric: numero_affiliation)
    return if salarie.nil?

    if salarie.femme?
      return if nb_conjoints.zero?
      errors.add(:base, "La salarié a déja 1 conjoint en union")
    end

    if monogame? and nb_conjoints >= 1
      errors.add(:base, "Il est impossible d'ajouter une nouvelle conjointe pour un salarié monogame")
    end

    if polygame? and nb_conjoints >= 4
      errors.add(:base, "Le salarié a déja 4 conjoints en union")
    end

  end

  def validate_date_naissance_salarie
    return if date_naissance_salarie.nil?
    if Date.today - date_naissance_salarie < 15.years
      errors.add(:base, "Le salarié doit avoir au moins 15 ans.")
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

  def valider_date_naissance_mariage
    return if date_mariage.nil? or date_naissance.nil?

    if date_naissance > date_mariage
      errors.add(:conjoints, "la date de mariage ne peut être antérieur à la date de naissance")
    elsif date_mariage > Date.today
      errors.add(:base, "la date de mariage ne peut être postérieur à la date du jour")
    end
  end

  def set_regime_matrimoniale
    conjoints = Conjoint.where(numero_affiliation: numero_affiliation).where(etat_conjoint: :union)

    @salarie = Salarie.find_by(matric: numero_affiliation)

    unless @salarie.nil?
      if @salarie.regime_matrimoniale == 'polygame' and conjoints.size < 1
        @salarie.update_columns(regime_matrimoniale: nil)
      end
    end
  end

  def set_nin_generer
    return if est_repris
    salarie = Psrm::Participant.find_by(matric: numero_affiliation)
    return if salarie.nil?

    code_etat_civil = self.code_etat_civil
    annee_naissance = date_naissance.year.to_s
    numero_registre = self.numero_registre.to_s

    if code_etat_civil.length == 1
      code_etat_civil = '00' + code_etat_civil.to_s
    elsif code_etat_civil.length == 2
      code_etat_civil = '0' + code_etat_civil.to_s
    end

    if salarie != nil and extrait_naissance? and homme?
      self.nin_generer = "2" + ' ' + code_etat_civil + ' ' + annee_naissance + ' ' + numero_registre
    elsif salarie != nil and extrait_naissance?
      self.nin_generer = "1" + ' ' + code_etat_civil + ' ' + annee_naissance + ' ' + numero_registre
    end

  end

  def valider_date_delivrance_piece
    if date_delivrance_piece.nil? and not est_repris?
      errors.add(:base, "La date de délivrance est obligatoire.")
    end
    if date_delivrance_piece? and date_delivrance_piece > Date.today.to_date
      errors.add(:date_delivrance_piece, "La date de délivrance piéce ne doit pas être postérieur à la date du jour. ")
    end
  end

  def valider_date_divorce
    return if date_divorce.nil?
    if date_divorce > Date.today.to_date
      errors.add(:date_divorce, "La date de divorce ne doit pas être postérieur à la date du jour. ")
    elsif date_divorce < date_mariage
      errors.add(:date_divorce, "La date de divorce piéce ne doit pas être postérieur à la date du mariage. ")
    end
  end

  def valider_date_deces
    return if date_deces.nil?
    if date_deces < date_mariage
      errors.add(:date_deces, "La date de décés ne doit pas être antérieur à la date de mariage. ")
    end
  end

  def valider_uniq_cni
    unless extrait_naissance?
      conjoints = Conjoint.where(numero_piece: numero_piece).pluck(:etat_conjoint)
      if conjoints.include? 'union'
        if Conjoint.all.pluck(:numero_piece).include? numero_piece
          errors.add(:base, 'NIN déja enregistré. ')
        end
      end

      if Enfant.all.pluck(:numero_piece).include? numero_piece
        errors.add(:base, 'NIN déja enregistré. ')

      elsif AscendantsSalarie.all.pluck(:numero_piece_mere).include? numero_piece
        errors.add(:base, 'NIN déja enregistré. ')

      elsif AscendantsSalarie.all.pluck(:numero_piece_pere).include? numero_piece
        errors.add(:base, 'NIN déja enregistré. ')
      end
    end

  end

  def valider_union_epouse
    salarie = Psrm::Participant.find_by(matric: numero_affiliation)
    return if salarie.nil?

    nin = extrait_naissance? ? nin_generer : numero_piece
    conjoint_union_exist = extrait_naissance? ? Conjoint.union.exists?(nin_generer: nin) : Conjoint.union.exists?(numero_piece: numero_piece)
    conjoint_divorce_exist = extrait_naissance? ? Conjoint.divorcer.exists?(nin_generer: nin) : Conjoint.divorcer.exists?(numero_piece: numero_piece)
    conjoint_decede_exist = extrait_naissance? ? Conjoint.deceder.exists?(nin_generer: nin) : Conjoint.deceder.exists?(numero_piece: numero_piece)

    if homme?
      if conjoint_union_exist
        errors.add(:base, 'La conjointe est déja en union')
      elsif conjoint_decede_exist
        errors.add(:base, 'La conjointe est déja déclarée décédée')
      elsif conjoint_divorce_exist and date_mariage < conjoint.date_divorce
        errors.add(:base, 'La conjointe est en union')
      end
    end
  end

  def infos_etat_civil_required
    if extrait_naissance? and numero_registre.length < 1
      errors.add(:base, 'Le numéro de registre est obligatoire')
    end
    if extrait_naissance? and code_etat_civil.length < 3
      errors.add(:base, 'Le code d\'état civile est obligatoire')
    end
  end

  def valider_nin
    salarie = Psrm::Participant.find_by(matric: numero_affiliation)
    return if salarie.nil?

    if cni?
      first_char = !numero_piece.first.match(/\A[a-zA-Z]*\z/).nil?

      if numero_piece.length < 13 || numero_piece.length > 14
        errors.add(:base, "Le NIN doit être compris entre 13 et 14 caractère")
      end

      if femme? and numero_piece[0].to_i == 1 || first_char
        errors.add(:numero_piece, ': Le NIN doit commencer par (2) pour une femme ')
      elsif homme? and numero_piece[0].to_i == 2 || first_char
        errors.add(:numero_piece, ': Le NIN doit commencer par (1) pour un homme ')
      end

    end
  end

  def limit_nombre_conjoint
    nb_conjoints = Conjoint.where(numero_affiliation: numero_affiliation).union.count

    if polygame? and union?
      if (nombre_femmes || 0) > 4
        errors.add(:base, 'le nombre maximal de conjoint autorisé est de (4).')
      elsif (nombre_femmes || 0) < 1
        errors.add(:base, 'le nombre minimal de conjoint est de (1).')
      elsif nb_conjoints >= (nombre_femmes || 0)
        errors.add(:base, 'Nombre de conjoint autorisé déja atteint.')
      end
    end

  end

  def validate_date_mariage
    unless date_etablissement_mariage.nil?
      # if date_etablissement_mariage > date_mariage + 182.day and date_jugement_suppletif.nil?
      if date_etablissement_mariage > date_mariage + 185.day and date_jugement_suppletif.nil?
        errors.add(:base, "Veuillez saisir la date de jugement supplétif.")
      elsif date_etablissement_mariage > Date.today
        errors.add(:base, "La date d'établissement de mariage ne peut être postérieur à la date du jour.")
      end
    end
  end

  def valider_date_suppletif
    return if date_jugement_suppletif.nil?
    if date_jugement_suppletif > Date.today
      errors.add(:base, "La date de jugement supplétif ne peut être postérieur à la date du jour.")
    elsif date_jugement_suppletif < date_mariage
      errors.add(:base, "La date de jugement supplétif ne doit pas être antérieur à la date du mariage.")
    elsif date_jugement_suppletif > date_etablissement_mariage
      errors.add(:base, "La date de jugement supplétif ne doit pas être antérieur à la date d'établissement du mariage.")
    end
  end

  def is_beneficiary!
    self.update_attribute(:est_af_beneficiaire, true)
    dossier_prestation = DossierPrestation.find_by_num_affiliation(numero_affiliation)
    dossier_prestation.conjoints.where.not(id: self.id).update_all(est_af_beneficiaire: false)
  end

  def is_not_beneficiary_anymore!
    self.update_attribute(:est_af_beneficiaire, false)
  end

  private

  def validate_numero_affiliation
    return if numero_affiliation.nil? or numero_affiliation.empty?
    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Psrm::Participant.where(matric: numero_affiliation).exists? # or Allocataire.where(numero_allocataire: numero_affiliation).exists?
  end

  def set_user!
    self.user = User.find_by(numero_salarie: numero_affiliation)
  end

  def create_salarie
    salarie = Salarie.find_by(matric: numero_affiliation)

    if salarie.nil?
      salarie = Salarie.new(
        matric: numero_affiliation,
        nom: nom_salarie,
        prenom: prenom_salarie,
        sexe: sex,
        regime_matrimoniale: regime_matrimoniale,
        date_naissance: date_naissance_salarie,
        nombre_femme: nombre_femmes,
        nin: nin
      )
    else
      salarie.update_columns(sexe: sex)
      salarie.update_columns(date_naissance: date_naissance_salarie)
      salarie.update_columns(nombre_femme: nombre_femmes)
      salarie.update_columns(regime_matrimoniale: regime_matrimoniale)
    end

    salarie.save
  end

  def create_conjoint_if_is_salary
    unless numero_piece.nil?
      salary = Psrm::Participant.find_by(numero_piece: numero_piece)
    end

    return if salary.nil?
    conjoint = Conjoint.find_by(numero_affiliation: salary.matric)
    if conjoint.nil?
      new_conjoint = Conjoint.new(
        numero_affiliation: salary.matric,
        prenom: prenom_salarie,
        nom: nom_salarie,
        date_naissance: date_naissance_salarie,
        date_mariage: date_mariage,
        nin: salary.numero_piece,
        etat: etat,
        est_salarie: true,
        ajoute_par: ajoute_par,
        numero_piece: nin,
        nom_salarie: salary.nom,
        prenom_salarie: salary.prenom,
        date_delivrance_piece: date_delivrance_piece_salarie,
        matric_conjoint: numero_affiliation,
        etat_conjoint: etat_conjoint,
        regime_matrimoniale: regime_matrimoniale,
        etat_civil: etat_civil,
        # rang_conjoint: self.rang_conjoint,
        date_naissance_salarie: date_naissance,
        date_etablissement_mariage: date_etablissement_mariage,
        type_piece: :cni,
        code_etat_civil: code_etat_civil,
        numero_registre: numero_registre.to_s
      )
    end
    new_conjoint.save(validate: false) unless new_conjoint.nil?
  end

  def set_beneficiary
    if est_af_beneficiaire and !union?
      is_not_beneficiary_anymore!
    end
  end
end
