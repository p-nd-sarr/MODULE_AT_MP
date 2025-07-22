class DonationConjoint < ApplicationRecord
  belongs_to :liquidation_retraite_france

  validates :description, :valeur_actuelle, :situation_departement, :nom_beneficiaire, :adresse_beneficiaire, :quantite, :date_donation, presence: true
end
