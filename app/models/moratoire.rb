class Moratoire < ApplicationRecord
  TYPE_STATUT= {
      soumise: 0,
      validee: 1,
      annulee: 2
  }.freeze

  enum statut: TYPE_STATUT

  belongs_to :user
  has_many  :factures

  def description
    "#{premier_montant} #{premier_montant}"
  end
end
