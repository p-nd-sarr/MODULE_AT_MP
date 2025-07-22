class ValiderPaiementsDossierPrestationJob < ApplicationJob
  queue_as :default

  # @param [DossierPrestation] dossier
  # @param [User] user
  # @param [int] trimester
  # @param [int] year
  def perform(dossier, user, trimester = nil, year = nil)
    if dossier.suspendu? and dossier.has_maintien_prestation_active? and dossier.get_maintien_prestations_active.deces?
      dossier.valider_paiements_veuves(user)
    else
      dossier.valider_paiements(user)
    end
  end
end
