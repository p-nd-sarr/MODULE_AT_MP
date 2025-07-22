class DocumentGrappePrestation < ApplicationRecord
  TYPE_DOCUMENT = {
      certificat_deces: 1,
      certificat_divorce: 2,

  }.freeze

  enum type_document: TYPE_DOCUMENT

  has_one_attached :document
  belongs_to :UpdateGrappeFamiliale

  validates :document, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :type_document, presence: true
end
