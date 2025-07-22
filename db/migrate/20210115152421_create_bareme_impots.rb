class CreateBaremeImpots < ActiveRecord::Migration[5.2]
  def change
    create_table :bareme_impots do |t|
      t.integer :revenu_brut
      t.integer :trimf
      t.integer :un
      t.integer :un_cinq
      t.integer :deux
      t.integer :deux_cinq
      t.integer :trois
      t.integer :trois_cinq
      t.integer :quatre
      t.integer :quatre_cinq
      t.integer :cinq

      t.timestamps
    end
  end
end
