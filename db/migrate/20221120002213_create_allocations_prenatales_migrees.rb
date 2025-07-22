class CreateAllocationsPrenatalesMigrees < ActiveRecord::Migration[5.2]
  def change
    create_table :allocations_prenatales_migrees do |t|

      t.integer :conjoint_id
      t.string :conjoint_prenom
      t.string :conjoint_nom
      t.integer :grossesse_id
      t.integer :Volet
      t.string :etat
      t.string :montant_liquide
      t.date :date_visite
      t.date :date_creation
      t.date :date_liquidation
      t.date :date_validation
      t.date :date_paiement
      t.string :numero_liquidation
      t.string :ajoute_par
      t.integer :beneficiaire_id
      t.integer :beneficiaire_prenom
      t.integer :beneficiaire_nom

      t.timestamps
    end
  end
end