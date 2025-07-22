class DocumentPrestationExterieure < ApplicationRecord
  TYPE_DOCUMENT = {
      piece: 1,
      attestation_travail: 2
  }.freeze

  enum type_document: TYPE_DOCUMENT

  has_one_attached :document
  belongs_to :prestation_exterieure

  validates :document, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :type_document, presence: true
end
