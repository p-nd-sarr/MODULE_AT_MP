class DocumentDossierMaternite < ApplicationRecord
  TYPE_DOCUMENT = {
      cni: 1,
      demande_conges: 2,
      attestation_travail: 3,
      attestation_susp_act: 4,
      certificat_medicale_gross: 5,
      last_bul_salaire: 6
  }.freeze

  enum type_document: TYPE_DOCUMENT

  has_one_attached :document
  belongs_to :dossier_maternite

  validates :document, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :type_document, presence: true
end
