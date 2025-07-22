class BaseReversion < ApplicationRecord
  include Documentable

  TYPE_DOCUMENT_OBLIGATOIRE = {
    certificat_deces: 11,
    copie_cni_legalise: 17
  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      certificat_vie_individuelle: 62,
      certificat_vie_collectif: 81,
      certificat_tutelle: 25,
      certificat_charge_entretien: 82,
      attestation_administrative: 83,
      declaration_sur_honneur: 20,
      decision_engagement: 84,
      decision_radiation: 85,
      bulletin_de_salaire: 53,
      justificatif_reversion: 92,
      contre_expertise: 96,

    }
  ).freeze

  belongs_to :allocataire,
             foreign_key: :numero_allocataire,
             primary_key: :numero_allocataire

  has_many :reversion_veuves,
           foreign_key: :numero_allocataire,
           primary_key: :numero_allocataire

  has_many :conjoints, through: :allocataire

  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true

  after_create :eteindre_allocataire

  validates :nombre_epouses_eligible, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }
  validates :nombre_enfant_eligible, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :validate_nombre_epouses_eligible!

  def nombre_veuves_can_be_eligibles
    return 0 if allocataire.versement_unique?

    date_fin = date_deces

    conjoints.map do |conjoint|
      date_debut = conjoint.date_mariage
      age = date_fin.year - date_debut.year
      age -= 1 if date_fin < date_debut + age.years
      (age >= 2) ? 1 : 0
    end.sum
  end

  def nombre_veuves_eligibles
    nombre_epouses_eligible
  end

  def nombre_orphelins_eligibles
    nombre_enfant_eligible
  end

  def part_veuves
    nombre_veuves_eligibles.zero? ? 0 : 50.0
  end

  def part_orphelins
    1.0 * [100 - part_veuves, nombre_orphelins_eligibles * 20].min
  end

  def total_parts
    reversion_veuves.map(&:part).sum.ceil(1)
  end

  def nombre_veuve_eligible_atteint?
    reversion_veuves.veuve.eligibles.count >= nombre_veuves_eligibles
  end

  def nombre_orphelins_eligible_atteint?
    reversion_veuves.orphelin.eligibles.count >= nombre_orphelins_eligibles
  end

  def pret_pour_soumission?
    required_document_uploaded?
  end

  private

  def validate_nombre_epouses_eligible!
    return if allocataire.nil?
    if allocataire.femme? and nombre_veuves_eligibles > 1
      errors.add(:nombre_veuves_eligibles, "Un allocataire femme ne peut pas avoir plus d'un veuf")
    end
  end

  def eteindre_allocataire
    allocataire.date_eteint = DateTime.now
    allocataire.eteint!
  end
end
