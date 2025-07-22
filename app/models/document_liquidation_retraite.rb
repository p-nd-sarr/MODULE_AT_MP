class DocumentLiquidationRetraite < ApplicationRecord
  TYPE_DOCUMENT = {
      cni: 1,
      # extrait_naissance: 2,
      attestation_travail: 2,
      certificat_mariage: 3,
      certificat_medical: 4,
      # cni_epouse: 5,
      # extrait_naissance_epouse: 6,
      passeport: 7,
      carte_consulaire: 8,
      rib: 9,
      certif_empl_sal: 10,
      procuration_depot_dossier: 11,
      protocole_accord_branche: 12
  }.freeze

  enum type_document: TYPE_DOCUMENT

  has_one_attached :document
  belongs_to :liquidation_retraite
  validates :document, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :type_document, presence: true
end
