class CreateEnrolementRegularisationPointageLignes < ActiveRecord::Migration[5.2]
  def change
    create_table :enrolement_regularisation_pointage_lignes do |t|
      t.references :enrolement_regularisation_pointage, foreign_key: true, index: { name: 'idx_regularisation_pointage_lignes_on_rp_id' }
      t.references :allocataire, index: { name: 'idx_regularisation_pointage_lignes_on_allocataire_id' }
      t.boolean :supprime, default: false, index: true
      t.boolean :comptabilise, default: false, index: true
      t.integer :supprime_par_id
      t.datetime :supprime_le

      t.timestamps
    end
  end
end
