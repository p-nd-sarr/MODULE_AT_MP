class AddIndexesToDeclarationSalaireManquante < ActiveRecord::Migration[5.2]
  def change
    add_index :declaration_salaire_manquantes, :numero
    add_index :declaration_salaire_manquantes, :exercice
    add_index :declaration_salaire_manquantes, :regime
    add_index :declaration_salaire_manquantes, :code_agence
  end
end
