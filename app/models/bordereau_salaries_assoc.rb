class BordereauSalariesAssoc < ApplicationRecord
  belongs_to :bordereau_collectif
  belongs_to :psrm_participant, :class_name => 'Psrm::Participant', foreign_key: :participant_id, primary_key: :matric
end
