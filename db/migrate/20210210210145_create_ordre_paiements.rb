class CreateOrdrePaiements < ActiveRecord::Migration[5.2]
  def self.up
    create_table :ordre_paiements do |t|
      t.references :dossier, polymorphic: true, null: false
      t.references :echeance_paiement, null: true
      t.string :numero_allocataire
      t.string :numero, null: false, limit: 20

      t.timestamps
    end

    add_reference :compta_transactions, :ordre_paiement, null: true
  end

  def self.down
    drop_table :ordre_paiements
    remove_reference :compta_transactions, :ordre_paiement, null: true
  end
end
