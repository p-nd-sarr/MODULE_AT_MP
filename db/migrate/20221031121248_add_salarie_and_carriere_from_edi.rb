class AddSalarieAndCarriereFromEdi < ActiveRecord::Migration[5.2]
  def change
    create_table "declaration_carrieres", force: :cascade do |t|
      t.references :declaration_chargement, foreign_key: true

      t.string "matric", limit: 20, index: true
      t.string "fhnum", limit: 20, index: true
      t.string "prenom", limit: 100
      t.string "nom", limit: 100
      t.string "fhrsoc"
      t.string "regime", limit: 5, index: true
      t.date "date_debut_contrat"
      t.date "date_fin_contrat"
      t.string "motif_sortie"
      t.date "date_debut_periode_cotisation"
      t.date "date_fin_periode_cotisation"
      t.float "total_sal_css_atmp_1"
      t.float "total_sal_css_atmp_2"
      t.float "total_sal_css_atmp_3"
      t.float "total_sal_css_pf_1"
      t.float "total_sal_css_pf_2"
      t.float "total_sal_css_pf_3"
      t.float "total_sal_ipres_rg_1"
      t.float "total_sal_ipres_rg_2"
      t.float "total_sal_ipres_rg_3"
      t.float "total_sal_ipres_rcc_1"
      t.float "total_sal_ipres_rcc_2"
      t.float "total_sal_ipres_rcc_3"
      t.string "temps_travail_1", limit: 20
      t.string "temps_travail_2", limit: 20
      t.string "temps_travail_3", limit: 20
      t.float "temps_presence_jour_1"
      t.float "temps_presence_jour_2"
      t.float "temps_presence_jour_3"
      t.float "temps_presence_heures_1"
      t.float "temps_presence_heures_2"
      t.float "temps_presence_heures_3"
      t.integer "points_rc", default: 0, null: false
      t.integer "points_rg", default: 0, null: false
    end

    create_table "declaration_participants", force: :cascade do |t|
      t.references :declaration_chargement, foreign_key: true

      t.string "matric", null: false, index: true
      t.string "ipres_ancien_matric", index: true
      t.string "css_ancien_matric", index: true
      t.string "prenom", index: true
      t.string "nom", index: true
      t.string "type_piece"
      t.string "numero_piece", index: true
      t.text "profession"
      t.string "emploi"
      t.string "regime"
      t.string "addr"
      t.string "phone"
      t.date "date_naissance"
      t.string "genre"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "id_employeur", limit: 20, index: true
      t.string "contrat_en_cours", limit: 3
      t.date "date_debut_contrat"
      t.date "date_fin_contrat"
    end
  end
end
