class GenerateBordereauEmployeurJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :echeance

  # @param [str] base_path
  # @param [int] e_id
  def perform(base_path, e_id)
    echeance_employeur = EcheanceCaisseEmployeur.find(e_id)
    echeance_employeur.generate_bordereau_pdf(base_path)
  end
end
