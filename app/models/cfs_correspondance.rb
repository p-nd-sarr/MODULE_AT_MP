class CfsCorrespondance < ApplicationRecord
  TYPE_LETTRE = {
    rejet: 1,
    retour_cause_fnr: 2,
    retour_cause_pas_affilie: 3,
    relance: 4,
    pieces_complementaires: 5,
    validation_carriere: 6,
    notification_anomalie: 7
  }.freeze
  enum type_lettre: TYPE_LETTRE

  PROVENANCE = {
    ipres: 1,
    france: 2,
    demandeur: 3
  }.freeze
  enum provenance: PROVENANCE

  TITRE_DESTINATAIRE = {
    monsieur_destinataire: 1,
    madame_destinataire: 2
  }.freeze
  enum titre_destinataire: TITRE_DESTINATAIRE

  TITRE_DEMANDEUR = {
    monsieur_demandeur: 1,
    madame_demandeur: 2
  }.freeze
  enum titre_demandeur: TITRE_DEMANDEUR

  belongs_to :liquidation_retraite_france

  has_one_attached :lettre

  # validates :provenance
  validates :type_lettre, :numero_correspondance, :numero_reference, :objet,
            :titre_destinataire, :destinataire, :adresse_destinataire, :expediteur, :titre_demandeur,
            presence: true, if: :ipres?
  validates :nature_piece_jointe, presence: true, if: :piece_jointe?
  validates :lettre, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
end
