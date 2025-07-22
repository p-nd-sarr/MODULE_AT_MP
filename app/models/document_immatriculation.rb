class DocumentImmatriculation < ApplicationRecord
  TYPE_DOCUMENT = {
      declaration_etablissement: 1,
      avis_immatriculation: 2,
      registre_commerce: 3,
      copie_cin_employeur: 4,
      contrats_travail: 5,
      copie_piece_employe: 6,
  }.freeze

  enum type_document: TYPE_DOCUMENT

  has_one_attached :document
  belongs_to :user
  #belongs_to :immatriculation_societe_prive

  validates :document, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :type_document, presence: true
end