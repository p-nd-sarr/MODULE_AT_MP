class CreateAllocationsFamilialesMigrees < ActiveRecord::Migration[5.2]
  def change
    create_table :allocations_familiales_migrees do |t|

      t.integer :enfant_id
      t.string :annee
      t.string :trimestre
      t.string :etat
      t.string :montant_liquide
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