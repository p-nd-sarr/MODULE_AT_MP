class AddBackFieldsToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :motif_retour, :text
    add_column :allocation_familiales, :retourne_par_id, :integer
    add_column :allocation_familiales, :date_retour, :date
  end
end
