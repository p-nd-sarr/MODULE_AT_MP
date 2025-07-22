class AddMotifRejetToDossierJuridique < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_juridiques, :motif_rejet, :text
  end
end
