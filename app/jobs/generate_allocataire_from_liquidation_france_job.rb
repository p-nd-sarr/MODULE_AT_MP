class GenerateAllocataireFromLiquidationFranceJob < ApplicationJob
  sidekiq_options retry: 2
  # queue_as :comptabilite

  # @param [LiquidationRetraiteFrance] liquidation_retraite
  def perform(liquidation_retraite)
    liquidation_retraite.generate_allocataire
  end
end
