class CafEnfant < ApplicationRecord
  include Documentable

  SEXE = {
    inconnu: 0,
    masculin: 1,
    feminin: 2,
    sans_objet: 9
  }

  LIEN_PARENTE = {
    mariage: 1,
    adulterin: 2,
    naturel: 3,
    adoption: 4,
    not_defined1: 5
  }.freeze

  TYPE_PIECE = {
    cni: 1,
    extrait_naisance: 2,
    not_defined2: 3
  }

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

  enum lien_parente: LIEN_PARENTE
  enum type_piece: TYPE_PIECE
  enum sexe: SEXE

  scope :choosen_childreen_by_conjoint, ->(id) { where(caf_enfants: { caf_conjoint_id: id }) }
  scope :eligible_for_caf_by_period, ->(id, debut, fin) { joins(:caf_conjoint).where(caf_conjoints: { prestation_exterieure_id: id }).where('caf_enfants.date_naissance <= ? AND caf_enfants.date_naissance <= ? AND caf_enfants.active = TRUE', debut.at_end_of_month, fin).where('caf_enfants.date_naissance >= ? AND caf_enfants.date_naissance >= ?', (debut - 21.years), (fin - 21.years).at_beginning_of_month).order(:date_naissance) }
  scope :active, -> { where(active: true) }
  scope :not_active, -> { where(active: false) }

  has_many :indemnites_prestation_exterieure_assocs, dependent: :destroy

  belongs_to :caf_conjoint, class_name: 'CafConjoint', foreign_key: :caf_conjoint_id, optional: true
  belongs_to :prestation_exterieure, class_name: 'PrestationExterieure', foreign_key: :prestation_exterieure_id
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  # has_one_attached :piece_identite
  # has_one_attached :certificat_vie_collectif
  # has_one_attached :certificat_medical
  # has_one_attached :certificat_scolarite

  validates :nom, :prenom, :date_naissance, :lieu_naissance, :lien_parente, :observations, :numero_piece, :caf_conjoint_id,
            presence: true
  # validates :piece_identite, content_type: {in: 'application/pdf', message: "n'est pas un PDF"} #, attached: true
  # validates :certificat_vie_collectif, content_type: {in: 'application/pdf', message: "n'est pas un PDF"} # , attached: true
  # validates :certificat_medical, content_type: {in: 'application/pdf', message: "n'est pas un PDF"} #, attached: true
  # validates :certificat_scolarite, content_type: {in: 'application/pdf', message: "n'est pas un PDF"} #, attached: true
  validate :valider_date_naissance

  def full_name
    "#{prenom} #{nom}"
  end

  def valider_date_naissance
    if self.date_naissance < caf_conjoint.date_mariage and self.lien_parente == 'mariage'
      errors.add(:date_mariage, "la date de naissance ne peut être antérieur à la date de mariage des parents")
    end
  end

  def require_piece_change(id)
    enfant = CafEnfant.find(id)
    require_change = false
    unless (DateTime.now.beginning_of_year..DateTime.now.end_of_year).cover?(enfant.extrait_naissance.created_at)
      require_change = true
    end
    require_change
  end

  def has_document_valid?(date_ref)
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

  def has_indemnities?
    IndemnitesPrestationExterieureAssoc.where(caf_enfant_id: self.id).exists?
  end

  def activate!
    self.update_attribute(:active, true)
  end

  def deactivate!
    self.update_attribute(:active, false)
  end

end