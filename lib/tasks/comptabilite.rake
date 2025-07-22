namespace :comptabilite do
  desc "Définir le numéro d'ordre"
  task set_numero_ordre: :environment do
    OrdrePaiement.set_last_number(Date.today.strftime('%Y%m%d'))
  end
end
