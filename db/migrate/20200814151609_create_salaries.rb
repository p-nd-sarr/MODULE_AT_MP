class CreateSalaries < ActiveRecord::Migration[5.2]
  def change
    create_table :salaries do |t|

      t.string :matric, limit: 20, null: false
      t.string :nom, limit: 250
      t.string :prenom, limit: 250
      t.integer :sexe
      t.string :libelle_regime
      t.string :regime_matrimoniale
      t.string :nin

      t.references :conjoints, foreign_key: true

      t.timestamps
    end
  end
end
