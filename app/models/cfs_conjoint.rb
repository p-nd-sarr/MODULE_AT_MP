class CfsConjoint < ApplicationRecord


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
    celibataire: 1,
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
    polygame: 2,
    aucun: 3
  }.freeze
  enum regime_matrimoniale: REGIME_MATRIMONIALE

  RANG_CONJOINT = {
    premiere: 1,
    deuxieme: 2,
    troisieme: 3,
    quatrieme: 4
  }.freeze
  enum rang_conjoint: RANG_CONJOINT

  belongs_to :liquidation_retraite_france
  belongs_to :nationalite, optional: true, :class_name => 'Admin::Country', foreign_key: :nationalite_id
  belongs_to :user, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true

  has_many :cfs_enfants

  has_one_attached :piece_identite
  has_one_attached :extrait_naissance
  has_one_attached :certificat_mariage
  has_one_attached :certificat_deces
  has_one_attached :certificat_divorce

  validates :prenom, :nom, :date_naissance, :date_mariage, :etat_conjoint, :sex,
            presence: true, unless: -> { incomplete? }
  validates :piece_identite, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, attached: true
  validates :extrait_naissance, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, attached: true, unless: -> { est_repris? }
  validates :certificat_mariage, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, attached: true, unless: -> { est_repris? }

  validates :date_deces, presence: true, if: :deceder?


  # validate :validate_numero_affiliation

  # validate :valider_conjoint_etat_matrimonial, on: :create
  #
  # validate :valider_date_naissance_mariage
  #
  # validate :valider_date_delivrance_piece, unless: -> { incomplete? }
  #
  # validate :valider_uniq_cni, on: :create
  #
  # validate :valider_union_epouse, on: :create
  #
  # validate :infos_etat_civil_required, unless: -> { incomplete? }
  #
  # validate :limit_nombre_conjoint, on: :create
  #
  # validate :validate_date_mariage, unless: -> { incomplete? }
  #
  # validate :valider_date_divorce, unless: -> { incomplete? }
  #
  # validate :valider_date_deces, unless: -> { incomplete? }
  #
  # validate :valider_date_suppletif, unless: -> { incomplete? }

  before_create :set_user!

  before_save :set_date_expiration_piece

  # before_save :set_nin_generer, unless: -> { incomplete?}

  # after_save :create_salarie

  after_save :set_regime_matrimoniale

  after_destroy :set_regime_matrimoniale

  # after_save :create_conjoint_if_is_salary

  scope :premiere_date_mariage, -> { order(:date_mariage).limit(1) }
  scope :marie, -> { where(etat_conjoint: :union) }
  scope :not_deleted, -> { where(deleted: false) }
  scope :not_incomplete, -> { where(incomplete: false) }

  def full_name
    "#{prenom unless prenom.nil?} #{nom unless nom.nil?}"
  end

  def full_name_mere
    "#{prenom_mere unless prenom_mere.nil?} #{nom_mere unless nom_mere.nil?}"
  end

  def full_name_pere
    "#{prenom_pere unless prenom_pere.nil?} #{nom_pere unless nom_pere.nil?}"
  end


  def valider_conjoint_etat_matrimonial
    return unless union? and not liquidation_retraite_france.numero_trouve?

    nb_conjoints = CfsConjoint.where(numero_affiliation: liquidation_retraite_france.numero_affiliation).union.count
    return if nb_conjoints.zero?

    salarie = Psrm::Participant.find_by(matric: liquidation_retraite_france.numero_affiliation)
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

  def valider_date_naissance_mariage
    return if date_mariage.nil? or date_naissance.nil?

    if date_naissance > date_mariage
      errors.add(:conjoints, "la date de mariage ne peut être antérieur à la date de naissance")
    elsif date_mariage > Date.today
      errors.add(:base, "la date de mariage ne peut être postérieur à la date du jour")
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

  def valider_uniq_cni
    unless extrait_naissance?
      conjoints = CfsConjoint.where(numero_piece: numero_piece).pluck(:etat_conjoint)
      if conjoints.include? 'union'
        if CfsConjoint.all.pluck(:numero_piece).include? numero_piece
          errors.add(:base, 'NIN déja enregistré. ')
        end
      end
    end
  end

  def valider_union_epouse
    return unless liquidation_retraite_france.numero_trouve?

    salarie = Psrm::Participant.find_by(matric: liquidation_retraite_france.numero_affiliation)
    return if salarie.nil?

    nin = extrait_naissance? ? nin_generer : numero_piece
    conjoint_union_exist = extrait_naissance? ? CfsConjoint.union.exists?(nin_generer: nin) : CfsConjoint.union.exists?(numero_piece: numero_piece)
    conjoint_divorce_exist = extrait_naissance? ? CfsConjoint.divorcer.exists?(nin_generer: nin) : CfsConjoint.divorcer.exists?(numero_piece: numero_piece)
    conjoint_decede_exist = extrait_naissance? ? CfsConjoint.deceder.exists?(nin_generer: nin) : CfsConjoint.deceder.exists?(numero_piece: numero_piece)

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

  def limit_nombre_conjoint
    return unless liquidation_retraite_france.numero_trouve?

    nb_conjoints = CfsConjoint.where(numero_affiliation: liquidation_retraite_france.numero_affiliation).marie.count

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
      if date_etablissement_mariage > date_mariage + 185.day and date_jugement_suppletif.nil?
        errors.add(:base, "Veuillez saisir la date de jugement supplétif.")
      elsif date_etablissement_mariage > Date.today
        errors.add(:base, "La date d'établissement de mariage ne peut être postérieur à la date du jour.")
      end
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

  def set_regime_matrimoniale
    return unless liquidation_retraite_france.numero_trouve?

    conjoints = CfsConjoint.where(numero_affiliation: liquidation_retraite_france.numero_affiliation).marie
    @salarie = Salarie.find_by(matric: liquidation_retraite_france.numero_affiliation)

    unless @salarie.nil?
      if @salarie.regime_matrimoniale == 'polygame' and conjoints.size < 1
        @salarie.update_columns(regime_matrimoniale: nil)
      end
    end
  end

  def set_nin_generer
    return if est_repris

    salarie = Psrm::Participant.find_by(matric: liquidation_retraite_france.numero_affiliation)
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

  private

  def validate_numero_affiliation
    return unless liquidation_retraite_france.numero_trouve?

    mat = liquidation_retraite_france.numero_affiliation
    return if mat.nil? or mat.empty? 

    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable")
    unless Psrm::Participant.where(matric: mat).exists?
    end
  end

  # def validate_numero_affiliation
  #   # return if liquidation_retraite_france.numero_affiliation.nil? or liquidation_retraite_france.numero_affiliation.empty?
  #   errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable")
  #   # unless Psrm::Participant.where(matric: numero_affiliation).exists?
  # end
  def set_user!
    return unless liquidation_retraite_france.numero_trouve?

    self.user = User.find_by(numero_salarie: liquidation_retraite_france.numero_affiliation)
  end

  def create_salarie
    return unless liquidation_retraite_france.numero_trouve?

    matricule = liquidation_retraite_france.numero_affiliation
    salarie = Salarie.find_by(matric: matricule)

    puts "OOOOOOOOOOOOKKKKKKKKKKK LAME 222 ------------- " + matricule
    if salarie.nil?
      salarie = Salarie.new(
        matric: matricule,
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
    return unless liquidation_retraite_france.numero_trouve?

    unless numero_piece.nil?
      salary = Psrm::Participant.find_by(numero_piece: numero_piece)
    end

    return if salary.nil?

    conjoint = CfsConjoint.find_by(numero_affiliation: salary.matric)
    if conjoint.nil?
      new_conjoint = CfsConjoint.new(
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
        matric_conjoint: liquidation_retraite_france.numero_affiliation,
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


end