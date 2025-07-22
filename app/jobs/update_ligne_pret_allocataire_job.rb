class UpdateLignePretAllocataireJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :comptabilite

  # @param [PretAllocataireLigne] ligne
  def perform(ligne)
    ligne.updates_values
  end
end
