class AddUniqueIndexToAllocationFamiliales < ActiveRecord::Migration[5.2]
  def change
    add_index :allocation_familiales,
              [:dossier_prestation_id, :enfant_id, :trimestre, :annee],
              unique: true,
              where: "etat NOT IN (5, 6)",
              name: 'index_unique_on_allocation_familiales_except_5_and_6'
  end
end
