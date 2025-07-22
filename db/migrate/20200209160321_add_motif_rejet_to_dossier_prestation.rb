class AddMotifRejetToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :motif_rejet, :text
    add_column :allocation_prenatales, :motif_rejet, :text
  end
end
