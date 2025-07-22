class CreateRevaloriserPensions < ActiveRecord::Migration[5.2]
  def change
    create_table :revaloriser_pensions do |t|
      t.integer :type_operation
      t.integer :type_revalorisation
      t.float :montant
      t.datetime :date_debut
      t.string :numero_allocataire

      t.timestamps
    end
  end
end
