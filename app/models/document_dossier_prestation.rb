class DocumentDossierPrestation < ApplicationRecord
  TYPE_DOCUMENT = {
      cni: 1,
      extrait_naissance: 2,
      certificat_mariage: 3,
      certificat_divorce: 4,
      cni_epouse: 5,
      extrait_naissance_epouse: 6
  }.freeze

  enum type_document: TYPE_DOCUMENT

  has_one_attached :document
  belongs_to :dossier_prestation

  validates :document, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :type_document, presence: true
end
