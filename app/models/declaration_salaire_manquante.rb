class DeclarationSalaireManquante < ApplicationRecord
  STATUT = {
    manquante: 0,
    en_cours: 1,
    chargee: 2
  }.freeze

  enum statut: STATUT

  REGIME = {
    general: 1,
    cadre: 2,
    employe_de_maison: 3
  }.freeze

  enum regime: REGIME

  belongs_to :employeur, class_name: 'Psrm::Employeur',
             foreign_key: :numero,
             primary_key: :ancien_num_ipres, optional: true

  has_many :declaration_chargements

  #validates :numero, uniqueness: { scope: [:exercice, :regime], message: "déjà déclaré" }
  validates :numero, :exercice, :regime, :raison_sociale, presence: true

  scope :cadre, -> { where(regime: 2) }
  scope :general, -> { where(regime: 1) }
end
