class RenameColumnMotifRejetToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    rename_column :allocation_familiales, :motif_rejet, :commentaire_rejet
  end
end
