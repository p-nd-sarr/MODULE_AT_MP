class BienPersConjoint < ApplicationRecord
  belongs_to :liquidation_retraite_france

  validates :description, :valeur_actuelle, :situation_departement, :lieu_imposition, :revenu_cadastral, presence: true
end
