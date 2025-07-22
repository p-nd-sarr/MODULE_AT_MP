class Rentier < ApplicationRecord
  has_one :at_consolidation, foreign_key: :rentier_id
  has_many :enfants, foreign_key: :numero_affiliation, primary_key: :numero_rentier
  has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :numero_rentier
  scope :en_attente_validation, -> { where(etat: [:inactif]) }
  scope :en_attente_activation, -> { where(etat: [:en_attente_activation]) }

  ETAT = {
    inactif: 0,
    en_attente_activation:1,
    actif: 2,
    suspendus: 3,
    rejete: 4,
    eteint: 5,

  }.freeze

  SEXE = {
    homme: 1,
    femme: 2
  }.freeze
  enum etat: ETAT
  enum sexe: SEXE
end
