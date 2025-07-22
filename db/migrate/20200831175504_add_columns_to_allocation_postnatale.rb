class AddColumnsToAllocationPostnatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_postnatales, :date_visite_1, :date
    add_column :allocation_postnatales, :date_visite_2, :date
    add_column :allocation_postnatales, :date_visite_3, :date
    add_column :allocation_postnatales, :date_etablissement, :date
    add_column :allocation_postnatales, :date_depot, :date

    add_column :allocation_postnatales, :num_volet_generer, :string
  end
end
