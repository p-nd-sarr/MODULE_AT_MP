class BeneficiaryAssociationsToDp < ApplicationRecord

  TYPE_BENEFICIARY = {
    conjoint: 1,
    attributaire: 2
  }.freeze

  enum type_beneficiary: TYPE_BENEFICIARY

  belongs_to :dossier_prestation
  belongs_to :conjoint, optional: true
  belongs_to :attributaire_tierce, optional: true
  belongs_to :enfant

  validates :dossier_prestation_id, :enfant_id, :type_beneficiary, presence: true
  validates :conjoint_id, presence: true, if: :conjoint?
  validates :attributaire_tierce_id, presence: true, if: :attributaire?
  validate :association_exist

  def association_exist
    if BeneficiaryAssociationsToDp.exists?(dossier_prestation_id: self.dossier_prestation_id, conjoint_id: self.conjoint_id, enfant_id: self.enfant_id)
      errors.add(:base, "L'association existe déjà.")
    end
  end

end
