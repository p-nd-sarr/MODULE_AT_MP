class AllocatairePf < ApplicationRecord

  REGIME_MAT = {
      monogame: 1,
      polygame: 2
  }.freeze

  SEXE = {
      homme: 1,
      femme: 2
  }.freeze

  enum regime_matrimoniale: REGIME_MAT

  enum sexe: SEXE

  enum mode_paiement: MODE_PAIEMENT

  has_many :enfants, foreign_key: :numero_affiliation, primary_key: :numero_allocataire
  has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :numero_allocataire
  has_many :dossier_prestations, foreign_key: :numero_affiliation, primary_key: :numero_allocataire

  validates :prenom, :nom, :date_naissance, :numero_allocataire,
            presence: true

  validates :numero_allocataire, uniqueness: {message: "Un allocataire possédant ce numéro figure dans la base." }
end
