class AddFieldDatePretAllocataireLigne < ActiveRecord::Migration[5.2]
  def change

    add_column :pret_allocataire_lignes, :verser, :boolean, :default => false

    change_column :pret_allocataire_lignes, :date_debut, :date

    remove_column :pret_allocataire_lignes, :date_fin

    add_column :pret_allocataire_lignes, :date_fin_previsionnelle, :date

  end
end
