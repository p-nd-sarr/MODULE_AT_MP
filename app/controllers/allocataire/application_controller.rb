class Allocataire::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :only_allocataire!
  helper_method :current_participant

  # @return [Psrm::Participant]
  def current_participant
    current_user.participant
  end
end