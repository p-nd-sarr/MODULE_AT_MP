class CarriereDossierMaternite < ApplicationRecord
  TRIMESTRE = {
    trimestre1: 1,
    trimestre2: 2,
    trimestre3: 3,
    trimestre4: 4
}.freeze

  enum trimestre: TRIMESTRE

  belongs_to :dossier_maternite
  has_one_attached :document

  validates :document, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :trimestre, :premier_mois, :deuxiem_mois, :annee, :troisiem_mois, presence: true
end
