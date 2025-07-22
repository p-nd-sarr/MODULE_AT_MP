class CreateEcheanceVeuvesCaisseEnfants < ActiveRecord::Migration[5.2]
  def change
    create_table :echeance_veuves_caisse_enfants do |t|
      t.references :echeance_veuves_caisse, foreign_key: true, index: { name: :echeance_caisse_id }
      t.references :dossier_prestation, foreign_key: true
      t.references :echeance_veuves_caisse_epouse, foreign_key: true, index: { name: :echeance_caisse_epouse_id }
      t.references :enfant, foreign_key: true
      t.integer :mois, index: true
      t.float :montant, default: 2_600
      t.boolean :document_valide, default: false
      t.boolean :liquide, default: false
      t.integer :numero_ordre

      t.timestamps
    end
  end
end
