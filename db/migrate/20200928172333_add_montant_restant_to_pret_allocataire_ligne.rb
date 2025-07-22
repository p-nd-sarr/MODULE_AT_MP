class AddMontantRestantToPretAllocataireLigne < ActiveRecord::Migration[5.2]
  def change
    add_column :pret_allocataire_lignes, :montant_restant, :float, null: false, default: 0
    PretAllocataireLigne.update_all("montant_restant=montant")
  end
end
