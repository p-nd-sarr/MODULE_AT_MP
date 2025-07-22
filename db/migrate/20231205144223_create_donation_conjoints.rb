class CreateDonationConjoints < ActiveRecord::Migration[5.2]
  def change
    create_table :donation_conjoints do |t|
      t.references :liquidation_retraite_france, foreign_key: true
      t.string :description
      t.float :valeur_actuelle
      t.string :situation_departement
      t.string :nom_beneficiaire
      t.string :adresse_beneficiaire
      t.integer :quantite
      t.date :date_donation

      t.timestamps
    end
  end
end
