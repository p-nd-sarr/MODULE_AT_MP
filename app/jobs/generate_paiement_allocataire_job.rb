class GeneratePaiementAllocataireJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :echeance

  # @param [EcheancePaiement] echeance
  # @param [Allocataire] allocataire
  def perform(echeance, allocataire)
    echeance.generate_paiement_allocataire(allocataire)
  end
end
