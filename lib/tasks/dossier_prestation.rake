namespace :dossier_prestation do
  desc "Cloturer les dossiers des allocataires ayant 60ans d'age"
  task cloturer_dossier: :environment do
    dossier_prestations = DossierPrestation.where("date_naissance <= ?", 61.years.ago).where.not( etat: :cloturer)
    dossier_prestations.each do |dossier_prestation|
      dossier_prestation.etat = :cloturer
      dossier_prestation.date_cloture = Date.today
      dossier_prestation.save
      puts">>>>>>>> DOSSIER SAVED"
    end
    puts">>>>>>>> FINISH"
  end

end
