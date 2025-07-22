class PeriodeAssurance < ApplicationRecord
  TYPE_PERIODE = {
    pays_residence: 1,
    second_pays: 2
  }.freeze
  enum type_periode: TYPE_PERIODE

  PROVENANCE = {
    retraite: 0,
    reversion: 1
  }.freeze
  enum provenance: PROVENANCE

  belongs_to :liquidation_retraite_france, class_name: 'LiquidationRetraiteFrance', foreign_key: :liquidation_retraite_france_id, optional: true
  belongs_to :cfs_reversion_veuve, optional: true

  # validates :date_debut, :date_fin, :trimestre_assurance, :trimestre_equivalente, presence: true
end
