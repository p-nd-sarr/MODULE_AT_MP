class CreateMissingDeclarations < ActiveRecord::Migration[5.2]
  def change
    create_table :missing_declarations do |t|
      t.string :numero_ipres
      t.string :exercice
      t.string :regime
      t.string :agence_ipres
      t.string :agence_css
      t.string :versement1
      t.string :versement2
      t.string :versement3
      t.string :versement4
      t.string :date_immatriculation_css

      t.timestamps
    end
  end
end
