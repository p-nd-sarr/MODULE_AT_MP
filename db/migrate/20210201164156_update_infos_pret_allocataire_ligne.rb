class UpdateInfosPretAllocataireLigne < ActiveRecord::Migration[5.2]
  def change
    rename_column :pret_allocataire_lignes, :verser, :est_verse
    add_column :pret_allocataire_lignes, :date_premier_prelevement, :date
    add_column :pret_allocataire_lignes, :date_dernier_prelevement, :date
    remove_column :pret_allocataire_lignes, :date_fin_previsionnelle
  end
end
