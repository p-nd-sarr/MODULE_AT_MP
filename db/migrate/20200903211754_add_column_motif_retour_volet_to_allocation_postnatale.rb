class AddColumnMotifRetourVoletToAllocationPostnatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_postnatales, :motif_retour_volet, :string
  end
end
