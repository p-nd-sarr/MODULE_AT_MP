class RemoveMontantFromPretAllocataire < ActiveRecord::Migration[5.2]
  def change
    remove_column :pret_allocataires, :montant, :float
  end
end
