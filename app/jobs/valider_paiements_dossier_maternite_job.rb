class ValiderPaiementsDossierMaterniteJob < ApplicationJob
  queue_as :default

  # @param [DossierMaternite] dossier
  # @param [User] user
  def perform(dossier, user)
    dossier.valider_paiements(user)
  end
end
