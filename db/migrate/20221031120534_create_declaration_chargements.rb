class CreateDeclarationChargements < ActiveRecord::Migration[5.2]
  def change
    create_table :declaration_chargements do |t|
      t.references :declaration_salaire_manquante, foreign_key: true, index: { name: 'idx_declaration_chargements_on_declaration_salaire_manquante_id' }
      t.integer :regime
      t.string :numero_adherent
      t.string :raison_sociale
      t.integer :zone
      t.string :date_declaration
      t.integer :created_by_id
      t.integer :nombre_salaries
      t.float :total_salaries
      t.float :cotisation_dues
      t.boolean :is_valid, default: false

      t.timestamps
    end
  end
end
