class ValiderPaiementDossierPrestationAvisTierJob < ApplicationJob
  queue_as :default

  # @param [DossierPrestationAvisTier] dossier
  # @param [User] user
  def perform(dossier, user)
    dossier.valider_paiement(user)
  end
end
