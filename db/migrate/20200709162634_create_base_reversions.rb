class CreateBaseReversions < ActiveRecord::Migration[5.2]
  def change
    create_table :base_reversions do |t|
      t.string :numero_allocataire, null: false
      t.date :date_deces
      t.text :commentaire
      t.datetime :traite_le
      t.integer :traite_par_id

      t.timestamps
    end
  end
end
