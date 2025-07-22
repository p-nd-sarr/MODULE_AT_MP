class CreateRevenuConjoints < ActiveRecord::Migration[5.2]
  def change
    create_table :revenu_conjoints do |t|
      t.references :liquidation_retraite_france, foreign_key: true
      t.string :nature
      t.float :montant_trimestriel
      t.float :montant_annuel

      t.timestamps
    end
  end
end
