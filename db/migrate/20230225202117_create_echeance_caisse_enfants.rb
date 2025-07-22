class CreateEcheanceCaisseEnfants < ActiveRecord::Migration[5.2]
  def change
    create_table :echeance_caisse_enfants do |t|
      t.references :echeance_caisse, foreign_key: true
      t.references :dossier_prestation, foreign_key: true
      t.references :echeance_caisse_dossier, foreign_key: true
      t.references :enfant, foreign_key: true
      t.integer :mois, index: true
      t.float :montant, default: 2_600
      t.boolean :valide, default: false
      t.integer :numero_ordre

      t.timestamps
    end
  end
end
