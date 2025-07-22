namespace :prestations do
  desc "Génération des échéances mensuelles"
  task generate_echeances: :environment do
    date = Date.today + 1.month + 1.month # update 19/12/2023 : maintenant on lance l'échéance la nuit du 19 au 20 c'est la raison pour laquelle on ajoute 2 mois au lieu d'un
    annee = date.year
    mois = date.month

    puts "==> Génération échéance #{mois}/#{annee}"

    if EcheancePaiement.exists?(annee: annee, periode: :mensuelle, numero_periode: mois)
      puts "L'échéance de ce mois existe déjà"
    else
      EcheancePaiement.create(annee: annee, periode: :mensuelle, numero_periode: mois)
      puts "==> FIN génération échéance #{mois}/#{annee}"
    end
  end

  desc "Génération comptabilité échéances mensuelles"
  task generate_comptabilite_echeances: :environment do
    e = EcheancePaiement.with_valider_directeur_state.where(send_to_compta: false, est_repris: false).order(:created_at).first

    e.try(:generate_paiements_compta)
  end

  desc "Génération des prets des allocataires"
  task generate_lignes_prets: :environment do
    PretAllocataire.valider.each do |pret_allocataire|
      pret_allocataire.generate_lignes_prets
    end
  end

  desc "Génération d'une régularisation de pointage"
  task generate_regularisation_pointage: :environment do
    puts "==> Génération régularisation de pointage"

    if EcheancePaiement.where(est_repris: false).where.not(workflow_state: [:rejeter, :valider_directeur]).exists?
      puts "Il existe une échéance non validée"
    else
      Enrolement::RegularisationPointage.create
    end

    puts "==> FIN génération régularisation de pointage"
  end

  desc "Génération comptabilité d'une régularisation de pointage"
  task generate_comptabilite_regularisation_pointage: :environment do
    r = Enrolement::RegularisationPointage.with_valide_state.first

    r.comptabiliser! unless r.nil?
  end

  desc "Renvoie des transactions comptables non envoyées sur les 10 derniers jours"
  task resend_transactions_to_compta: :environment do
    puts "==> Renvoi des transactions comptables non envoyées"
    transactions = ComptaTransaction.where('created_at >= ?', Date.today - 10.days).
      where(can_send_to_compta: true, send_to_compta: false, echeance_paiement_id: nil)
    puts "Nombre de transactions à renvoyer : #{transactions.count}"
    transactions.each do |transaction|
      puts "Envoi de la transaction #{transaction.id} à la comptabilité"
      transaction.save
    end
  end
end
