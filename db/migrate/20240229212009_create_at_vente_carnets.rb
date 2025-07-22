class CreateAtVenteCarnets < ActiveRecord::Migration[5.2]
  def change
    create_table :at_vente_carnets do |t|
      t.string :num_employeur
      t.string :num_recu
      t.integer :num_carnets
      t.date :date_delivrance
      t.integer :ajoute_par_id

      t.timestamps
    end
  end
end
