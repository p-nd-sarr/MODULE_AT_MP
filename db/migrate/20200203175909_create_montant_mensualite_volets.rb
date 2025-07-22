class CreateMontantMensualiteVolets < ActiveRecord::Migration[5.2]
  def change
    create_table :montant_mensualite_volets do |t|
      t.integer :num_volet
      t.integer :montant
      t.references :allocation_prenatale, foreign_key: true
      t.date :date_changement

      t.timestamps
    end
  end
end
