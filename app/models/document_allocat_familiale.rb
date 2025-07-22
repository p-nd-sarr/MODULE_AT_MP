class DocumentAllocatFamiliale < ApplicationRecord
  TYPE_DOCUMENT = {
      certificat_medicale: 1,
      certificat_scolarite: 2,
      certificat_infirmite: 3,
      certificat_apprentissage: 4
  }.freeze

  enum type_document: TYPE_DOCUMENT

  has_one_attached :document
  belongs_to :allocation_familiale

  validates :document, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :type_document, presence: true
end
