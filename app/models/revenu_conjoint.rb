class RevenuConjoint < ApplicationRecord
  belongs_to :liquidation_retraite_france

  validates :nature, :montant_trimestriel, :montant_annuel, presence: true
end
