class AddMotifRetourToEcheanceVeuve < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_veuves_caisses, :motif_retour, :text
  end
end
