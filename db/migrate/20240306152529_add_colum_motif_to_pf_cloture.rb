class AddColumMotifToPfCloture < ActiveRecord::Migration[5.2]
  def change
    add_column :demande_pf_clotures, :motif, :integer
    add_column :demande_pf_clotures, :commentaire, :text
  end
end
