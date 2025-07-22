class RenameColumnFromCssAllocataireTransfer < ActiveRecord::Migration[5.2]
  def change
    rename_column :css_transfert_allocataires, :employeur_source, :employeur_source_id
    rename_column :css_transfert_allocataires, :employeur_destination, :employeur_destination_id
  end
end
