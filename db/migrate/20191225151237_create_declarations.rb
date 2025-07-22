class CreateDeclarations < ActiveRecord::Migration[5.2]
  def change
    create_table :declarations do |t|
      t.date :periode
      t.integer :statut
      t.float :montant_pf
      t.float :montant_at
      t.float :montant_rg
      t.float :montant_rcc
      t.float :montant_total

      t.references :immatriculation, foreign_key: true

      t.timestamps
    end
  end
end
