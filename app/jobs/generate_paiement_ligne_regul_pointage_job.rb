class GeneratePaiementLigneRegulPointageJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :echeance

  # @param [Enrolement::RegularisationPointageLigne] ligne
  def perform(ligne)
    ligne.generate_paiement_allocataire
  end
end
