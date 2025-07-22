class CreatePaiements < ActiveRecord::Migration[5.2]
  def change
    create_table :paiements do |t|
      t.string :reference_paiement
      t.date :date_paiement
      t.float :montant
      t.integer :mode_paiement

      t.references :factures, foreign_key: true


      t.timestamps
    end
  end
end