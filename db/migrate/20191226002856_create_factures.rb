class CreateFactures < ActiveRecord::Migration[5.2]
  def change
    create_table :factures do |t|
      t.string :reference_facture
      t.date :date_facture
      t.date  :periode
      t.date :echeance
      t.float :montant
      t.float :solde

      t.references :declarations, foreign_key: true

      t.timestamps
    end
  end
end
