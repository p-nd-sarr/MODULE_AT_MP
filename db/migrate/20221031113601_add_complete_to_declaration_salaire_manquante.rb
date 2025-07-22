class AddCompleteToDeclarationSalaireManquante < ActiveRecord::Migration[5.2]
  def change
    add_column :declaration_salaire_manquantes, :complete, :boolean, default: false, null: false
  end
end
