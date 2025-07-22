class AddColumnsToAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_prenatales, :date_visite, :date
    add_column :allocation_prenatales, :date_etablissement, :date
    add_column :allocation_prenatales, :date_depot, :date

    add_column :allocation_prenatales, :num_volet_generer, :string
  end
end
