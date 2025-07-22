class ValiderPaiementDossierMaterniteAvisTiersJob < ApplicationJob
  queue_as :default

  # @param [DossierMaterniteAvisTier] dossier
  # @param [User] user
  def perform(dossier, user)
    dossier.valider_paiement(user)
  end
end
