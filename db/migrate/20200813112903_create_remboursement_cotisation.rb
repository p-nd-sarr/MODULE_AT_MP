class CreateRemboursementCotisation < ActiveRecord::Migration[5.2]
  def change
    create_table :remboursement_cotisations do |t|
      t.string "numero_affiliation", limit: 15
      t.date "date_entree"
      t.date "date_sortie"
      t.integer "type_regime_id"
      t.float "salaire"
      t.string "ref_employeur", limit: 15
      t.string "motif_rejet"
      t.integer "etat"
      t.datetime "date_traitement"
      t.integer "traite_par_id"
      t.integer "points", default: 0
      t.float "salaire1", default: 0.0
      t.float "salaire2", default: 0.0
      t.string "exercice"
      t.timestamps

    end
  end
end
