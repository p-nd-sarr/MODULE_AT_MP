class GenerateAllocataireFromLiquidationJob < ApplicationJob
  sidekiq_options retry: 2
  # queue_as :comptabilite

  # @param [LiquidationRetraite] liquidation_retraite
  def perform(liquidation_retraite)
    liquidation_retraite.generate_allocataire
  end
end
