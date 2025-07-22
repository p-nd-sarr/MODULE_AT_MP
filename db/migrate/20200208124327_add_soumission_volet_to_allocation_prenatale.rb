class AddSoumissionVoletToAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_prenatales, :soumission_volet1, :boolean
    add_column :allocation_prenatales, :soumission_volet2, :boolean
    add_column :allocation_prenatales, :soumission_volet3, :boolean
  end
end
