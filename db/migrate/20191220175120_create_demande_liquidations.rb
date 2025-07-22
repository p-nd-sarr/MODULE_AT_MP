    class CreateDemandeLiquidations < ActiveRecord::Migration[5.2]
  def change
    create_table :liquidation_retraites do |t|
      t.references :user
      t.integer :type_demande, null: false
      t.string :numero_affiliation, null: false
      t.string :prenom, null: false
      t.string :nom, null: false
      t.date :date_naissance, null: false
      t.string :lieu_naissance, null: false
      t.string :adresse_reception_allocation
      t.string :adresse_domicile
      t.integer :mode_paiement
      t.string :compte_bancaire_nom_banque
      t.string :compte_bancaire_code_banque
      t.string :compte_bancaire_code_guichet
      t.string :compte_bancaire_numero_compte
      t.integer :etat, null: false, default: 1

      t.timestamps
    end
  end
end