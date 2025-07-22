class SalaryModificationHistorique < ApplicationRecord

  belongs_to :participant, :class_name => 'Psrm::Participant', foreign_key: :psrm_participant_id, primary_key: :matric
  belongs_to :user
end

