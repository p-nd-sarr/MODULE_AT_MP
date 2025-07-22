class GenerateLignePretAllocataireJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :comptabilite

  # @param [PretAllocataire] pret_allocataire
  # @param [Allocataire] allocataire
  def perform(pret_allocataire, allocataire)
    pret_allocataire.pret_allocataire_lignes.create(
      allocataire: allocataire,
      date_debut: pret_allocataire.date_debut
    )
  end
end
