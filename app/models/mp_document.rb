class MpDocument < ApplicationRecord
  belongs_to :maladie_professionnelle
  TYPE_DOCUMENT = {
    certificat_medical: 1,
    cni: 2,
    contrat_travail: 3
  }.freeze

  enum type_document: TYPE_DOCUMENT

  has_one_attached :document
  
  validates :document, attached: true, content_type: %w[image/png image/jpeg application/pdf]
  validates :type_document, presence: true
end
