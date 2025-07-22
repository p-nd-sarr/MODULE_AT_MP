class CreateModifierAdresse < ActiveRecord::Migration[5.2]
  def change
    create_table :modifier_adresses do |t|
      t.references :allocataire, foreign_key: true
      t.string :numero_allocataire, null: false
      t.string :prenom, null: false
      t.string :nom, null: false
      t.string :adresse_rue, limit: 250
      t.string :adresse_ville, limit: 250
      t.string :code_pays, limit: 250
      t.string :code_region, limit: 250
      t.string :code_commune, limit: 250
      t.date :date_soumission
      t.date :date_validation
      t.references :user, foreign_key: true
      t.integer :valide_par_id
      t.integer :ajoute_par_id
      t.datetime :traite_le
      t.integer :traite_par_id
      t.string :motif_rejet
      t.integer :etat, null: false, default: 1
      t.timestamps
    end
  end
end
