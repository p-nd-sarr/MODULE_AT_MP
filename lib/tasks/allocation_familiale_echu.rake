namespace :allocation_familiale_echue do
  desc "Supension allocation familiale à date échue"
  task suspendre_allocation: :environment do
    AllocationFamiliale.creation.where('date_fin_validite < ?', Date.today).update_all(etat: :echu, montant_paiement: 0)
  end
end
