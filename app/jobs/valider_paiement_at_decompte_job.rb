class ValiderPaiementAtDecompteJob < ApplicationJob
  queue_as :default

  # @param [AtDecompte] dossier
  # @param [User] user
  def perform(dossier, user)
    dossier.valider_paiements(user)
  end
end
