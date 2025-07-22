class CreateAtDecomptes < ActiveRecord::Migration[5.2]
  def change
    create_table :at_decomptes do |t|
      t.string :periode_indemnise
      t.integer :nombre_jour
      t.float :demi_salaire
      t.float :deux_tier_salaire
      t.float :montant
      t.date :date_validation
      t.date :date_liquidation
      t.date :date_paiement
      t.boolean :est_valide, default: :false
      t.references :arret_travail, foreign_key: true

      t.timestamps
    end
  end
end
