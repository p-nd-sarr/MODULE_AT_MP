class CreateEcheanceCaisseEmployeurs < ActiveRecord::Migration[5.2]
  def change
    create_table :echeance_caisse_employeurs do |t|
      t.references :echeance_caisse, foreign_key: true
      t.string :workflow_state, limit: 50
      t.string :matric, index: true
      t.string :raison_sociale
      t.string :ipres_ancien_matric, index: true
      t.string :css_ancien_matric, index: true
      t.string :code_agence_css, index: true
      t.string :code_agence_ipres, index: true
      t.string :email_mandataire
      t.string :telephone_mandataire
      t.string :prenom_mandataire
      t.string :nom_mandataire

      t.timestamps
    end
  end
end
