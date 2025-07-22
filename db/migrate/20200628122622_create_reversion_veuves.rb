class CreateReversionVeuves < ActiveRecord::Migration[5.2]
  def change
    create_table :reversion_veuves do |t|
      t.string :workflow_state
      t.string :prenom, null: false
      t.string :nom, null: false
      t.date :date_naissance, null: false
      t.string :lieu_naissance
      t.string :numero_allocataire, null: false
      t.string :adresse
      t.integer :mode_paiement
      t.string :compte_bancaire_nom_banque
      t.string :compte_bancaire_code_banque
      t.string :compte_bancaire_code_guichet
      t.string :compte_bancaire_numero_compte
      t.string :adresse_reception_allocation

      t.timestamps
    end
  end
end
