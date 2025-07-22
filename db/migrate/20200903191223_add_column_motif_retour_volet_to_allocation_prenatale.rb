class AddColumnMotifRetourVoletToAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_prenatales, :motif_retour_volet, :string
  end
end
