class ValiderPaiementAtFraisEngagesJob < ApplicationJob
  queue_as :default

  # @param [AtFraisEngage] dossier
  # @param [User] user
  def perform(dossier, user)
    dossier.valider_paiements(user)
  end
end
