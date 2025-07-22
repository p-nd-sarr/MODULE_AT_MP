class AtDocument < ApplicationRecord
  TYPE_DOCUMENT = {
    certificat_guerison: 15,
    bulletin_de_salaire: 53
  }.freeze

  enum type_document: TYPE_DOCUMENT

  belongs_to :arret_travail, optional: true

  has_one_attached :document

  validates :document, attached: true,  content_type: ["image/png", "image/jpeg", "application/pdf"]
  validates :type_document, presence: true




  

end
