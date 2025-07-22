class AddStatutToDeclarationSalaireManquante < ActiveRecord::Migration[5.2]
  def change
    add_column :declaration_salaire_manquantes, :statut, :integer, default: 0
    add_column :declaration_chargements, :statut, :integer, default: 0
  end
end
