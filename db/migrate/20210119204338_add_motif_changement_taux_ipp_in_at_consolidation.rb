class AddMotifChangementTauxIppInAtConsolidation < ActiveRecord::Migration[5.2]
  def change
    add_column :at_consolidations, :motif_changement_taux_ipp, :string
  end
end
