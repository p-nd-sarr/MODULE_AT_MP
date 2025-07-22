namespace :prestation_exterieure_caf do
  desc "Supension de dossier prestation exterieure CAF à date échue"
  task suspendre_dossier: :environment do
    prestations = PrestationExterieure.with_dossier_valide_state
    prestations.each do |prestation|
      if prestation.require_pieces_change? and prestation.is_date_echeance?
        prestation.est_dossier_suspendu!
      end
    end
  end

end
