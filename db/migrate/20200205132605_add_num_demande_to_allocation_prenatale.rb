class AddNumDemandeToAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_prenatales, :num_demande, :string
  end
end
