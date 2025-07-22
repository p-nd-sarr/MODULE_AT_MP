class ValiderPaiementsPrestationExterieureJob < ApplicationJob
  queue_as :default

  # @param [PrestationExterieure] dossier
  # @param [User] user
  def perform(dossier, user)
    dossier.validate_payment(user)
  end
end
