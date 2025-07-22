class AvocatsHuissier < ApplicationRecord

  TYPE_INTERVENANT = {
    avocat: 0,
    huissier: 1
  }
  enum type_intervenant: TYPE_INTERVENANT

  validates :type_intervenant, :dossier_juridique_id, :prenom, :nom, presence: true
  validates :nin, uniqueness: { message: "Le nin existe déjà" }, allow_nil: true
  validates :tel, uniqueness: { message: "Le numéro de téléphone existe déjà" }, allow_nil: true
  validates_format_of :tel, :with => /\d[0-9]\)*\z/, :message => "Seuls les nombres positifs sans espaces sont autorisés", allow_nil: true
  validate :length_of_nin

  belongs_to :dossier_juridique, foreign_key: :dossier_juridique_id
  has_many :dossier_juridique_honoraires, foreign_key: :avocats_huissier_id

  scope :avocats, -> { where(type_intervenant: :avocat) }
  scope :huissiers, -> { where(type_intervenant: :huissier) }

  def full_name
    "#{prenom} #{nom}"
  end

  def length_of_nin
    if nin?
      unless nin.to_s.length.between?(13, 14)
        errors.add(:base, "la taille du cni doit être comprise entre 13 et 14 caractères!")
      end
    end
  end

end
