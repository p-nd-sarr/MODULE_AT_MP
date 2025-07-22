# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_02_21_014456) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "DR", id: false, force: :cascade do |t|
    t.float "MATRIC"
    t.text "NOM"
    t.text "PRENOM"
    t.integer "AE"
    t.integer "ME"
    t.integer "JE"
    t.integer "AS"
    t.integer "MS"
    t.integer "JS"
    t.integer "ENTREP"
    t.integer "MATSOL"
    t.integer "EXER"
    t.integer "ME_1"
    t.integer "JE_1"
    t.integer "MS_1"
    t.integer "JS_1"
    t.integer "SAL1"
    t.integer "SAL2"
    t.text "MOTIF"
    t.integer "SREEL"
    t.integer "DERNIEREENTREPRISE"
    t.text "RAISONSOCIALE"
    t.text "ADRESSE"
    t.integer "TEL"
    t.integer "BP"
  end

  create_table "RETRAITE", id: false, force: :cascade do |t|
    t.float "MATRIC"
    t.text "NOM"
    t.text "PRENOM"
    t.integer "REGIM"
    t.integer "AE"
    t.integer "ME"
    t.integer "JE"
    t.integer "AS"
    t.integer "MS"
    t.integer "JS"
    t.text "MATSOL"
    t.integer "DERNIEREENTREPRISE"
    t.text "RAISONSOCIALE_1"
    t.text "ADRESSE"
    t.text "T�l�phone"
    t.text "BP"
    t.integer "ENTREP"
    t.text "RAISONSOCIALE"
    t.integer "EXER"
    t.integer "ME_1"
    t.integer "JE_1"
    t.integer "MS_1"
    t.integer "JS_1"
    t.integer "SAL1"
    t.integer "SAL2"
    t.text "MOTIF"
    t.integer "SREEL"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activity_recommandations", force: :cascade do |t|
    t.integer "ajoute_par_id"
    t.integer "affecte_a_id"
    t.integer "response_par_id"
    t.text "recommandation"
    t.text "direction_response"
    t.date "date_response"
    t.bigint "dossier_audits_id"
    t.bigint "dossier_audit_activities_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dossier_audit_activities_id"], name: "index_activity_recommandations_on_dossier_audit_activities_id"
    t.index ["dossier_audits_id"], name: "index_activity_recommandations_on_dossier_audits_id"
  end

  create_table "admin_activite_principales", force: :cascade do |t|
    t.bigint "admin_secteur_activite_id"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_secteur_activite_id"], name: "index_admin_activite_principales_on_admin_secteur_activite_id"
  end

  create_table "admin_agences", force: :cascade do |t|
    t.integer "type_agence"
    t.string "code"
    t.string "description_ebs"
    t.string "code_prest"
    t.string "description_prest"
    t.string "code_psrm"
    t.string "description_psrm"
    t.string "code_site"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_association_allocataires", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_banque_agences", force: :cascade do |t|
    t.bigint "admin_banque_id"
    t.string "nom", null: false
    t.string "code", null: false
    t.string "bank_branch_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_banque_id"], name: "index_admin_banque_agences_on_admin_banque_id"
  end

  create_table "admin_banques", force: :cascade do |t|
    t.string "code"
    t.string "nom"
    t.boolean "actif", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bank_id"
    t.string "code_swift", limit: 11
  end

  create_table "admin_bareme_pensions", force: :cascade do |t|
    t.bigint "admin_type_regime_id"
    t.date "date_debut_validite", null: false
    t.date "date_fin_validite", null: false
    t.float "valeur_point_annuelle", null: false
    t.float "valeur_point_trimestrielle"
    t.float "valeur_point_bimestrielle"
    t.float "valeur_point_mensuelle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "regime"
    t.index ["admin_type_regime_id"], name: "index_admin_bareme_pensions_on_admin_type_regime_id"
  end

  create_table "admin_baremes", force: :cascade do |t|
    t.bigint "admin_type_regime_id", null: false
    t.integer "periode", null: false
    t.float "plafond_salaire", null: false
    t.date "date_debut_validite", null: false
    t.date "date_fin_validite", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "taux_contractuel", null: false
    t.float "salaire_reference", null: false
    t.integer "regime"
    t.index ["admin_type_regime_id"], name: "index_admin_baremes_on_admin_type_regime_id"
  end

  create_table "admin_caf_baremes", force: :cascade do |t|
    t.integer "periode", null: false
    t.float "montant_indemnites", null: false
    t.date "date_debut_validite", null: false
    t.date "date_fin_validite", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_cities", force: :cascade do |t|
    t.bigint "admin_country_id", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_country_id"], name: "index_admin_cities_on_admin_country_id"
  end

  create_table "admin_communes", force: :cascade do |t|
    t.bigint "admin_ville_id"
    t.integer "code", null: false
    t.string "designation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_ville_id"], name: "index_admin_communes_on_admin_ville_id"
  end

  create_table "admin_composant_salaires", force: :cascade do |t|
    t.string "designation"
    t.string "code"
    t.boolean "prise_en_compte"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_compta_nature_prestations", force: :cascade do |t|
    t.string "code", null: false
    t.string "libelle", null: false
    t.integer "entite", null: false
    t.integer "branche", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_convention_collectives", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_countries", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "est_pays_caf"
  end

  create_table "admin_departements", force: :cascade do |t|
    t.bigint "admin_region_id"
    t.string "designation", null: false
    t.integer "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_region_id"], name: "index_admin_departements_on_admin_region_id"
  end

  create_table "admin_etablissements", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_gesadms", force: :cascade do |t|
    t.string "MATRICULE"
    t.string "PRENOM"
    t.string "NOM"
    t.string "NAISSLIEU"
    t.integer "SALAIRE"
    t.integer "COTISAT"
    t.integer "RESTE"
    t.string "NAISSMM"
    t.string "NAISSAA"
    t.integer "SEXE"
    t.integer "NATION"
    t.integer "EMPLOI"
    t.string "PECMM"
    t.string "PECAA"
    t.integer "SITUAT"
    t.integer "JJPOS"
    t.integer "CDQVNB"
    t.string "CDQWNB"
    t.string "CDDXNB"
    t.integer "CDEETAB"
    t.integer "CDECARTE"
    t.integer "CDBLNB"
    t.string "CDBKNB"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_jour_ouvrable_annuels", force: :cascade do |t|
    t.string "mois"
    t.integer "mois_en_chiffre"
    t.integer "nombre_jour_ouvrable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "annee"
  end

  create_table "admin_localite_grappes", force: :cascade do |t|
    t.integer "code_pays"
    t.integer "code_localite"
    t.string "localite"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_mandataires", force: :cascade do |t|
    t.string "prenom", null: false
    t.string "nom", null: false
    t.string "nin", null: false
    t.string "telephone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sexe"
    t.string "email"
    t.string "numero_employeur", null: false
  end

  create_table "admin_montant_mensualite_volets", force: :cascade do |t|
    t.integer "num_volet"
    t.integer "montant"
    t.date "date_changement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_motif_sorties", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_mouvement_travail_fins", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_mouvement_travails", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_professions", force: :cascade do |t|
    t.string "code", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_quartiers", force: :cascade do |t|
    t.bigint "admin_commune_id"
    t.integer "code", null: false
    t.string "designation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_commune_id"], name: "index_admin_quartiers_on_admin_commune_id"
  end

  create_table "admin_regions", force: :cascade do |t|
    t.string "designation", null: false
    t.integer "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "admin_country_id", null: false
    t.index ["admin_country_id"], name: "index_admin_regions_on_admin_country_id"
  end

  create_table "admin_rentes", force: :cascade do |t|
    t.integer "age"
    t.float "prix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_salaire_annuels", force: :cascade do |t|
    t.string "annee"
    t.float "coefficient"
    t.date "date_effet"
    t.date "date_reval"
    t.float "plancher"
    t.float "plafond"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_secteur_activites", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_sites", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_statut_juridiques", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_temps_travails", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_type_contrat_salaries", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_type_dossier_juridiques", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_type_employeurs", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_type_etablissement_diplomatiques", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_type_etablissement_publiques", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_type_etablissements", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_type_etat_civils", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_type_piece_identifications", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_type_regimes", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_type_statut_juridiques", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_villes", force: :cascade do |t|
    t.bigint "admin_departement_id"
    t.integer "code", null: false
    t.string "designation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_departement_id"], name: "index_admin_villes_on_admin_departement_id"
  end

  create_table "affectation_dossier_juridiques", force: :cascade do |t|
    t.integer "affecte_par_id"
    t.integer "affecte_a_id"
    t.date "date_affectation"
    t.bigint "dossier_juridiques_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dossier_juridiques_id"], name: "index_affectation_dossier_juridiques_on_dossier_juridiques_id"
  end

  create_table "allocataire_cnavs", force: :cascade do |t|
    t.bigint "dossier_cnav_id"
    t.date "date_import"
    t.string "numero"
    t.string "prenom"
    t.string "nom"
    t.integer "admin_region_id"
    t.integer "montant"
    t.string "origine"
    t.string "compte"
    t.date "date_soumission"
    t.date "date_validation"
    t.integer "valide_par_id"
    t.bigint "user_id"
    t.integer "ajoute_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.string "motif_rejet"
    t.boolean "paiement", default: false
    t.integer "etat"
    t.integer "mode_paiement"
    t.string "numero_liquidation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date_liquidation"
    t.integer "admin_banque_id"
    t.integer "delta"
    t.integer "valider_liq_par_id"
    t.datetime "valider_liq_le"
    t.integer "valider_insp_par_id"
    t.datetime "valider_insp_le"
    t.integer "iban"
    t.index ["dossier_cnav_id"], name: "index_allocataire_cnavs_on_dossier_cnav_id"
    t.index ["user_id"], name: "index_allocataire_cnavs_on_user_id"
  end

  create_table "allocataire_pfs", force: :cascade do |t|
    t.string "numero_allocataire", limit: 20, null: false
    t.string "nom", limit: 250
    t.string "prenom", limit: 250
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.integer "sexe"
    t.integer "regime_matrimoniale"
    t.integer "nombre_conjoint"
    t.integer "nationalite_id"
    t.integer "type_national"
    t.string "adresse"
    t.string "numero_employeur"
    t.string "adresse_employeur"
    t.integer "mode_paiement"
    t.string "telephone", limit: 30
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "est_repris", default: false, null: false
  end

  create_table "allocataire_suivi_modifications", force: :cascade do |t|
    t.bigint "allocataire_id", null: false
    t.string "dossier_revision_type"
    t.bigint "dossier_revision_id"
    t.string "commentaire", null: false
    t.datetime "date_validation", null: false
    t.boolean "impacte_montant_paiement", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allocataire_id"], name: "index_allocataire_suivi_modifications_on_allocataire_id"
    t.index ["dossier_revision_type", "dossier_revision_id"], name: "index_allocataire_suivi_modifications_on_dr_type_and_dr_id"
  end

  create_table "allocataires", force: :cascade do |t|
    t.string "numero_allocataire", limit: 20, null: false
    t.integer "categorie"
    t.string "nom", limit: 250
    t.string "prenom", limit: 250
    t.integer "sexe"
    t.integer "nationalite_id"
    t.integer "trimestre_naissance"
    t.date "date_naissance"
    t.integer "type_piece_identification_id"
    t.string "numero_identification_nationale", limit: 50
    t.string "situation_matrimoniale_code", limit: 3
    t.integer "type_etat_civil_id"
    t.integer "nombre_epouses"
    t.integer "nombre_enfants"
    t.integer "trimestre_sorti_enfant1"
    t.integer "trimestre_sorti_enfant2"
    t.integer "trimestre_sorti_enfant3"
    t.integer "nombre_enfant_veuve"
    t.string "adresse_rue", limit: 250
    t.string "adresse_ville", limit: 250
    t.string "code_pays", limit: 250
    t.string "code_region", limit: 250
    t.string "code_commune", limit: 250
    t.string "telephone", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "etat"
    t.date "date_soumission"
    t.date "date_suspension"
    t.text "motif_suspension"
    t.integer "mode_paiement", default: 4
    t.string "compte_bancaire_nom_banque"
    t.string "compte_bancaire_numero_compte", limit: 50
    t.date "date_debut_changement"
    t.integer "motif_virement"
    t.string "lieu_naissance"
    t.integer "regime_mat"
    t.integer "type_residence"
    t.string "numero_employeur"
    t.string "adress_employeur"
    t.integer "regime"
    t.integer "age_revolu", default: 0
    t.float "moyenne_rg", default: 0.0
    t.float "mois_gratuis_rg", default: 0.0
    t.float "points_rg", default: 0.0
    t.float "points_base_rg", default: 0.0
    t.float "pourcentage_minoration_rg", default: 0.0
    t.float "point_minoration_rg", default: 0.0
    t.float "pourcentage_majoration_rg", default: 0.0
    t.float "point_majoration_rg", default: 0.0
    t.float "points_complementaires_rg", default: 0.0
    t.float "points_servis_rg", default: 0.0
    t.float "montant_brut_rg", default: 0.0
    t.float "montant_imposable_rg", default: 0.0
    t.float "moyenne_rc", default: 0.0
    t.float "mois_gratuis_rc", default: 0.0
    t.float "points_rc", default: 0.0
    t.float "points_base_rc", default: 0.0
    t.float "pourcentage_minoration_rc", default: 0.0
    t.float "point_minoration_rc", default: 0.0
    t.float "pourcentage_majoration_rc", default: 0.0
    t.float "point_majoration_rc", default: 0.0
    t.float "points_complementaires_rc", default: 0.0
    t.float "points_servis_rc", default: 0.0
    t.float "montant_brut_rc", default: 0.0
    t.float "montant_imposable_rc", default: 0.0
    t.float "montant_net", default: 0.0
    t.float "montant_minimum_fiscal", default: 0.0
    t.float "montant_igr", default: 0.0
    t.float "montant_rappel", default: 0.0
    t.float "montant_premier_paiement", default: 0.0
    t.boolean "versement_unique"
    t.date "date_jouissance"
    t.float "moyenne", default: 0.0
    t.float "mois_gratuis", default: 0.0
    t.float "points", default: 0.0
    t.float "points_base", default: 0.0
    t.float "point_minoration", default: 0.0
    t.float "pourcentage_majoration", default: 0.0
    t.float "point_majoration", default: 0.0
    t.float "points_complementaires", default: 0.0
    t.float "points_servis", default: 0.0
    t.float "montant_imposable", default: 0.0
    t.float "montant_subvention", default: 0.0
    t.integer "enfant1_id"
    t.integer "enfant2_id"
    t.integer "enfant3_id"
    t.date "date_fin_enfant1"
    t.date "date_fin_enfant2"
    t.date "date_fin_enfant3"
    t.date "date_recalcul_points_majoration"
    t.string "email"
    t.datetime "date_eteint"
    t.integer "admin_banque_agence_id"
    t.string "compte_bancaire_cle_rib", limit: 2
    t.boolean "est_repris", default: false
    t.string "numero_dossier"
    t.date "date_cessation"
    t.integer "trimestre_cessation"
    t.string "old_code_banque", limit: 50
    t.string "old_compte_banque", limit: 50
    t.boolean "rappel_depose", default: false
    t.string "numero_allocataire_donneur", limit: 20
    t.string "ipres_ancien_matric"
    t.string "css_ancien_matric"
    t.datetime "date_activation_dp"
    t.datetime "date_activation_insp"
    t.string "motif_rejet"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.date "date_sortie_majoration"
    t.integer "admin_association_allocataire_id"
    t.string "adresse_domicile"
    t.string "adresse_paiement"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.datetime "date_deces"
    t.string "code_caisse_paiement", limit: 3
    t.float "old_montant_net_m1", default: 0.0
    t.float "old_montant_net_m2", default: 0.0
    t.float "old_montant_net_m3", default: 0.0
    t.float "new_montant_net_m1", default: 0.0
    t.float "new_montant_net_m2", default: 0.0
    t.float "new_montant_net_m3", default: 0.0
    t.float "diff_montant_net_m1", default: 0.0
    t.float "diff_montant_net_m2", default: 0.0
    t.float "diff_montant_net_m3", default: 0.0
    t.boolean "rappel_augmentation_envoye", default: false
    t.float "arrondi_en_cours", default: 0.0, null: false
    t.float "old_arrondi_en_cours", default: 0.0, null: false
    t.boolean "suspendu_non_pointe"
    t.index ["admin_agence_id"], name: "index_allocataires_on_admin_agence_id"
    t.index ["admin_region_id"], name: "index_allocataires_on_admin_region_id"
    t.index ["categorie"], name: "allocataires_categorie_idx"
    t.index ["css_ancien_matric"], name: "index_allocataires_on_css_ancien_matric"
    t.index ["etat"], name: "allocataires_etat_idx"
    t.index ["ipres_ancien_matric"], name: "index_allocataires_on_ipres_ancien_matric"
    t.index ["mode_paiement"], name: "allocataires_mode_paiement_idx"
    t.index ["nom"], name: "allocataires_nom_idx"
    t.index ["numero_allocataire"], name: "index_allocataires_on_numero_allocataire"
    t.index ["numero_allocataire_donneur"], name: "index_allocataires_on_numero_allocataire_donneur"
    t.index ["prenom"], name: "allocataires_prenom_idx"
    t.index ["suspendu_non_pointe"], name: "allocataires_suspendu_non_pointe_idx"
    t.index ["versement_unique"], name: "allocataires_versement_unique_idx"
  end

  create_table "allocation_familiales", force: :cascade do |t|
    t.bigint "dossier_prestation_id"
    t.bigint "enfant_id"
    t.date "date_soumission"
    t.date "date_validation"
    t.integer "valide_par_id"
    t.bigint "user_id"
    t.integer "ajoute_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.string "commentaire_rejet"
    t.integer "montant_paiement"
    t.boolean "paiement", default: false, null: false
    t.integer "etat", default: 1
    t.integer "trimestre"
    t.integer "annee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "document_valid"
    t.datetime "date_paiement"
    t.datetime "date_liquidation"
    t.integer "paiement_id"
    t.date "date_ouverture_droit"
    t.integer "motif_rejet"
    t.string "numero_liquidation_generer"
    t.bigint "ordre_paiement_id"
    t.date "date_rejet"
    t.integer "rejete_par_id"
    t.date "date_fin_validite"
    t.date "date_debut_validite"
    t.date "date_expiration_piece"
    t.boolean "est_repris", default: false, null: false
    t.boolean "en_tete_comptabilite", default: true
    t.integer "bordereau_collectif_id"
    t.integer "liquide_par_bordereau_id"
    t.integer "maintien_prestation_id"
    t.bigint "admin_agence_id"
    t.date "date_reception"
    t.text "motif_retour"
    t.integer "retourne_par_id"
    t.date "date_retour"
    t.integer "soumis_par_id"
    t.bigint "echeance_caisse_id"
    t.bigint "echeance_caisse_lot_liquidation_id"
    t.boolean "is_from_ech_paid"
    t.bigint "echeance_veuves_caisse_id"
    t.bigint "echeance_veuves_caisse_lot_liquidation_id"
    t.index ["admin_agence_id"], name: "index_allocation_familiales_on_admin_agence_id"
    t.index ["dossier_prestation_id", "enfant_id", "trimestre", "annee"], name: "index_unique_on_allocation_familiales_except_5_and_6", unique: true, where: "(etat <> ALL (ARRAY[5, 6]))"
    t.index ["dossier_prestation_id"], name: "index_allocation_familiales_on_dossier_prestation_id"
    t.index ["echeance_caisse_id"], name: "index_allocation_familiales_on_echeance_caisse_id"
    t.index ["echeance_caisse_lot_liquidation_id"], name: "echeance_lot_id"
    t.index ["echeance_veuves_caisse_id"], name: "index_allocation_familiales_on_echeance_veuves_caisse_id"
    t.index ["echeance_veuves_caisse_lot_liquidation_id"], name: "echeance_veuve_lot_id"
    t.index ["enfant_id"], name: "index_allocation_familiales_on_enfant_id"
    t.index ["ordre_paiement_id"], name: "index_allocation_familiales_on_ordre_paiement_id"
    t.index ["user_id"], name: "index_allocation_familiales_on_user_id"
  end

  create_table "allocation_postnatales", force: :cascade do |t|
    t.bigint "dossier_prestation_id"
    t.date "date_accouchement"
    t.integer "volet"
    t.text "commentaire"
    t.date "date_soumission"
    t.date "date_validation"
    t.integer "valide_par_id"
    t.bigint "user_id"
    t.integer "ajoute_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.string "motif_rejet"
    t.integer "montant_paiement"
    t.boolean "paiement", default: false, null: false
    t.integer "etat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "enfant_id"
    t.datetime "date_paiement"
    t.datetime "date_liquidation"
    t.integer "paiement_id"
    t.date "date_visite_1"
    t.date "date_visite_2"
    t.date "date_visite_3"
    t.date "date_etablissement"
    t.date "date_depot"
    t.string "num_volet_generer"
    t.string "motif_retour_volet"
    t.bigint "ordre_paiement_id"
    t.date "date_reception"
    t.date "date_enregistrement"
    t.boolean "est_repris", default: false, null: false
    t.boolean "en_tete_comptabilite", default: true
    t.integer "retourne_par_id"
    t.date "date_retour"
    t.index ["dossier_prestation_id"], name: "index_allocation_postnatales_on_dossier_prestation_id"
    t.index ["ordre_paiement_id"], name: "index_allocation_postnatales_on_ordre_paiement_id"
    t.index ["user_id"], name: "index_allocation_postnatales_on_user_id"
  end

  create_table "allocation_prenatales", force: :cascade do |t|
    t.bigint "dossier_prestation_id"
    t.integer "volet"
    t.text "commentaire"
    t.date "date_soumission"
    t.date "date_validation"
    t.integer "traite_par_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "etat", default: 1
    t.boolean "paiement", default: false, null: false
    t.integer "montant_paiement"
    t.text "motif_rejet"
    t.datetime "traite_le"
    t.integer "ajoute_par_id"
    t.datetime "date_paiement"
    t.datetime "date_liquidation"
    t.bigint "grossesse_id"
    t.integer "paiement_id"
    t.date "date_visite"
    t.date "date_etablissement"
    t.date "date_depot"
    t.string "num_volet_generer"
    t.string "motif_retour_volet"
    t.date "date_rejet"
    t.bigint "ordre_paiement_id"
    t.date "date_reception"
    t.boolean "est_repris", default: false, null: false
    t.boolean "en_tete_comptabilite", default: true
    t.index ["dossier_prestation_id"], name: "index_allocation_prenatales_on_dossier_prestation_id"
    t.index ["grossesse_id"], name: "index_allocation_prenatales_on_grossesse_id"
    t.index ["ordre_paiement_id"], name: "index_allocation_prenatales_on_ordre_paiement_id"
    t.index ["user_id"], name: "index_allocation_prenatales_on_user_id"
  end

  create_table "allocations_familiales_migrees", force: :cascade do |t|
    t.integer "enfant_id"
    t.string "annee"
    t.string "trimestre"
    t.string "etat"
    t.string "montant_liquide"
    t.date "date_creation"
    t.date "date_liquidation"
    t.date "date_validation"
    t.date "date_paiement"
    t.string "numero_liquidation"
    t.string "ajoute_par"
    t.string "beneficiaire_id"
    t.string "beneficiaire_prenom"
    t.string "beneficiaire_nom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dossier_prestation_id"
    t.string "enfant_nom"
    t.string "enfant_prenom"
    t.integer "reprise_site"
    t.index ["dossier_prestation_id"], name: "index_allocations_familiales_migrees_on_dossier_prestation_id"
  end

  create_table "allocations_postnatales_migrees", force: :cascade do |t|
    t.integer "conjoint_id"
    t.string "conjoint_prenom"
    t.string "conjoint_nom"
    t.integer "enfant_id"
    t.string "enfant_prenom"
    t.string "enfant_nom"
    t.integer "volet"
    t.string "etat"
    t.string "montant_liquide"
    t.date "date_visite_1"
    t.date "date_visite_2"
    t.date "date_visite_3"
    t.date "date_creation"
    t.date "date_liquidation"
    t.date "date_validation"
    t.date "date_paiement"
    t.string "numero_liquidation"
    t.string "ajoute_par"
    t.string "beneficiaire_id"
    t.string "beneficiaire_prenom"
    t.string "beneficiaire_nom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dossier_prestation_id"
    t.index ["dossier_prestation_id"], name: "index_allocations_postnatales_migrees_on_dossier_prestation_id"
  end

  create_table "allocations_prenatales_migrees", force: :cascade do |t|
    t.integer "conjoint_id"
    t.string "conjoint_prenom"
    t.string "conjoint_nom"
    t.integer "grossesse_id"
    t.integer "volet"
    t.string "etat"
    t.string "montant_liquide"
    t.date "date_visite"
    t.date "date_creation"
    t.date "date_liquidation"
    t.date "date_validation"
    t.date "date_paiement"
    t.string "numero_liquidation"
    t.string "ajoute_par"
    t.string "beneficiaire_id"
    t.string "beneficiaire_prenom"
    t.string "beneficiaire_nom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dossier_prestation_id"
    t.index ["dossier_prestation_id"], name: "index_allocations_prenatales_migrees_on_dossier_prestation_id"
  end

  create_table "arret_travails", force: :cascade do |t|
    t.string "raison_sociale_employeur"
    t.string "numero_employeur"
    t.string "adresse_employeur"
    t.string "boite_postale_employeur"
    t.string "email_employeur"
    t.string "telephone_employeur"
    t.string "fax_employeur"
    t.string "activite_principale_entreprise"
    t.string "nin_salarie"
    t.string "numero_affiliation"
    t.string "carnet_accident_travail"
    t.string "prenom_salarie"
    t.string "nom_salarie"
    t.date "date_de_naissance_salarie"
    t.integer "situation_matrimoniale_salarie"
    t.integer "nationalite_salarie"
    t.string "adresse_domiciliaire_salarie"
    t.string "telephone_salarie"
    t.integer "qualification_professionnelle_salarie"
    t.date "date_embauche_salarie"
    t.integer "anciennete_salarie"
    t.integer "type_de_contrat_travail_salarie"
    t.string "nature_du_travail_au_moment_accident"
    t.boolean "infirmite_anterieure_accident"
    t.float "taux_infirmite_anterieure_accident"
    t.string "numero_rente_infirmite_anterieure_accident"
    t.datetime "date_accident"
    t.integer "nombre_hr_entre_accident_et_prise_travail"
    t.integer "lieu_accident"
    t.boolean "accident_mortel"
    t.datetime "debut_arret_travail"
    t.integer "agent_materiel"
    t.string "code_agent_materiel"
    t.text "cause_circonstances_acccident"
    t.boolean "avec_constat"
    t.string "detail_constat"
    t.boolean "avec_temoin"
    t.string "nom_temoin"
    t.string "adresse_temoin"
    t.boolean "personne_avisee"
    t.string "nom_personne_avisee"
    t.string "adresse_personne_avisee"
    t.string "personne_avisee_quand"
    t.string "personne_avisee_par_qui"
    t.boolean "accident_cause_par_tiers"
    t.string "prenom_tiers"
    t.string "nom_tiers"
    t.string "adresse_tiers"
    t.string "prenom_civilement_responsable"
    t.string "nom_civilement_responsable"
    t.string "adresse_civilement_responsable"
    t.boolean "salaire_verse_en_totalite_en_at"
    t.datetime "date_declaration"
    t.string "nom_declarant"
    t.string "prenom_declarant"
    t.string "lieu_declaration"
    t.integer "etat"
    t.boolean "est_ipp"
    t.float "taux_ipp"
    t.float "taux_itt"
    t.boolean "info_salarie_valid", default: false
    t.boolean "info_employeur_valid", default: false
    t.boolean "detail_accident_valid", default: false
    t.boolean "document_valid", default: false
    t.boolean "frais_indemnité_valid", default: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "numero_ipress_css_salarie"
    t.string "dossier_initial_salarie"
    t.date "date_rechute_salarie"
    t.float "salaire_du_jour"
    t.float "salaire_du_mois"
    t.string "numero_unique_ipress_css_employeur"
    t.string "ancien_numero_ipress_employeur"
    t.string "ancien_numero_css_employeur"
    t.string "status_ipress"
    t.string "status_css"
    t.string "status_ipress_css"
    t.float "solde_total_ipress_css"
    t.float "solde_branche_vieillesse"
    t.float "solde_branche_at"
    t.float "solde_branche_pf"
    t.string "agence_gestion_ipress"
    t.string "agence_gestion_css"
    t.float "taux_at"
    t.float "taux_pf"
    t.integer "nature_accident"
    t.integer "declarant"
    t.string "num_dossier"
    t.boolean "deleted"
    t.boolean "est_journalier", default: false
    t.string "affecte_a"
    t.integer "affectation_type"
    t.boolean "dprp_obligatoire", default: false
    t.integer "sexe"
    t.string "lieu_de_naissance"
    t.string "telephone"
    t.string "adresse"
    t.string "email"
    t.string "nationalite"
    t.integer "type_de_piece"
    t.integer "type_declaration"
    t.string "adresse_declarant"
    t.string "telephone_declarant"
    t.integer "consequence_accident_travail"
    t.date "date_du_deces"
    t.string "raison_absence_constat"
    t.string "raison_sociale_assureur"
    t.string "nom_assureur"
    t.string "adresse_assureur"
    t.string "numero_police_assurance"
    t.integer "incapacite_permanente"
    t.text "visible_for"
    t.boolean "creer_par_ag_direction_at", default: false
    t.boolean "medecin_conseil_obligatoire", default: false
    t.string "qualite_declarant"
    t.string "workflow_state"
    t.integer "soumis_par"
    t.datetime "date_soumission"
    t.string "motif"
    t.integer "instruit_par_id"
    t.datetime "instruit_le"
    t.datetime "valider_le"
    t.integer "valider_par_id"
    t.integer "traite_par_id"
    t.datetime "traite_le"
    t.integer "affectation_at"
    t.datetime "affectation_date"
    t.integer "ajoute_par_id"
    t.string "decision_commission_rejet"
    t.datetime "date_cloture_dossier"
    t.datetime "date_reouverture_dossier"
    t.integer "cloture_soumise_par"
    t.integer "reouverture_soumise_par"
    t.boolean "is_subrogation", default: false
    t.boolean "active_enquete_dprp", default: false
    t.boolean "active_avis_medecin", default: false
    t.string "desc_dprp"
    t.string "desc_medecin"
    t.datetime "date_soumission_redacteur"
    t.datetime "date_soumission_dajc"
    t.datetime "date_soumission_dir_at"
    t.datetime "date_acceptation"
    t.datetime "date_soumission_comite"
    t.datetime "date_rejet_dossier"
    t.datetime "date_soumission_chef_service"
    t.datetime "date_soumission_chef_agence"
    t.datetime "date_affectation_redacteur"
    t.datetime "date_affectation_tech"
    t.integer "accepte_par"
    t.integer "rejete_par"
    t.integer "soumis_chef_div_at_par"
    t.integer "soumis_chef_agence_par"
    t.integer "affecter_redacteur_par"
    t.integer "affecter_tech_par"
    t.integer "nombre_jour"
    t.integer "soumis_dir_at_par"
    t.boolean "has_numero_affiliation", default: true
    t.string "numero_temporaire"
    t.datetime "date_soumission_avis_medecin"
    t.datetime "date_soumission_avis_dprp"
    t.datetime "date_soumission_avis_chef_service"
    t.datetime "date_annulation_guerison"
    t.string "motif_annulation_guerison"
    t.string "personne_avisee_qualite"
    t.date "date_reception"
    t.boolean "info_pro_salarie_valid", default: false
    t.boolean "est_repris", default: false
    t.bigint "admin_agence_id"
    t.string "no_sinistre"
    t.integer "nombre_heure_paye"
    t.index ["admin_agence_id"], name: "index_arret_travails_on_admin_agence_id"
    t.index ["user_id"], name: "index_arret_travails_on_user_id"
  end

  create_table "ascendants_salaries", force: :cascade do |t|
    t.bigint "user_id"
    t.string "numero_affiliation", null: false
    t.string "nom_salarie", null: false
    t.string "prenom_salarie", null: false
    t.string "prenom_mere", null: false
    t.string "nom_mere", null: false
    t.date "date_naissance_mere", null: false
    t.string "numero_piece_mere"
    t.integer "type_piece_mere"
    t.string "prenom_pere", null: false
    t.string "nom_pere", null: false
    t.date "date_naissance_pere", null: false
    t.string "numero_piece_pere"
    t.integer "type_piece_pere"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_naissance_salarie"
    t.index ["user_id"], name: "index_ascendants_salaries_on_user_id"
  end

  create_table "at_avis", force: :cascade do |t|
    t.text "description"
    t.string "fait_par"
    t.string "fait_par_profil"
    t.bigint "arret_travail_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "est_valide", default: false
    t.integer "avis", default: 1
    t.index ["arret_travail_id"], name: "index_at_avis_on_arret_travail_id"
  end

  create_table "at_base_reversion_rentes", force: :cascade do |t|
    t.bigint "arret_travail_id"
    t.string "numero_affiliation", null: false
    t.date "date_deces"
    t.string "workflow_state"
    t.string "string"
    t.string "num_dossier"
    t.integer "soumis_par"
    t.date "date_soumission"
    t.integer "ajoute_par"
    t.date "ajouter_le"
    t.string "conjoints_id", default: [], array: true
    t.string "enfants_id", default: [], array: true
    t.string "ascendants_pere_id", default: [], array: true
    t.string "ascendants_mere_id", default: [], array: true
    t.boolean "info_reversion", default: false
    t.boolean "documents_valide", default: false
    t.boolean "boolean", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arret_travail_id"], name: "index_at_base_reversion_rentes_on_arret_travail_id"
  end

  create_table "at_carnets", force: :cascade do |t|
    t.string "numero_carnet"
    t.integer "arret_travail_id"
    t.string "numero_employeur"
    t.string "raison_sociale"
    t.datetime "date_achat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "est_repris", default: false
    t.string "no_sinistre"
  end

  create_table "at_code_prime_salaires", force: :cascade do |t|
    t.string "designation"
    t.string "code"
    t.boolean "prise_en_compte"
    t.float "montant"
    t.bigint "arret_travail_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "at_consolidation_id_id"
    t.bigint "at_rente_familles_id_id"
    t.integer "at_rechute_id"
    t.boolean "est_repris", default: false
    t.string "no_sinistre"
    t.index ["arret_travail_id"], name: "index_at_code_prime_salaires_on_arret_travail_id"
    t.index ["at_consolidation_id_id"], name: "index_at_code_prime_salaires_on_at_consolidation_id_id"
    t.index ["at_rente_familles_id_id"], name: "index_at_code_prime_salaires_on_at_rente_familles_id_id"
  end

  create_table "at_consolidations", force: :cascade do |t|
    t.string "email"
    t.string "workflow_state"
    t.string "string"
    t.integer "soumis_par"
    t.string "integer"
    t.date "date_soumission"
    t.string "datetime"
    t.string "num_dossier"
    t.text "motif"
    t.boolean "information_consolidation_valide", default: false
    t.boolean "documents_valide", default: false
    t.boolean "boolean", default: false
    t.integer "ajoute_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "arret_travail_id"
    t.boolean "tableau_rente_valide", default: false
    t.boolean "information_salaire_valide", default: false
    t.string "motif_changement_taux_ipp"
    t.integer "taux_ipp_mc"
    t.string "avis_mc"
    t.datetime "date_validation_mc"
    t.datetime "date_validation_chef_service"
    t.datetime "date_soumission_chef_agence"
    t.datetime "date_soumission_tech"
    t.datetime "date_soumission_chef_service"
    t.boolean "decision_mc_valide", default: false
    t.datetime "date_affectation_technicien"
    t.integer "affectation_technicien"
    t.datetime "date_verification"
    t.datetime "date_validation_chef_agence"
    t.datetime "date_validation_directeur_at"
    t.datetime "date_validation_audit"
    t.datetime "date_validation_directeur_general"
    t.integer "taux_ipp_medecin_expert"
    t.integer "rentier_id"
    t.boolean "creer_en_agence", default: true
    t.datetime "date_consolidation_medecin_conseil"
    t.datetime "date_consolidation_medecin_expert"
    t.datetime "date_consolidation_medecin_traitant"
    t.float "taux_ipp_medecin_traitant"
    t.boolean "accord_taux_ipp", default: false
    t.date "date_visite"
    t.index ["arret_travail_id"], name: "index_at_consolidations_on_arret_travail_id"
  end

  create_table "at_decomptes", force: :cascade do |t|
    t.string "periode_indemnise"
    t.integer "nombre_jour"
    t.float "demi_salaire"
    t.float "deux_tier_salaire"
    t.float "montant"
    t.date "date_validation"
    t.date "date_liquidation"
    t.date "date_paiement"
    t.boolean "est_valide", default: false
    t.bigint "arret_travail_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "etat"
    t.datetime "date_validation_comptable"
    t.date "date_debut"
    t.date "date_fin"
    t.date "date_validation_medecin"
    t.boolean "est_calculer", default: false
    t.integer "ajoute_par_id"
    t.integer "validation_comptable_par"
    t.integer "validation_medecin_conseil_par"
    t.integer "validation_par"
    t.integer "liquide_par"
    t.text "motif_rejet"
    t.integer "rejete_par"
    t.boolean "validation_medecin_obligatoire", default: false
    t.datetime "date_rejet"
    t.integer "active_par"
    t.datetime "date_activation"
    t.string "motif_convocation"
    t.datetime "date_convocation"
    t.integer "convoquer_par_id"
    t.boolean "solicite_medecin", default: false
    t.boolean "est_repris", default: false
    t.string "no_sinistre"
    t.boolean "paiement", default: false
    t.bigint "ordre_paiement_id"
    t.index ["arret_travail_id"], name: "index_at_decomptes_on_arret_travail_id"
    t.index ["ordre_paiement_id"], name: "index_at_decomptes_on_ordre_paiement_id"
  end

  create_table "at_documents", force: :cascade do |t|
    t.string "libelle"
    t.string "code"
    t.integer "type_document"
    t.text "description"
    t.bigint "arret_travail_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arret_travail_id"], name: "index_at_documents_on_arret_travail_id"
  end

  create_table "at_dossier_reversion_rentes", force: :cascade do |t|
    t.string "numero_affiliation", null: false
    t.string "prenom", null: false
    t.string "nom", null: false
    t.date "date_naissance"
    t.date "date_mariage"
    t.integer "type_ayant_droit"
    t.string "numero_dossier"
    t.string "workflow_state"
    t.integer "conjoint_id"
    t.integer "enfant_id"
    t.integer "ascendants_salarie_id"
    t.string "nom_tuteur"
    t.string "prenom_tuteur"
    t.datetime "date_soumis"
    t.integer "soumis_par_id"
    t.integer "valider_par_id"
    t.date "valider_le"
    t.boolean "info_ayant_droit", default: false
    t.boolean "documents_valide", default: false
    t.boolean "boolean", default: false
    t.integer "ajoute_par"
    t.date "ajouter_le"
    t.string "etat"
    t.string "string"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "at_rente_famille_id"
  end

  create_table "at_events", force: :cascade do |t|
    t.text "description"
    t.string "done_by"
    t.bigint "arret_travail_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arret_travail_id"], name: "index_at_events_on_arret_travail_id"
  end

  create_table "at_frais_engages", force: :cascade do |t|
    t.string "numero"
    t.string "prenom"
    t.string "nom"
    t.string "montant"
    t.string "date_liquidation"
    t.string "nature"
    t.integer "type_frais"
    t.bigint "arret_travail_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "identification"
    t.date "date_validation"
    t.date "date_validation_comptable"
    t.integer "rembourse_a_qui", default: 1
    t.integer "etat"
    t.date "date_validation_medecin"
    t.integer "ajoute_par_id"
    t.integer "validation_comptable_par"
    t.integer "validation_medecin_conseil_par"
    t.integer "validation_par"
    t.integer "liquide_par"
    t.text "motif_rejet"
    t.integer "rejete_par"
    t.boolean "validation_medecin_obligatoire", default: false
    t.datetime "date_rejet"
    t.integer "active_par"
    t.datetime "date_activation"
    t.boolean "remboursement_tiers", default: false, null: false
    t.boolean "est_repris", default: false
    t.string "no_sinistre"
    t.boolean "paiement", default: false
    t.bigint "ordre_paiement_id"
    t.index ["arret_travail_id"], name: "index_at_frais_engages_on_arret_travail_id"
    t.index ["ordre_paiement_id"], name: "index_at_frais_engages_on_ordre_paiement_id"
  end

  create_table "at_guerisons", force: :cascade do |t|
    t.bigint "arret_travail_id"
    t.text "observation"
    t.integer "soumis_par_id"
    t.string "workflow_state"
    t.text "motif"
    t.boolean "information_generale", default: false
    t.boolean "boolean", default: false
    t.boolean "documents_valide", default: false
    t.date "date_soumission"
    t.integer "ajoute_par_id"
    t.date "ajouter_le"
    t.integer "valide_par_id"
    t.date "date_validation"
    t.date "date_ouverture_guerison"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_rejet"
    t.integer "rejete_par_id"
    t.boolean "est_repris", default: false
    t.string "no_sinistre"
    t.index ["arret_travail_id"], name: "index_at_guerisons_on_arret_travail_id"
  end

  create_table "at_incapacites", force: :cascade do |t|
    t.date "date_debut"
    t.date "date_fin"
    t.integer "nombre_jour"
    t.integer "nombre_heure"
    t.bigint "arret_travail_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "est_calculer", default: false
    t.boolean "est_valide", default: false
    t.integer "at_decompte_id"
    t.integer "done_by"
    t.boolean "est_repris", default: false
    t.string "no_sinistre"
    t.index ["arret_travail_id"], name: "index_at_incapacites_on_arret_travail_id"
  end

  create_table "at_lesions", force: :cascade do |t|
    t.integer "nature_lesion"
    t.string "code_nature_lesion"
    t.integer "siege_lesion"
    t.string "code_siege_lesion"
    t.bigint "arret_travail_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type_arret"
    t.boolean "est_repris", default: false
    t.string "no_sinistre"
    t.index ["arret_travail_id"], name: "index_at_lesions_on_arret_travail_id"
  end

  create_table "at_rechutes", force: :cascade do |t|
    t.bigint "arret_travail_id"
    t.string "workflow_state"
    t.text "motif"
    t.boolean "information_generale", default: false
    t.boolean "boolean", default: false
    t.boolean "documents_valide", default: false
    t.boolean "information_salaire", default: false
    t.integer "soumis_par"
    t.date "date_soumission"
    t.integer "ajoute_par_id"
    t.date "ajouter_le"
    t.integer "valide_par_id"
    t.date "date_validation"
    t.date "date_rechute"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_validation_mc"
    t.date "date_validation_rechute"
    t.date "date_rejet_rechute"
    t.string "description_avis"
    t.string "avis"
    t.boolean "avis_mc_valide"
    t.string "observation"
    t.integer "rejete_par_id"
    t.boolean "est_repris", default: false
    t.string "no_sinistre"
    t.index ["arret_travail_id"], name: "index_at_rechutes_on_arret_travail_id"
  end

  create_table "at_rente_familles", force: :cascade do |t|
    t.bigint "arret_travail_id"
    t.string "workflow_state"
    t.string "string"
    t.integer "soumis_par"
    t.string "integer"
    t.date "date_soumission"
    t.string "datetime"
    t.text "motif"
    t.boolean "information_defunt", default: false
    t.boolean "documents_valide", default: false
    t.boolean "boolean", default: false
    t.boolean "information_salaire", default: false
    t.boolean "epouses_valide", default: false
    t.boolean "enfants_valide", default: false
    t.boolean "ascendants_valide", default: false
    t.boolean "tableau_rente_valide", default: false
    t.date "date_deces"
    t.integer "ajoute_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "numero_affiliation"
    t.date "date_affectation"
    t.integer "affectation_technicien"
    t.string "conjoints_id", default: [], array: true
    t.string "enfants_id", default: [], array: true
    t.integer "rejete_par_id"
    t.integer "valide_chef_agence_par_id"
    t.integer "valide_chef_service_par_id"
    t.integer "valide_dir_at_par_id"
    t.datetime "date_validation_chef_service"
    t.datetime "date_validation_chef_agence"
    t.datetime "date_validation_directeur_at"
    t.datetime "date_validation_directeur_general"
    t.datetime "valide_dg_par_id"
    t.integer "date_rejete"
    t.string "motif_deces"
    t.datetime "date_validation_audit"
    t.integer "validation_audit_par_id"
    t.index ["arret_travail_id"], name: "index_at_rente_familles_on_arret_travail_id"
  end

  create_table "at_salaires", force: :cascade do |t|
    t.integer "mois"
    t.integer "montant"
    t.integer "at_consolidation_id"
    t.integer "at_rente_famille_id"
    t.integer "arret_travail_id"
  end

  create_table "at_vente_carnets", force: :cascade do |t|
    t.string "num_employeur"
    t.string "num_recu"
    t.integer "num_carnets"
    t.date "date_delivrance"
    t.integer "ajoute_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "numero_carnet", default: [], array: true
    t.bigint "admin_agence_id"
    t.index ["admin_agence_id"], name: "index_at_vente_carnets_on_admin_agence_id"
  end

  create_table "attestations", force: :cascade do |t|
    t.string "titre"
    t.string "url"
    t.integer "etat", default: 0
    t.string "message"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attributaire_tierces", force: :cascade do |t|
    t.string "workflow_state"
    t.string "prenom"
    t.string "nom"
    t.string "nin"
    t.integer "ajoute_par_id"
    t.integer "soumis_par_id"
    t.integer "valide_par_id"
    t.integer "cloture_par_id"
    t.integer "rejete_par_id"
    t.text "motif_rejet"
    t.date "date_soumission"
    t.date "date_validation"
    t.date "date_cloturation"
    t.date "date_rejet"
    t.bigint "dossier_prestation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dossier_prestation_id"], name: "index_attributaire_tierces_on_dossier_prestation_id"
  end

  create_table "avis_tiers", force: :cascade do |t|
    t.string "numero_dossier"
    t.integer "type_operation"
    t.float "montant"
    t.float "montant_mensuel"
    t.datetime "date_debut"
    t.string "date_fin"
    t.integer "nombre_echeance"
    t.string "numero_allocataire"
    t.string "commentaire"
    t.integer "etat"
    t.datetime "valider_le"
    t.integer "valider_par_id"
    t.integer "ajouter_par_id"
    t.integer "gest_allocataire_id"
    t.datetime "affecter_le"
    t.datetime "traite_le"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "montant_restant", default: 0.0, null: false
    t.date "date_versement"
    t.boolean "est_repris", default: false
  end

  create_table "avis_tiers_paiement_allocataires", id: false, force: :cascade do |t|
    t.bigint "paiement_allocataire_id", null: false
    t.bigint "avis_tier_id", null: false
    t.index ["avis_tier_id", "paiement_allocataire_id"], name: "index_avis_tiers_paiement_allocataires"
  end

  create_table "avocats_huissiers", force: :cascade do |t|
    t.string "prenom"
    t.string "nom"
    t.string "adresse"
    t.integer "tel"
    t.string "email"
    t.bigint "nin"
    t.bigint "dossier_juridique_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "type_intervenant"
    t.index ["dossier_juridique_id"], name: "index_avocats_huissiers_on_dossier_juridique_id"
  end

  create_table "bareme_impots", force: :cascade do |t|
    t.integer "revenu_brut"
    t.integer "trimf"
    t.integer "un"
    t.integer "un_cinq"
    t.integer "deux"
    t.integer "deux_cinq"
    t.integer "trois"
    t.integer "trois_cinq"
    t.integer "quatre"
    t.integer "quatre_cinq"
    t.integer "cinq"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "base_reversion_salaries", force: :cascade do |t|
    t.string "numero_dossier"
    t.string "numero_affiliation", null: false
    t.string "nom", null: false
    t.string "prenom", null: false
    t.string "conjoints_id", default: [], array: true
    t.string "enfants_id", default: [], array: true
    t.date "date_deces", null: false
    t.date "date_cessation_activite", null: false
    t.date "date_naissance", null: false
    t.boolean "etat_civil_demandeur_valide", default: false, null: false
    t.boolean "documents_valide", default: false, null: false
    t.boolean "carriere_valide", default: false, null: false
    t.boolean "recap_point_valide", default: false, null: false
    t.boolean "epouses_valide", default: false, null: false
    t.boolean "enfants_valide", default: false, null: false
    t.datetime "valider_le"
    t.integer "valider_par_id"
    t.integer "ajouter_par_id"
    t.integer "instruit_par_id"
    t.datetime "instruit_le"
    t.datetime "affecter_le"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.integer "affectation_salarie"
    t.datetime "affectation_salarie_date"
    t.datetime "affectation_allocataire_date"
    t.integer "affectation_allocataire"
    t.date "date_soumission"
    t.date "ajouter_le"
    t.string "num_dossier"
    t.text "motif"
    t.datetime "debut_periode"
    t.string "workflow_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "affecter_salarie"
    t.boolean "dossier_demandeur_valide", default: false
    t.string "sexe"
    t.integer "agence_creation_id"
    t.integer "admin_agence_id"
    t.integer "nombre_epouses_eligible"
    t.integer "nombre_enfant_eligible"
    t.date "date_ouverture"
    t.datetime "date_soumission_carriere"
    t.datetime "date_validation_carriere"
    t.datetime "date_soumission_validation"
    t.datetime "date_validation_liquidation"
    t.integer "soumission_carriere_par"
    t.integer "validation_carriere_par"
    t.integer "soumission_validation_par"
    t.integer "validation_liquidation_par"
    t.string "commentaire_soumission"
    t.string "commentaire_instruction"
    t.string "commentaire_carriere"
    t.string "commentaire_validation_carriere"
    t.string "commentaire_tableau"
    t.string "commentaire_validation_tableau"
    t.string "commentaire_validation"
    t.string "commentaire_affectation_salaire"
    t.string "commentaire_affectation_allocataire"
    t.boolean "not_completed", default: false
    t.integer "motif_not_completed"
    t.text "documents_deposes_obligatoires", default: [], array: true
    t.text "documents_deposes_facultatifs", default: [], array: true
    t.integer "affecte_a_id"
  end

  create_table "base_reversions", force: :cascade do |t|
    t.string "numero_allocataire", null: false
    t.date "date_deces"
    t.text "commentaire"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "nombre_epouses_eligible", null: false
    t.integer "nombre_enfant_eligible", null: false
  end

  create_table "beneficiary_associations_to_dps", force: :cascade do |t|
    t.bigint "dossier_prestation_id"
    t.bigint "conjoint_id"
    t.bigint "enfant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "attributaire_tierce_id"
    t.integer "type_beneficiary"
    t.index ["conjoint_id"], name: "index_beneficiary_associations_to_dps_on_conjoint_id"
    t.index ["dossier_prestation_id"], name: "index_beneficiary_associations_to_dps_on_dossier_prestation_id"
    t.index ["enfant_id"], name: "index_beneficiary_associations_to_dps_on_enfant_id"
  end

  create_table "bien_pers_conjoints", force: :cascade do |t|
    t.bigint "liquidation_retraite_france_id"
    t.string "description"
    t.float "valeur_actuelle"
    t.string "situation_departement"
    t.string "lieu_imposition"
    t.float "revenu_cadastral"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["liquidation_retraite_france_id"], name: "index_bien_pers_conjoints_on_liquidation_retraite_france_id"
  end

  create_table "bordereau_collectifs", force: :cascade do |t|
    t.bigint "employeur_id"
    t.string "numero_bordereau", null: false
    t.integer "trimestre", null: false
    t.integer "annee", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "workflow_state"
    t.date "date_liquidation"
    t.date "date_validation_chef_agence"
    t.date "date_validation_comptable"
    t.integer "liquide_par_id"
    t.integer "valide_chef_agence_par_id"
    t.integer "valide_comptable_par_id"
    t.string "motif_rejet"
    t.date "date_document"
    t.integer "bordereau_type", default: 1
    t.index ["employeur_id"], name: "index_bordereau_collectifs_on_employeur_id"
  end

  create_table "bordereau_salaries_assocs", force: :cascade do |t|
    t.bigint "bordereau_collectif_id"
    t.string "participant_id"
    t.index ["bordereau_collectif_id"], name: "index_bordereau_salaries_assocs_on_bordereau_collectif_id"
    t.index ["participant_id"], name: "index_bordereau_salaries_assocs_on_participant_id"
  end

  create_table "caf_conjoints", force: :cascade do |t|
    t.string "prenom"
    t.string "nom"
    t.string "nom_jeune_fille"
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.date "date_mariage"
    t.date "date_separation"
    t.date "date_divorce"
    t.string "adresse_precise"
    t.bigint "prestation_exterieure_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "etat_couple"
    t.integer "sexe"
    t.integer "type_piece"
    t.string "nin_conjoint"
    t.boolean "is_beneficiary", default: false
    t.boolean "est_repris", default: false
    t.integer "ajoute_par_id"
    t.string "numero_secu_social"
    t.index ["prestation_exterieure_id"], name: "index_caf_conjoints_on_prestation_exterieure_id"
  end

  create_table "caf_enfants", force: :cascade do |t|
    t.string "prenom"
    t.string "nom"
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.string "observations"
    t.bigint "caf_conjoint_id"
    t.integer "lien_parente"
    t.integer "type_piece"
    t.string "numero_piece"
    t.integer "sexe"
    t.boolean "est_repris", default: false
    t.date "migrated_document_exp_date"
    t.integer "ajoute_par_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.bigint "prestation_exterieure_id"
    t.string "numero_secu_social"
    t.string "nin_conjoint"
    t.boolean "active", default: true
    t.index ["caf_conjoint_id"], name: "index_caf_enfants_on_caf_conjoint_id"
    t.index ["prestation_exterieure_id"], name: "index_caf_enfants_on_prestation_exterieure_id"
  end

  create_table "caisse_paiements", force: :cascade do |t|
    t.string "numero_ordre", limit: 20
    t.string "numero_allocataire", limit: 30
    t.string "ipres_ancien_matric", limit: 30
    t.string "prenom"
    t.string "nom"
    t.integer "source"
    t.integer "mode_paiement"
    t.string "details"
    t.float "montant", null: false
    t.integer "etat", default: 1, null: false
    t.integer "annee"
    t.integer "periode"
    t.integer "numero_periode"
    t.bigint "echeance_paiement_id"
    t.bigint "compta_transaction_id"
    t.datetime "date_paiement"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nin", limit: 50
    t.integer "marquee_impayee_par_id"
    t.datetime "marquee_impayee_le"
    t.boolean "paye_sur_psrm", default: false, null: false
    t.index ["compta_transaction_id"], name: "index_caisse_paiements_on_compta_transaction_id"
    t.index ["echeance_paiement_id"], name: "index_caisse_paiements_on_echeance_paiement_id"
    t.index ["ipres_ancien_matric"], name: "index_caisse_paiements_on_ipres_ancien_matric"
    t.index ["mode_paiement"], name: "index_caisse_paiements_on_mode_paiement"
    t.index ["nom"], name: "index_caisse_paiements_on_nom"
    t.index ["numero_allocataire"], name: "index_caisse_paiements_on_numero_allocataire"
    t.index ["numero_ordre"], name: "index_caisse_paiements_on_numero_ordre", unique: true
    t.index ["prenom"], name: "index_caisse_paiements_on_prenom"
    t.index ["source"], name: "index_caisse_paiements_on_source"
    t.index ["user_id"], name: "index_caisse_paiements_on_user_id"
  end

  create_table "carriere_dossier_maternites", force: :cascade do |t|
    t.bigint "dossier_maternite_id"
    t.date "date_depot"
    t.string "num_employeur"
    t.string "raison_sociale"
    t.date "date_document"
    t.integer "trimestre"
    t.integer "annee"
    t.boolean "en_jour"
    t.integer "premier_mois"
    t.integer "deuxiem_mois"
    t.integer "troisiem_mois"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "presence_en_heure", default: false
    t.boolean "est_repris", default: false, null: false
    t.index ["dossier_maternite_id"], name: "index_carriere_dossier_maternites_on_dossier_maternite_id"
  end

  create_table "carriere_dossier_prestations", force: :cascade do |t|
    t.bigint "dossier_prestation_id"
    t.date "date_depot"
    t.string "num_employeur"
    t.string "raison_sociale"
    t.date "date_document"
    t.integer "trimestre"
    t.boolean "infos_jour"
    t.boolean "infos_heure"
    t.integer "premier_mois"
    t.integer "deuxiem_mois"
    t.integer "troisiem_mois"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "annee"
    t.boolean "est_justifier"
    t.text "commentaire"
    t.string "num_employeur_mois_2"
    t.string "raison_sociale_employeur_mois_2"
    t.string "num_employeur_mois_3"
    t.string "raison_sociale_employeur_mois_3"
    t.boolean "est_justifier_mois2"
    t.boolean "est_justifier_mois3"
    t.string "motif_mois1"
    t.string "motif_mois2"
    t.string "motif_mois3"
    t.boolean "est_repris", default: false, null: false
    t.integer "bordereau_collectif_id"
    t.bigint "echeance_caisse_id"
    t.bigint "echeance_caisse_lot_liquidation_id"
    t.index ["dossier_prestation_id", "trimestre", "annee"], name: "index_unique_on_carriere_dossier_prestations_trimestre_annee", unique: true
    t.index ["dossier_prestation_id"], name: "index_carriere_dossier_prestations_on_dossier_prestation_id"
    t.index ["echeance_caisse_id"], name: "index_carriere_dossier_prestations_on_echeance_caisse_id"
    t.index ["echeance_caisse_lot_liquidation_id"], name: "tp_echeance_lot_id"
  end

  create_table "carrieres", force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "points", default: 0
    t.float "salaire1", default: 0.0
    t.float "salaire2", default: 0.0
    t.string "exercice"
    t.integer "revision_pension_id", default: 0
    t.string "raison_sociale"
    t.float "salaire_plafond", default: 0.0
    t.boolean "est_repris", default: false
    t.string "motif"
    t.integer "edi_id"
    t.index ["edi_id"], name: "index_carrieres_on_edi_id"
  end

  create_table "carrieres_exterieures", force: :cascade do |t|
    t.bigint "employeur_exterieur_id"
    t.bigint "cfs_reversion_veuve_id"
    t.date "date_debut"
    t.date "date_fin"
    t.integer "type_regime"
    t.float "salaire"
    t.string "motif_rejet"
    t.integer "etat"
    t.datetime "date_traitement"
    t.integer "traite_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "provenance"
    t.bigint "liquidation_retraite_france_id"
    t.index ["cfs_reversion_veuve_id"], name: "index_carrieres_exterieures_on_cfs_reversion_veuve_id"
    t.index ["employeur_exterieur_id"], name: "index_carrieres_exterieures_on_employeur_exterieur_id"
  end

  create_table "carrieres_x", id: false, force: :cascade do |t|
    t.string "numero_affiliation", limit: 15
    t.date "min_rg"
    t.date "max_rg"
    t.bigint "lignes_rg"
    t.decimal "mois_rg"
    t.date "min_rc"
    t.date "max_rc"
    t.bigint "lignes_rc"
    t.decimal "mois_rc"
    t.float "first_salaire_rg"
    t.float "last_salaire_rg"
    t.float "first_salaire_rc"
    t.float "last_salaire_rc"
  end

  create_table "carrieres_zz", id: false, force: :cascade do |t|
    t.string "numero_affiliation", limit: 15
    t.integer "type_regime_id"
    t.decimal "min"
    t.decimal "max"
    t.date "min_exer"
    t.date "max_exer"
    t.bigint "lignes"
    t.decimal "mois"
  end

  create_table "carrieres_zzz", id: false, force: :cascade do |t|
    t.string "numero_affiliation", limit: 15
    t.date "min_rg"
    t.date "max_rg"
    t.bigint "lignes_rg"
    t.decimal "mois_rg"
    t.date "min_rc"
    t.date "max_rc"
    t.bigint "lignes_rc"
    t.decimal "mois_rc"
  end

  create_table "carrires_prest_exterieures", force: :cascade do |t|
    t.bigint "employeur_exterieurs_id"
    t.bigint "prestation_ext_frances_id"
    t.date "date_debut"
    t.date "date_fin"
    t.integer "type_regime"
    t.float "salaire"
    t.string "motif_rejet"
    t.integer "etat"
    t.datetime "date_traitement"
    t.integer "traite_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employeur_exterieurs_id"], name: "index_carrires_prest_exterieures_on_employeur_exterieurs_id"
    t.index ["prestation_ext_frances_id"], name: "index_carrires_prest_exterieures_on_prestation_ext_frances_id"
  end

  create_table "cfs_conjoints", force: :cascade do |t|
    t.bigint "liquidation_retraite_france_id"
    t.string "prenom"
    t.string "nom"
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.integer "nationalite_id"
    t.string "prenom_pere"
    t.string "nom_pere"
    t.string "prenom_mere"
    t.string "nom_mere"
    t.string "numero_securite_sociale"
    t.date "date_mariage"
    t.boolean "situation"
    t.date "date_deces"
    t.integer "etat", default: 1
    t.integer "ajoute_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "nin"
    t.boolean "est_salarie"
    t.string "numero_salarie"
    t.boolean "est_enceinte", default: false
    t.string "numero_affiliation"
    t.integer "type_piece"
    t.string "numero_piece"
    t.string "nom_salarie"
    t.string "prenom_salarie"
    t.date "date_delivrance_piece"
    t.date "date_expiration_piece"
    t.string "matric_conjoint"
    t.integer "sex"
    t.integer "etat_conjoint"
    t.integer "regime_matrimoniale"
    t.integer "etat_civil"
    t.integer "rang_conjoint"
    t.string "code_etat_civil"
    t.string "numero_registre"
    t.string "nin_generer"
    t.date "date_naissance_salarie"
    t.date "date_divorce"
    t.date "date_transcription"
    t.integer "nombre_femmes"
    t.date "date_etablissement_mariage"
    t.date "date_jugement_suppletif"
    t.date "date_expiration_piece_salarie"
    t.date "date_delivrance_piece_salarie"
    t.string "numero_jugement_mariage"
    t.boolean "est_repris", default: false, null: false
    t.string "old_created_par", limit: 100
    t.string "old_conjoint_id", limit: 250
    t.date "date_declaration_divorce"
    t.date "date_declaration_deces"
    t.integer "reprise_site"
    t.boolean "deleted", default: false
    t.boolean "incomplete", default: false
    t.index ["liquidation_retraite_france_id"], name: "index_cfs_conjoints_on_liquidation_retraite_france_id"
    t.index ["user_id"], name: "index_cfs_conjoints_on_user_id"
  end

  create_table "cfs_correspondances", force: :cascade do |t|
    t.bigint "liquidation_retraite_france_id"
    t.integer "type_lettre"
    t.integer "provenance"
    t.string "numero_correspondance"
    t.string "numero_dossier"
    t.string "numero_reference"
    t.string "objet"
    t.integer "titre_destinataire"
    t.string "destinataire"
    t.string "adresse_destinataire"
    t.string "expediteur"
    t.datetime "date"
    t.string "corps"
    t.integer "titre_demandeur"
    t.boolean "piece_jointe"
    t.string "nature_piece_jointe"
    t.integer "etat"
    t.integer "ajoute_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["liquidation_retraite_france_id"], name: "index_cfs_correspondances_on_liquidation_retraite_france_id"
  end

  create_table "cfs_enfants", force: :cascade do |t|
    t.bigint "liquidation_retraite_france_id"
    t.string "prenom"
    t.string "nom"
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.date "date_deces"
    t.integer "etat"
    t.integer "ajoute_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "cfs_conjoint_id"
    t.string "prenom_mere"
    t.string "nom_mere"
    t.string "prenom_pere"
    t.string "nom_pere"
    t.string "numero_affiliation"
    t.integer "origine_enfant"
    t.integer "type_piece"
    t.string "numero_piece"
    t.integer "sexe"
    t.string "numero_registre"
    t.string "code_etat_civil"
    t.string "nom_mere_naturel"
    t.string "prenom_mere_naturel"
    t.string "nin_generer"
    t.date "date_delivrance_piece"
    t.date "date_transcription"
    t.date "date_expiration_piece"
    t.boolean "est_repris"
    t.date "date_declaration_deces"
    t.boolean "deleted"
    t.boolean "incomplete"
    t.string "numero_securite_sociale"
    t.index ["cfs_conjoint_id"], name: "index_cfs_enfants_on_cfs_conjoint_id"
    t.index ["liquidation_retraite_france_id"], name: "index_cfs_enfants_on_liquidation_retraite_france_id"
    t.index ["user_id"], name: "index_cfs_enfants_on_user_id"
  end

  create_table "cfs_reversion_veuves", force: :cascade do |t|
    t.integer "sexe_salarie"
    t.string "numero_affiliation"
    t.string "prenom"
    t.string "nom"
    t.string "nom_jeune_fille"
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.string "adresse_residence"
    t.string "prenom_pere"
    t.string "prenom_mere"
    t.string "nom_pere"
    t.string "nom_mere"
    t.integer "nationalite_id"
    t.string "num_immatric_ipres"
    t.string "num_immatric_cfs"
    t.integer "situation_familiale"
    t.date "date_mariage"
    t.date "date_situation_fam"
    t.date "date_ouverture_dossier"
    t.integer "nature"
    t.boolean "inapte", default: false
    t.date "date_depart_inapt"
    t.date "date_decision_inapt"
    t.boolean "titulaire_pens_invalidite", default: false
    t.boolean "titre_reg_gl", default: false
    t.boolean "titre_reg_agric", default: false
    t.boolean "titre_reg_minier", default: false
    t.boolean "titre_reg_special", default: false
    t.string "institution_reg_spec"
    t.string "num_pension_inapt"
    t.date "date_cess_act_sn"
    t.integer "total_an_carr_sn"
    t.date "date_cess_act_fr"
    t.integer "total_an_carr_fr"
    t.integer "sens_convention"
    t.integer "decide_points"
    t.integer "decide_montant_annuel"
    t.date "decide_date"
    t.integer "etat", default: 1
    t.date "date_soumission"
    t.date "date_validation"
    t.integer "valide_par_id"
    t.integer "ajoute_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.integer "soumis_par_id"
    t.boolean "etat_civil_demandeur_valid", default: false
    t.boolean "grappe_fam_valid", default: false
    t.boolean "activite_prof_valid", default: false
    t.boolean "assur_residence_valid", default: false
    t.boolean "assur_second_pays_valid", default: false
    t.boolean "charge_second_pays_valid", default: false
    t.boolean "document_valid", default: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.string "compte_bancaire_nom_banque"
    t.string "compte_bancaire_code_banque"
    t.string "compte_bancaire_code_guichet"
    t.string "compte_bancaire_numero_compte", limit: 50
    t.string "numero_dossier"
    t.string "numero_piece"
    t.integer "type_piece"
    t.string "motif_rejet"
    t.string "email"
    t.integer "affectation_allocataire"
    t.datetime "affectation_allocataire_date"
    t.boolean "recap_point_valide", default: false
    t.integer "affectation_salarie"
    t.datetime "affectation_salarie_date"
    t.integer "instruit_par_id"
    t.datetime "instruit_le"
    t.bigint "allocataire_id"
    t.string "workflow_state"
    t.integer "type_retraite"
    t.boolean "epouses_valide", default: false, null: false
    t.boolean "enfants_valide", default: false, null: false
    t.string "nom_defunt"
    t.string "prenom_defunt"
    t.string "numero_securite_sociale_defunt"
    t.string "numero_securite_sociale_veuve"
    t.string "adresse_postale"
    t.index ["user_id"], name: "index_cfs_reversion_veuves_on_user_id"
  end

  create_table "cips", force: :cascade do |t|
    t.string "prenom"
    t.string "nom"
    t.string "demande_type"
    t.datetime "date_creation"
    t.integer "ajoute_par_id"
    t.string "nin"
    t.string "piece_identite"
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "composant_salaire_icms", force: :cascade do |t|
    t.bigint "dossier_maternite_id"
    t.integer "montant"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "composant_salaire_id"
    t.index ["dossier_maternite_id"], name: "index_composant_salaire_icms_on_dossier_maternite_id"
  end

  create_table "composant_salaires", force: :cascade do |t|
    t.string "designation"
    t.string "code"
    t.boolean "prise_en_compte"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "compta_transactions", primary_key: ["id", "date_comptable"], force: :cascade do |t|
    t.bigserial "id", null: false
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable", null: false
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.float "montant_subvention"
  end

  create_table "compta_transactions_2015", primary_key: ["id", "date_comptable"], force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('compta_transactions_id_seq1'::regclass)" }, null: false
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable", null: false
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.float "montant_subvention"
    t.index ["admin_agence_id"], name: "compta_transactions_2015_admin_agence_id_idx"
    t.index ["admin_region_id"], name: "compta_transactions_2015_admin_region_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2015_dossier_type_dossier_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2015_dossier_type_dossier_id_idx1"
    t.index ["echeance_paiement_id"], name: "compta_transactions_2015_echeance_paiement_id_idx"
    t.index ["id_reprise"], name: "compta_transactions_2015_id_reprise_idx"
    t.index ["numero_allocataire"], name: "compta_transactions_2015_numero_allocataire_idx"
    t.index ["ordre_paiement_id"], name: "compta_transactions_2015_ordre_paiement_id_idx"
    t.index ["send_to_compta"], name: "compta_transactions_2015_send_to_compta_idx"
  end

  create_table "compta_transactions_2016", primary_key: ["id", "date_comptable"], force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('compta_transactions_id_seq1'::regclass)" }, null: false
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable", null: false
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.float "montant_subvention"
    t.index ["admin_agence_id"], name: "compta_transactions_2016_admin_agence_id_idx"
    t.index ["admin_region_id"], name: "compta_transactions_2016_admin_region_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2016_dossier_type_dossier_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2016_dossier_type_dossier_id_idx1"
    t.index ["echeance_paiement_id"], name: "compta_transactions_2016_echeance_paiement_id_idx"
    t.index ["id_reprise"], name: "compta_transactions_2016_id_reprise_idx"
    t.index ["numero_allocataire"], name: "compta_transactions_2016_numero_allocataire_idx"
    t.index ["ordre_paiement_id"], name: "compta_transactions_2016_ordre_paiement_id_idx"
    t.index ["send_to_compta"], name: "compta_transactions_2016_send_to_compta_idx"
  end

  create_table "compta_transactions_2017", primary_key: ["id", "date_comptable"], force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('compta_transactions_id_seq1'::regclass)" }, null: false
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable", null: false
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.float "montant_subvention"
    t.index ["admin_agence_id"], name: "compta_transactions_2017_admin_agence_id_idx"
    t.index ["admin_region_id"], name: "compta_transactions_2017_admin_region_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2017_dossier_type_dossier_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2017_dossier_type_dossier_id_idx1"
    t.index ["echeance_paiement_id"], name: "compta_transactions_2017_echeance_paiement_id_idx"
    t.index ["id_reprise"], name: "compta_transactions_2017_id_reprise_idx"
    t.index ["numero_allocataire"], name: "compta_transactions_2017_numero_allocataire_idx"
    t.index ["ordre_paiement_id"], name: "compta_transactions_2017_ordre_paiement_id_idx"
    t.index ["send_to_compta"], name: "compta_transactions_2017_send_to_compta_idx"
  end

  create_table "compta_transactions_2018", primary_key: ["id", "date_comptable"], force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('compta_transactions_id_seq1'::regclass)" }, null: false
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable", null: false
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.float "montant_subvention"
    t.index ["admin_agence_id"], name: "compta_transactions_2018_admin_agence_id_idx"
    t.index ["admin_region_id"], name: "compta_transactions_2018_admin_region_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2018_dossier_type_dossier_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2018_dossier_type_dossier_id_idx1"
    t.index ["echeance_paiement_id"], name: "compta_transactions_2018_echeance_paiement_id_idx"
    t.index ["id_reprise"], name: "compta_transactions_2018_id_reprise_idx"
    t.index ["numero_allocataire"], name: "compta_transactions_2018_numero_allocataire_idx"
    t.index ["ordre_paiement_id"], name: "compta_transactions_2018_ordre_paiement_id_idx"
    t.index ["send_to_compta"], name: "compta_transactions_2018_send_to_compta_idx"
  end

  create_table "compta_transactions_2019", primary_key: ["id", "date_comptable"], force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('compta_transactions_id_seq1'::regclass)" }, null: false
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable", null: false
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.float "montant_subvention"
    t.index ["admin_agence_id"], name: "compta_transactions_2019_admin_agence_id_idx"
    t.index ["admin_region_id"], name: "compta_transactions_2019_admin_region_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2019_dossier_type_dossier_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2019_dossier_type_dossier_id_idx1"
    t.index ["echeance_paiement_id"], name: "compta_transactions_2019_echeance_paiement_id_idx"
    t.index ["id_reprise"], name: "compta_transactions_2019_id_reprise_idx"
    t.index ["numero_allocataire"], name: "compta_transactions_2019_numero_allocataire_idx"
    t.index ["ordre_paiement_id"], name: "compta_transactions_2019_ordre_paiement_id_idx"
    t.index ["send_to_compta"], name: "compta_transactions_2019_send_to_compta_idx"
  end

  create_table "compta_transactions_2020", primary_key: ["id", "date_comptable"], force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('compta_transactions_id_seq1'::regclass)" }, null: false
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable", null: false
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.float "montant_subvention"
    t.index ["admin_agence_id"], name: "compta_transactions_2020_admin_agence_id_idx"
    t.index ["admin_region_id"], name: "compta_transactions_2020_admin_region_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2020_dossier_type_dossier_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2020_dossier_type_dossier_id_idx1"
    t.index ["echeance_paiement_id"], name: "compta_transactions_2020_echeance_paiement_id_idx"
    t.index ["id_reprise"], name: "compta_transactions_2020_id_reprise_idx"
    t.index ["numero_allocataire"], name: "compta_transactions_2020_numero_allocataire_idx"
    t.index ["ordre_paiement_id"], name: "compta_transactions_2020_ordre_paiement_id_idx"
    t.index ["send_to_compta"], name: "compta_transactions_2020_send_to_compta_idx"
  end

  create_table "compta_transactions_2021", primary_key: ["id", "date_comptable"], force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('compta_transactions_id_seq1'::regclass)" }, null: false
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable", null: false
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.float "montant_subvention"
    t.index ["admin_agence_id"], name: "compta_transactions_2021_admin_agence_id_idx"
    t.index ["admin_region_id"], name: "compta_transactions_2021_admin_region_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2021_dossier_type_dossier_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2021_dossier_type_dossier_id_idx1"
    t.index ["echeance_paiement_id"], name: "compta_transactions_2021_echeance_paiement_id_idx"
    t.index ["id_reprise"], name: "compta_transactions_2021_id_reprise_idx"
    t.index ["numero_allocataire"], name: "compta_transactions_2021_numero_allocataire_idx"
    t.index ["ordre_paiement_id"], name: "compta_transactions_2021_ordre_paiement_id_idx"
    t.index ["send_to_compta"], name: "compta_transactions_2021_send_to_compta_idx"
  end

  create_table "compta_transactions_2022", primary_key: ["id", "date_comptable"], force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('compta_transactions_id_seq1'::regclass)" }, null: false
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable", null: false
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.float "montant_subvention"
    t.index ["admin_agence_id"], name: "compta_transactions_2022_admin_agence_id_idx"
    t.index ["admin_region_id"], name: "compta_transactions_2022_admin_region_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2022_dossier_type_dossier_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2022_dossier_type_dossier_id_idx1"
    t.index ["echeance_paiement_id"], name: "compta_transactions_2022_echeance_paiement_id_idx"
    t.index ["id_reprise"], name: "compta_transactions_2022_id_reprise_idx"
    t.index ["numero_allocataire"], name: "compta_transactions_2022_numero_allocataire_idx"
    t.index ["ordre_paiement_id"], name: "compta_transactions_2022_ordre_paiement_id_idx"
    t.index ["send_to_compta"], name: "compta_transactions_2022_send_to_compta_idx"
  end

  create_table "compta_transactions_2023", primary_key: ["id", "date_comptable"], force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('compta_transactions_id_seq1'::regclass)" }, null: false
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable", null: false
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.float "montant_subvention"
    t.index ["admin_agence_id"], name: "compta_transactions_2023_admin_agence_id_idx"
    t.index ["admin_region_id"], name: "compta_transactions_2023_admin_region_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2023_dossier_type_dossier_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2023_dossier_type_dossier_id_idx1"
    t.index ["echeance_paiement_id"], name: "compta_transactions_2023_echeance_paiement_id_idx"
    t.index ["id_reprise"], name: "compta_transactions_2023_id_reprise_idx"
    t.index ["numero_allocataire"], name: "compta_transactions_2023_numero_allocataire_idx"
    t.index ["ordre_paiement_id"], name: "compta_transactions_2023_ordre_paiement_id_idx"
    t.index ["send_to_compta"], name: "compta_transactions_2023_send_to_compta_idx"
  end

  create_table "compta_transactions_2024", primary_key: ["id", "date_comptable"], force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('compta_transactions_id_seq1'::regclass)" }, null: false
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable", null: false
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.float "montant_subvention"
    t.index ["admin_agence_id"], name: "compta_transactions_2024_admin_agence_id_idx"
    t.index ["admin_region_id"], name: "compta_transactions_2024_admin_region_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2024_dossier_type_dossier_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2024_dossier_type_dossier_id_idx1"
    t.index ["echeance_paiement_id"], name: "compta_transactions_2024_echeance_paiement_id_idx"
    t.index ["id_reprise"], name: "compta_transactions_2024_id_reprise_idx"
    t.index ["numero_allocataire"], name: "compta_transactions_2024_numero_allocataire_idx"
    t.index ["ordre_paiement_id"], name: "compta_transactions_2024_ordre_paiement_id_idx"
    t.index ["send_to_compta"], name: "compta_transactions_2024_send_to_compta_idx"
  end

  create_table "compta_transactions_2025", primary_key: ["id", "date_comptable"], force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('compta_transactions_id_seq1'::regclass)" }, null: false
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable", null: false
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.float "montant_subvention"
    t.index ["admin_agence_id"], name: "compta_transactions_2025_admin_agence_id_idx"
    t.index ["admin_region_id"], name: "compta_transactions_2025_admin_region_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2025_dossier_type_dossier_id_idx"
    t.index ["dossier_type", "dossier_id"], name: "compta_transactions_2025_dossier_type_dossier_id_idx1"
    t.index ["echeance_paiement_id"], name: "compta_transactions_2025_echeance_paiement_id_idx"
    t.index ["id_reprise"], name: "compta_transactions_2025_id_reprise_idx"
    t.index ["numero_allocataire"], name: "compta_transactions_2025_numero_allocataire_idx"
    t.index ["ordre_paiement_id"], name: "compta_transactions_2025_ordre_paiement_id_idx"
    t.index ["send_to_compta"], name: "compta_transactions_2025_send_to_compta_idx"
  end

  create_table "compta_transactions_legacy", id: :bigint, default: -> { "nextval('compta_transactions_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.string "code_operation", null: false
    t.string "code_classe_evenement", default: "LIQUIDATION", null: false
    t.string "code_agence_liquidation"
    t.string "numero_allocataire", null: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "code_banque_allocataire"
    t.string "numero_compte_allocataire"
    t.date "date_debut_periode"
    t.date "date_fin_periode"
    t.float "montant", null: false
    t.string "code_devise", limit: 3, default: "XOF", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mode_paiement"
    t.boolean "send_to_compta", default: false, null: false
    t.string "bank_id"
    t.string "bank_branch_id"
    t.bigint "ordre_paiement_id"
    t.string "description"
    t.boolean "can_send_to_compta", default: true, null: false
    t.datetime "send_to_compta_at"
    t.bigint "echeance_paiement_id"
    t.integer "zone"
    t.bigint "admin_region_id"
    t.bigint "admin_agence_id"
    t.string "nin_allocataire"
    t.string "telephone_allocataire"
    t.string "mail_allocataire"
    t.datetime "date_comptable"
    t.boolean "en_tete", default: true, null: false
    t.boolean "est_repris", default: false, null: false
    t.integer "id_reprise"
    t.string "infos_paiement_id_bhs", limit: 30
    t.string "infos_paiement_id_ccp", limit: 30
    t.string "infos_paiement_libelle_ccp", limit: 30
    t.string "infos_paiement_succursale_cncas", limit: 30
    t.boolean "est_attributaire", default: false, null: false
    t.boolean "par_subrogation", default: false, null: false
    t.string "id_reel_allocataire"
    t.string "nom_reel_allocataire"
    t.string "prenom_reel_allocataire"
    t.index ["admin_agence_id"], name: "index_compta_transactions_on_admin_agence_id_legacy"
    t.index ["admin_region_id"], name: "index_compta_transactions_on_admin_region_id_legacy"
    t.index ["dossier_type", "dossier_id"], name: "index_compta_transactions_on_dr_type_and_dr_id_legacy"
    t.index ["echeance_paiement_id"], name: "index_compta_transactions_on_echeance_paiement_id_legacy"
    t.index ["id_reprise"], name: "index_compta_transactions_on_id_reprise_legacy"
    t.index ["numero_allocataire"], name: "compta_transactions_numero_allocataire_idx_legacy"
    t.index ["ordre_paiement_id"], name: "index_compta_transactions_on_ordre_paiement_id_legacy"
    t.index ["send_to_compta"], name: "compta_transactions_send_to_compta_idx_legacy"
  end

  create_table "conjoints", force: :cascade do |t|
    t.bigint "user_id"
    t.string "prenom", null: false
    t.string "nom", null: false
    t.date "date_naissance", null: false
    t.date "date_mariage", null: false
    t.string "nin"
    t.integer "etat", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "est_salarie"
    t.string "numero_salarie"
    t.boolean "est_enceinte", default: false
    t.string "numero_affiliation"
    t.integer "ajoute_par_id"
    t.integer "type_piece"
    t.string "numero_piece"
    t.string "nom_salarie"
    t.string "prenom_salarie"
    t.date "date_delivrance_piece"
    t.date "date_expiration_piece"
    t.string "matric_conjoint"
    t.integer "sex"
    t.integer "etat_conjoint"
    t.integer "regime_matrimoniale"
    t.integer "etat_civil"
    t.integer "rang_conjoint"
    t.string "code_etat_civil"
    t.string "numero_registre"
    t.string "nin_generer"
    t.date "date_naissance_salarie"
    t.date "date_divorce"
    t.date "date_deces"
    t.date "date_transcription"
    t.integer "nombre_femmes"
    t.date "date_etablissement_mariage"
    t.date "date_jugement_suppletif"
    t.boolean "est_af_beneficiaire"
    t.date "date_expiration_piece_salarie"
    t.date "date_delivrance_piece_salarie"
    t.string "numero_jugement_mariage"
    t.boolean "est_repris", default: false, null: false
    t.string "old_created_par", limit: 100
    t.string "old_conjoint_id", limit: 250
    t.date "date_declaration_divorce"
    t.date "date_declaration_deces"
    t.integer "reprise_site"
    t.boolean "deleted", default: false
    t.boolean "incomplete", default: false
    t.index ["deleted"], name: "conjoints_deleted_idx"
    t.index ["etat_conjoint"], name: "conjoints_etat_conjoint_idx"
    t.index ["incomplete"], name: "conjoints_incomplete_idx"
    t.index ["numero_affiliation"], name: "conjoints_numero_affiliation_idx"
    t.index ["numero_salarie"], name: "conjoints_numero_salarie_idx"
    t.index ["user_id"], name: "index_conjoints_on_user_id"
  end

  create_table "css_fiabilisation_historics", force: :cascade do |t|
    t.integer "dossier_id"
    t.string "dossier_type"
    t.string "prenom"
    t.string "nom"
    t.string "numero_affiliation"
    t.string "sexe"
    t.date "date_naissance"
    t.date "date_mariage"
    t.string "ajoute_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "css_transfert_allocataires", force: :cascade do |t|
    t.string "workflow_state"
    t.string "numero_affiliation"
    t.string "employeur_source_id"
    t.string "employeur_destination_id"
    t.string "agence_source_id"
    t.string "agence_destination_id"
    t.date "date_transfert"
    t.integer "ajoute_par_id"
    t.integer "soumis_par_id"
    t.integer "valide_par_id"
    t.integer "retourne_par_id"
    t.date "date_soumission"
    t.date "date_validation"
    t.boolean "information_valid"
    t.string "commentaire"
    t.text "motif_retour"
    t.date "date_retour"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_embauche"
  end

  create_table "css_transfert_employeurs", force: :cascade do |t|
    t.string "workflow_state"
    t.string "employeur_matric"
    t.string "agence_source_id"
    t.string "agence_destination_id"
    t.date "date_transfert"
    t.integer "ajoute_par_id"
    t.integer "soumis_par_id"
    t.integer "valide_par_id"
    t.integer "retourne_par_id"
    t.date "date_soumission"
    t.date "date_validation"
    t.boolean "information_valid"
    t.string "commentaire"
    t.text "motif_retour"
    t.date "date_retour"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deces_enfants", force: :cascade do |t|
    t.string "numero_affiliation"
    t.string "prenom"
    t.string "nom"
    t.date "date_naissance"
    t.string "prenom_salarie"
    t.string "nom_salarie"
    t.integer "type_piece"
    t.string "numero_piece"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "enfant_id"
    t.date "date_deces"
  end

  create_table "deces_salaries", force: :cascade do |t|
    t.string "numero_affiliation"
    t.string "prenom"
    t.string "nom"
    t.date "date_deces"
    t.string "numero_piece"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "declaration_carrieres", force: :cascade do |t|
    t.bigint "declaration_chargement_id"
    t.string "matric", limit: 20
    t.string "fhnum", limit: 20
    t.string "prenom", limit: 100
    t.string "nom", limit: 100
    t.string "fhrsoc"
    t.string "regime", limit: 5
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
    t.index ["declaration_chargement_id"], name: "index_declaration_carrieres_on_declaration_chargement_id"
    t.index ["fhnum"], name: "index_declaration_carrieres_on_fhnum"
    t.index ["matric"], name: "index_declaration_carrieres_on_matric"
    t.index ["regime"], name: "index_declaration_carrieres_on_regime"
  end

  create_table "declaration_chargement_lignes", force: :cascade do |t|
    t.bigint "declaration_chargement_id"
    t.integer "numero_ligne"
    t.integer "exercice"
    t.string "numero_affiliation", limit: 50
    t.string "nom"
    t.string "prenom"
    t.string "matricule_interne", limit: 100
    t.integer "jour_entree"
    t.integer "mois_entree"
    t.integer "annee_entree"
    t.integer "jour_sortie"
    t.integer "mois_sortie"
    t.integer "annee_sortie"
    t.string "motif_sortie"
    t.float "salaire_soumis"
    t.float "salaire_reel"
    t.string "statut"
    t.string "nin", limit: 30
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.string "profession"
    t.string "nationalite", limit: 100
    t.string "sexe", limit: 1
    t.boolean "erreur"
    t.string "details_erreur", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["declaration_chargement_id"], name: "idx_declaration_chargement_lignes_on_declaration_chargement_id"
  end

  create_table "declaration_chargements", force: :cascade do |t|
    t.bigint "declaration_salaire_manquante_id"
    t.integer "regime"
    t.string "numero_adherent"
    t.string "raison_sociale"
    t.integer "zone"
    t.string "date_declaration"
    t.integer "created_by_id"
    t.integer "nombre_salaries"
    t.float "total_salaries"
    t.float "cotisation_dues"
    t.boolean "is_valid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "statut", default: 0
    t.integer "traite_par_id"
    t.datetime "traite_le"
    t.string "motif_rejet"
    t.index ["declaration_salaire_manquante_id"], name: "idx_declaration_chargements_on_declaration_salaire_manquante_id"
  end

  create_table "declaration_divorce_ou_deces_conjoints", force: :cascade do |t|
    t.string "numero_affiliation"
    t.string "prenom_salarie"
    t.string "nom_salarie"
    t.integer "status_with_conjoint"
    t.string "prenom_conjoint"
    t.string "nom_conjoint"
    t.integer "type_piece"
    t.string "numero_piece_conjoint"
    t.bigint "conjoint_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_declaration"
    t.index ["conjoint_id"], name: "index_declaration_divorce_ou_deces_conjoints_on_conjoint_id"
  end

  create_table "declaration_participants", force: :cascade do |t|
    t.bigint "declaration_chargement_id"
    t.string "matric", null: false
    t.string "ipres_ancien_matric"
    t.string "css_ancien_matric"
    t.string "prenom"
    t.string "nom"
    t.string "type_piece"
    t.string "numero_piece"
    t.text "profession"
    t.string "emploi"
    t.string "regime"
    t.string "addr"
    t.string "phone"
    t.date "date_naissance"
    t.string "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "id_employeur", limit: 20
    t.string "contrat_en_cours", limit: 3
    t.date "date_debut_contrat"
    t.date "date_fin_contrat"
    t.index ["css_ancien_matric"], name: "index_declaration_participants_on_css_ancien_matric"
    t.index ["declaration_chargement_id"], name: "index_declaration_participants_on_declaration_chargement_id"
    t.index ["id_employeur"], name: "index_declaration_participants_on_id_employeur"
    t.index ["ipres_ancien_matric"], name: "index_declaration_participants_on_ipres_ancien_matric"
    t.index ["matric"], name: "index_declaration_participants_on_matric"
    t.index ["nom"], name: "index_declaration_participants_on_nom"
    t.index ["numero_piece"], name: "index_declaration_participants_on_numero_piece"
    t.index ["prenom"], name: "index_declaration_participants_on_prenom"
  end

  create_table "declaration_participants_secour", id: false, force: :cascade do |t|
    t.bigserial "id", null: false
    t.bigint "declaration_chargement_id"
    t.string "matric", null: false
    t.string "ipres_ancien_matric"
    t.string "css_ancien_matric"
    t.string "prenom"
    t.string "nom"
    t.string "type_piece"
    t.string "numero_piece"
    t.text "profession"
    t.string "emploi"
    t.string "regime"
    t.string "addr"
    t.string "phone"
    t.date "date_naissance"
    t.string "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "id_employeur", limit: 20
    t.string "contrat_en_cours", limit: 3
    t.date "date_debut_contrat"
    t.date "date_fin_contrat"
  end

  create_table "declaration_salaire_manquantes", force: :cascade do |t|
    t.string "numero", limit: 20, null: false
    t.string "raison_sociale"
    t.integer "zone"
    t.string "adresse"
    t.integer "exercice", null: false
    t.integer "regime", null: false
    t.string "telephone", limit: 30
    t.integer "effectif"
    t.string "code_agence", limit: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "complete", default: false, null: false
    t.integer "statut", default: 0
    t.index ["code_agence"], name: "index_declaration_salaire_manquantes_on_code_agence"
    t.index ["exercice"], name: "index_declaration_salaire_manquantes_on_exercice"
    t.index ["numero"], name: "index_declaration_salaire_manquantes_on_numero"
    t.index ["regime"], name: "index_declaration_salaire_manquantes_on_regime"
  end

  create_table "declarations", force: :cascade do |t|
    t.date "periode"
    t.integer "statut"
    t.float "montant_pf"
    t.float "montant_at"
    t.float "montant_rg"
    t.float "montant_rcc"
    t.float "montant_total"
    t.bigint "immatriculation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "effectif", default: 0
    t.bigint "user_id"
    t.boolean "mouvement_effectif_valide"
    t.boolean "recap_salarie_valide"
    t.boolean "synthese_valide"
    t.boolean "etat"
    t.date "date_soumission"
    t.float "cumul_pf"
    t.float "cumul_at"
    t.float "cumul_rg"
    t.float "cumul_rcc"
    t.float "cumul_salaire", default: 0.0
    t.bigint "process_flow_id", default: 0
    t.bigint "form_id", default: 0
    t.index ["immatriculation_id"], name: "index_declarations_on_immatriculation_id"
  end

  create_table "demande_carte_allocataires", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "allocataire_id"
    t.string "numero_document"
    t.integer "agence_enregistrement_id"
    t.string "nom"
    t.string "prenom"
    t.date "date_naissance"
    t.string "nin"
    t.string "email"
    t.string "adresse"
    t.integer "agence_retrait_id"
    t.string "telephone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allocataire_id"], name: "index_demande_carte_allocataires_on_allocataire_id"
    t.index ["user_id"], name: "index_demande_carte_allocataires_on_user_id"
  end

  create_table "demande_pf_clotures", force: :cascade do |t|
    t.string "workflow_state"
    t.bigint "admin_agence_id"
    t.bigint "dossier_prestation_id"
    t.integer "soumis_par_id"
    t.integer "valide_par_id"
    t.integer "annuler_par_id"
    t.text "motif_annulation"
    t.date "date_validation"
    t.date "date_annulation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "motif"
    t.text "commentaire"
    t.index ["admin_agence_id"], name: "index_demande_pf_clotures_on_admin_agence_id"
    t.index ["dossier_prestation_id"], name: "index_demande_pf_clotures_on_dossier_prestation_id"
  end

  create_table "demande_remboursement_cotisations", force: :cascade do |t|
    t.bigint "user_id"
    t.string "numero_affiliation", null: false
    t.string "prenom", null: false
    t.string "nom", null: false
    t.date "date_naissance", null: false
    t.string "lieu_naissance", null: false
    t.string "email"
    t.string "adresse_reception_allocation"
    t.string "adresse_domicile"
    t.integer "mode_paiement"
    t.string "compte_bancaire_nom_banque"
    t.string "compte_bancaire_code_banque"
    t.string "compte_bancaire_code_guichet"
    t.string "compte_bancaire_numero_compte", limit: 50
    t.integer "motif_remboursement"
    t.string "periode_remboursement"
    t.boolean "etat_civil_demandeur_valide", default: false, null: false
    t.boolean "documents_valide", default: false, null: false
    t.boolean "remboursement_valide", default: false
    t.boolean "recap_remboursement_valide", default: false
    t.string "workflow_state"
    t.datetime "valider_le"
    t.integer "valider_par_id"
    t.integer "ajouter_par_id"
    t.integer "instruit_par_id"
    t.datetime "instruit_le"
    t.datetime "affecter_le"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.integer "affectation_salarie"
    t.datetime "affectation_salarie_date"
    t.datetime "affectation_allocataire_date"
    t.integer "affectation_allocataire"
    t.date "date_soumission"
    t.string "num_dossier"
    t.text "motif"
    t.datetime "debut_periode"
    t.datetime "fin_periode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_demande_remboursement_cotisations_on_user_id"
  end

  create_table "document_allocat_familiales", force: :cascade do |t|
    t.bigint "allocation_familiale_id"
    t.integer "type_document"
    t.text "commentaire"
    t.date "date_depot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_expiration_piece"
    t.index ["allocation_familiale_id"], name: "index_document_allocat_familiales_on_allocation_familiale_id"
  end

  create_table "document_dossier_maternites", force: :cascade do |t|
    t.bigint "dossier_maternite_id"
    t.integer "type_document"
    t.text "commentaire"
    t.date "date_depot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dossier_maternite_id"], name: "index_document_dossier_maternites_on_dossier_maternite_id"
  end

  create_table "document_dossier_prestations", force: :cascade do |t|
    t.bigint "dossier_prestation_id"
    t.integer "type_document"
    t.text "commentaire"
    t.date "date_depot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dossier_prestation_id"], name: "index_document_dossier_prestations_on_dossier_prestation_id"
  end

  create_table "document_immatriculations", force: :cascade do |t|
    t.text "commentaire"
    t.integer "type_document"
    t.bigint "immatriculation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["immatriculation_id"], name: "index_document_immatriculations_on_immatriculation_id"
  end

  create_table "document_liquidation_retraites", force: :cascade do |t|
    t.bigint "liquidation_retraite_id"
    t.integer "type_document", null: false
    t.text "commentaire"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["liquidation_retraite_id"], name: "index_document_liquidation_retraites_on_liquidation_retraite_id"
  end

  create_table "document_prestation_exterieures", force: :cascade do |t|
    t.bigint "prestation_exterieure_id"
    t.integer "type_document"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prestation_exterieure_id"], name: "prestation_exterieure_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "documentable_type", null: false
    t.bigint "documentable_id", null: false
    t.integer "type_document", null: false
    t.text "commentaire"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_expiration"
    t.date "date_delivrance_piece"
    t.index ["documentable_type", "documentable_id", "type_document"], name: "documents_documentable_type_idx"
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable_type_and_documentable_id"
  end

  create_table "donation_conjoints", force: :cascade do |t|
    t.bigint "liquidation_retraite_france_id"
    t.string "description"
    t.float "valeur_actuelle"
    t.string "situation_departement"
    t.string "nom_beneficiaire"
    t.string "adresse_beneficiaire"
    t.integer "quantite"
    t.date "date_donation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["liquidation_retraite_france_id"], name: "index_donation_conjoints_on_liquidation_retraite_france_id"
  end

  create_table "dossier_audit_activities", force: :cascade do |t|
    t.integer "ajoute_par_id"
    t.string "description"
    t.bigint "dossier_audits_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "incident"
    t.text "evaluation_incident"
    t.text "plan_actions"
    t.string "workflow_state"
    t.text "motif_rejet"
    t.integer "soumis_par_id"
    t.integer "valide_par_id"
    t.date "date_soumission"
    t.date "date_validation"
    t.boolean "is_ready", default: false
    t.index ["dossier_audits_id"], name: "index_dossier_audit_activities_on_dossier_audits_id"
  end

  create_table "dossier_audit_affectations", force: :cascade do |t|
    t.integer "affecte_par_id"
    t.integer "affecte_a_id"
    t.date "date_affectation"
    t.bigint "dossier_audits_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dossier_audits_id"], name: "index_dossier_audit_affectations_on_dossier_audits_id"
  end

  create_table "dossier_audits", force: :cascade do |t|
    t.string "num_dossier"
    t.string "description"
    t.string "motif"
    t.string "objectifs"
    t.string "etendu_controle"
    t.string "techniques_controle"
    t.date "date_debut"
    t.integer "ajoute_par_id"
    t.integer "soumis_par_id"
    t.integer "valide_par_id"
    t.date "date_soumission"
    t.date "date_validation"
    t.string "workflow_state"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "admin_agence_id"
    t.text "programme_travail"
    t.text "motif_rejet"
    t.integer "soumis_directeur_par_id"
    t.integer "cloture_par_id"
    t.date "date_cloture"
    t.date "date_soumission_directeur"
    t.index ["admin_agence_id"], name: "index_dossier_audits_on_admin_agence_id"
  end

  create_table "dossier_cnavs", force: :cascade do |t|
    t.string "numero_dossier"
    t.date "date_ouverture"
    t.integer "etat"
    t.integer "mois"
    t.integer "annee"
    t.string "motif_rejet"
    t.date "date_soumission"
    t.integer "soumis_par_id"
    t.date "date_validation"
    t.integer "valide_par_id"
    t.integer "ajoute_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "valider_liq_par_id"
    t.datetime "valider_liq_le"
    t.integer "valider_insp_par_id"
    t.datetime "valider_insp_le"
    t.integer "type_convention"
    t.integer "usage"
    t.integer "trimestre"
    t.index ["user_id"], name: "index_dossier_cnavs_on_user_id"
  end

  create_table "dossier_juridique_actes", force: :cascade do |t|
    t.integer "type_act"
    t.date "date_act"
    t.string "comment"
    t.bigint "dossier_juridique_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ajoute_par_id"
    t.index ["dossier_juridique_id"], name: "index_dossier_juridique_actes_on_dossier_juridique_id"
  end

  create_table "dossier_juridique_honoraires", force: :cascade do |t|
    t.integer "montant"
    t.string "nom_complet_juge"
    t.date "date_eff"
    t.bigint "dossier_juridique_id"
    t.bigint "avocats_huissier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ajoute_par_id"
    t.index ["avocats_huissier_id"], name: "index_dossier_juridique_honoraires_on_avocats_huissier_id"
    t.index ["dossier_juridique_id"], name: "index_dossier_juridique_honoraires_on_dossier_juridique_id"
  end

  create_table "dossier_juridiques", force: :cascade do |t|
    t.string "nom_dossier"
    t.string "num_dossier"
    t.string "description_dossier"
    t.string "objet_dossier"
    t.string "parties"
    t.string "requerent"
    t.string "defendeur"
    t.string "nature_litige"
    t.string "etat_procedure"
    t.string "agence_concerne"
    t.string "direction_concerne"
    t.string "montant_reclame"
    t.integer "ajoute_par_id"
    t.integer "soumis_par_id"
    t.date "date_soumission"
    t.integer "cloture_par_id"
    t.date "date_cloture"
    t.string "workflow_state"
    t.bigint "admin_type_dossier_juridique_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_debut_contrat"
    t.date "date_fin_contrat"
    t.text "motif_rejet"
    t.integer "rejete_par_id"
    t.date "date_rejet"
    t.index ["admin_type_dossier_juridique_id"], name: "index_dossier_juridiques_on_admin_type_dossier_juridique_id"
  end

  create_table "dossier_maternites", force: :cascade do |t|
    t.string "num_affiliation"
    t.string "prenom"
    t.string "nom"
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.string "adresse_domicile"
    t.boolean "etat_civil_demandeur_valid"
    t.boolean "carriere_valid"
    t.boolean "document_valid"
    t.bigint "user_id"
    t.date "debut_grossesse"
    t.integer "etat"
    t.date "date_soumission"
    t.integer "ajoute_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.string "motif_rejet"
    t.string "num_dossier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sexe_salarie"
    t.integer "montant_salaire", default: 0, null: false
    t.integer "montant_indemnite", default: 0, null: false
    t.date "debut_conges"
    t.string "telephone", limit: 30
    t.string "email"
    t.boolean "subrogation", default: false
    t.string "nin"
    t.boolean "attributaire", default: false
    t.string "nom_attributaire"
    t.string "prenom_attributaire"
    t.string "nin_attributaire"
    t.integer "mode_paiement"
    t.string "compte_bancaire_code_guichet"
    t.string "raison_sociale"
    t.string "num_immatriculation"
    t.string "tel_employeur"
    t.string "email_employeur"
    t.string "adresse_employeur"
    t.integer "tag_paiement_dossier"
    t.date "date_accouchement_prev"
    t.date "date_fin_cong_prev"
    t.integer "nbre_jr_repos"
    t.integer "nbre_jr_payes"
    t.integer "categorie_travail"
    t.date "date_embauche"
    t.text "rapport_controle"
    t.datetime "date_rapport"
    t.boolean "salaire_valid", default: false
    t.date "date_accouchement_reel"
    t.date "date_fin_cong_reel"
    t.integer "delai_stage", default: 0, null: false
    t.integer "suspendu_par_id"
    t.date "date_suspension"
    t.boolean "suspendu", default: false, null: false
    t.integer "cloture_par_id"
    t.date "date_cloture"
    t.boolean "cloture", default: false, null: false
    t.date "date_suspension_salaire"
    t.integer "type_piece"
    t.datetime "affectation_controleur_date"
    t.integer "affectation_controleur"
    t.datetime "date_rapport_joint"
    t.integer "nombre_part_impot"
    t.integer "valeur_impot"
    t.boolean "decedee", default: false
    t.date "date_deces"
    t.string "nom_mandataire"
    t.string "prenom_mandataire"
    t.string "nin_mandataire"
    t.integer "admin_banque_agence_id"
    t.string "compte_bancaire_cle_rib", limit: 2
    t.string "compte_bancaire_numero_compte", limit: 50
    t.string "commentaire_affectation_controleur"
    t.integer "jours_prolongation"
    t.integer "part_trimf"
    t.boolean "generation_paiement_encours", default: false
    t.boolean "est_repris", default: false, null: false
    t.integer "retourne_par_id"
    t.date "retourne_le"
    t.text "motif_retour"
    t.integer "soumis_par_id"
    t.integer "site"
    t.integer "old_dossier_maternite_id"
    t.text "documents_deposes_obligatoires", default: [], array: true
    t.text "documents_deposes_facultatifs", default: [], array: true
    t.integer "admin_agence_id"
    t.boolean "est_ir_trimf_applique", default: true
    t.integer "montant_ir"
    t.boolean "deleted", default: false
    t.boolean "incomplete", default: false
    t.integer "affecte_a_id"
    t.index ["deleted"], name: "dossier_maternites_deleted_idx"
    t.index ["incomplete"], name: "dossier_maternites_incomplete_idx"
    t.index ["user_id"], name: "index_dossier_maternites_on_user_id"
  end

  create_table "dossier_prestation_avis_tiers", force: :cascade do |t|
    t.integer "type_avis"
    t.integer "etat"
    t.float "montant_avis"
    t.float "montant_echeance"
    t.integer "ajouter_par_id"
    t.integer "soumis_par_id"
    t.integer "valider_par_id"
    t.date "date_soumission"
    t.date "date_validation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "retourner_par_id"
    t.date "date_retour"
    t.text "motif_retour"
    t.integer "status", default: 2
    t.bigint "dossier_prestation_id"
    t.integer "nature_avis"
    t.text "motif"
    t.integer "trimestre"
    t.integer "annee"
    t.integer "volet_post"
    t.integer "volet_pre"
    t.integer "conjoint_id"
    t.integer "enfant_id"
    t.string "numero_liquidation"
    t.date "date_liquidation"
    t.integer "traite_par_id"
    t.date "traite_le"
    t.index ["dossier_prestation_id"], name: "index_dossier_prestation_avis_tiers_on_dossier_prestation_id"
  end

  create_table "dossier_prestation_historics", force: :cascade do |t|
    t.bigint "dossier_prestation_id"
    t.bigint "admin_agence_id"
    t.string "employeur_matric"
    t.date "date_embauche"
    t.boolean "is_current"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "transfer_date"
    t.index ["admin_agence_id"], name: "index_dossier_prestation_historics_on_admin_agence_id"
    t.index ["dossier_prestation_id"], name: "index_dossier_prestation_historics_on_dossier_prestation_id"
  end

  create_table "dossier_prestations", force: :cascade do |t|
    t.integer "sexe_salarie"
    t.string "num_affiliation"
    t.string "prenom"
    t.string "nom"
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.string "adresse_domicile"
    t.string "etat"
    t.date "date_soumission"
    t.date "date_validation"
    t.integer "traite_par_id"
    t.boolean "etat_civil_demandeur_valid"
    t.boolean "carriere_valid"
    t.boolean "conjoint_valid"
    t.boolean "enfants_valid"
    t.boolean "document_valid"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "num_dossier"
    t.bigint "conjoint_id"
    t.text "motif_rejet"
    t.datetime "traite_le"
    t.integer "ajoute_par_id"
    t.date "date_enregistrement"
    t.string "full_name_conjoint"
    t.string "motif_retour"
    t.date "date_reception"
    t.date "date_ouverture"
    t.integer "suspendu_par_id"
    t.date "date_suspension"
    t.date "date_cloture"
    t.string "full_name_beneficiare"
    t.integer "nationalite"
    t.date "date_embauche"
    t.boolean "est_repris", default: false, null: false
    t.string "employeur_actuel", limit: 20
    t.string "nin"
    t.bigint "agence_id"
    t.string "telephone"
    t.integer "cloture_par_id"
    t.integer "affecte_a_id"
    t.boolean "deleted", default: false
    t.boolean "incomplete", default: false
    t.string "employeur_actuel_old"
    t.index ["agence_id"], name: "dossier_prestations_agence_id_idx"
    t.index ["conjoint_id"], name: "index_dossier_prestations_on_conjoint_id"
    t.index ["deleted"], name: "dossier_prestations_deleted_idx"
    t.index ["etat"], name: "dossier_prestations_etat_idx"
    t.index ["incomplete"], name: "dossier_prestations_incomplete_idx"
    t.index ["num_affiliation"], name: "dossier_prestations_num_affiliation_idx"
    t.index ["user_id"], name: "index_dossier_prestations_on_user_id"
  end

  create_table "dossier_reversion_salaries", force: :cascade do |t|
    t.bigint "base_reversion_salary_id"
    t.string "prenom", null: false
    t.string "nom", null: false
    t.date "date_naissance", null: false
    t.string "lieu_naissance"
    t.string "numero_affiliation", null: false
    t.string "adresse"
    t.integer "mode_paiement"
    t.string "compte_bancaire_code_guichet"
    t.string "adresse_reception_allocation"
    t.string "nom_tuteur"
    t.string "prenom_tuteur"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.boolean "eligible", default: false
    t.boolean "boolean", default: false
    t.bigint "conjoint_id"
    t.bigint "enfant_id"
    t.datetime "date_soumis"
    t.integer "ajoute_par_id"
    t.date "ajouter_le"
    t.integer "affecter_a"
    t.date "affecter_le"
    t.integer "instruit_par_id"
    t.date "instruit_le"
    t.integer "valider_par_id"
    t.date "valider_le"
    t.integer "affecter_salarie"
    t.integer "type_ayant_droit"
    t.string "numero_dossier", null: false
    t.integer "etat", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "etat_ayant_droit_valide", default: false
    t.boolean "documents_valide", default: false
    t.string "email"
    t.string "phone"
    t.date "date_mariage"
    t.integer "admin_banque_agence_id"
    t.string "compte_bancaire_cle_rib", limit: 2
    t.string "compte_bancaire_numero_compte", limit: 50
    t.date "date_ouverture"
    t.bigint "allocataire_id"
    t.string "motif_rejet_allocataire"
    t.integer "rejet_allocataire_par_id"
    t.datetime "date_rejet_allocataire"
    t.index ["allocataire_id"], name: "index_dossier_reversion_salaries_on_allocataire_id"
    t.index ["base_reversion_salary_id"], name: "index_dossier_reversion_salaries_on_base_reversion_salary_id"
    t.index ["conjoint_id"], name: "index_dossier_reversion_salaries_on_conjoint_id"
    t.index ["enfant_id"], name: "index_dossier_reversion_salaries_on_enfant_id"
  end

  create_table "echeance_caisse_dossiers", force: :cascade do |t|
    t.bigint "echeance_caisse_id"
    t.bigint "dossier_prestation_id"
    t.string "workflow_state", limit: 50
    t.string "employeur_actuel"
    t.string "num_affiliation"
    t.string "nin"
    t.string "prenom"
    t.string "nom"
    t.integer "nombre_enfants"
    t.integer "nombre_total_enfants_eligibles"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_naissance"
    t.integer "temps_presence_mois1", default: 18
    t.integer "temps_presence_mois2", default: 18
    t.integer "temps_presence_mois3", default: 18
    t.boolean "absence_justifie_mois1", default: false
    t.boolean "absence_justifie_mois2", default: false
    t.boolean "absence_justifie_mois3", default: false
    t.string "motif_absence_mois1"
    t.string "motif_absence_mois2"
    t.string "motif_absence_mois3"
    t.bigint "echeance_caisse_employeur_id"
    t.boolean "is_individual_payment", default: false
    t.integer "individual_payment_by"
    t.index ["created_at"], name: "echeance_caisse_dossiers_created_at_idx"
    t.index ["dossier_prestation_id"], name: "index_echeance_caisse_dossiers_on_dossier_prestation_id"
    t.index ["echeance_caisse_employeur_id"], name: "idx_ecd1"
    t.index ["echeance_caisse_id"], name: "index_echeance_caisse_dossiers_on_echeance_caisse_id"
    t.index ["employeur_actuel"], name: "index_echeance_caisse_dossiers_on_employeur_actuel"
    t.index ["num_affiliation"], name: "index_echeance_caisse_dossiers_on_num_affiliation"
  end

  create_table "echeance_caisse_dossiers_ade_port", id: false, force: :cascade do |t|
    t.string "matricule"
    t.string "prenom"
    t.string "nom"
    t.integer "nombre_enfant_payes"
    t.string "montant"
    t.string "numero_piece"
  end

  create_table "echeance_caisse_employeurs", force: :cascade do |t|
    t.bigint "echeance_caisse_id"
    t.string "workflow_state", limit: 50
    t.string "matric"
    t.string "raison_sociale"
    t.string "ipres_ancien_matric"
    t.string "css_ancien_matric"
    t.string "code_agence_css"
    t.string "code_agence_ipres"
    t.string "email_mandataire"
    t.string "telephone_mandataire"
    t.string "prenom_mandataire"
    t.string "nom_mandataire"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "temps_presence_valide", default: false
    t.text "motif_retour"
    t.index ["code_agence_css"], name: "index_echeance_caisse_employeurs_on_code_agence_css"
    t.index ["code_agence_ipres"], name: "index_echeance_caisse_employeurs_on_code_agence_ipres"
    t.index ["css_ancien_matric"], name: "index_echeance_caisse_employeurs_on_css_ancien_matric"
    t.index ["echeance_caisse_id"], name: "index_echeance_caisse_employeurs_on_echeance_caisse_id"
    t.index ["ipres_ancien_matric"], name: "index_echeance_caisse_employeurs_on_ipres_ancien_matric"
    t.index ["matric"], name: "index_echeance_caisse_employeurs_on_matric"
  end

  create_table "echeance_caisse_enfants", force: :cascade do |t|
    t.bigint "echeance_caisse_id"
    t.bigint "dossier_prestation_id"
    t.bigint "echeance_caisse_dossier_id"
    t.bigint "enfant_id"
    t.integer "mois"
    t.float "montant", default: 2600.0
    t.boolean "document_valide", default: false
    t.integer "numero_ordre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "liquide", default: false
    t.boolean "paiement_individuel", default: false
    t.boolean "payable", default: true
    t.index ["created_at"], name: "echeance_caisse_enfants_created_at_idx"
    t.index ["dossier_prestation_id"], name: "index_echeance_caisse_enfants_on_dossier_prestation_id"
    t.index ["echeance_caisse_dossier_id"], name: "index_echeance_caisse_enfants_on_echeance_caisse_dossier_id"
    t.index ["echeance_caisse_id"], name: "index_echeance_caisse_enfants_on_echeance_caisse_id"
    t.index ["enfant_id"], name: "index_echeance_caisse_enfants_on_enfant_id"
    t.index ["mois"], name: "index_echeance_caisse_enfants_on_mois"
  end

  create_table "echeance_caisse_liquidations", force: :cascade do |t|
    t.bigint "echeance_caisse_employeur_id"
    t.bigint "echeance_caisse_enfant_id"
    t.boolean "liquide", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "compta_transaction_id"
    t.bigint "echeance_caisse_lot_liquidation_id"
    t.index ["echeance_caisse_employeur_id"], name: "idx_ece1"
    t.index ["echeance_caisse_enfant_id"], name: "idx_ece2"
    t.index ["echeance_caisse_lot_liquidation_id"], name: "idx_ecl_eclt1"
  end

  create_table "echeance_caisse_lot_liquidations", force: :cascade do |t|
    t.bigint "echeance_caisse_id"
    t.bigint "echeance_caisse_employeur_id"
    t.boolean "liquide", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "liquide_par_id"
    t.integer "valide_ca_par_id"
    t.integer "valide_comptable_par_id"
    t.date "date_liquidation"
    t.date "date_validation_ca"
    t.date "date_validation_comptable"
    t.index ["echeance_caisse_employeur_id"], name: "idx_eclt_ece1"
    t.index ["echeance_caisse_id", "echeance_caisse_employeur_id"], name: "index_echeance_caisse_lot_on_echeance_caisse_and_employeur", unique: true, where: "(liquide = false)"
    t.index ["echeance_caisse_id"], name: "idx_eclt_ec1"
  end

  create_table "echeance_caisses", force: :cascade do |t|
    t.integer "annee"
    t.integer "trimestre"
    t.string "workflow_state", limit: 50
    t.date "periode_debut"
    t.date "periode_fin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "echeance_paiements", force: :cascade do |t|
    t.integer "annee"
    t.integer "periode", default: 1
    t.integer "numero_periode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "workflow_state"
    t.datetime "valider_le"
    t.integer "validation_par_id"
    t.integer "traite_par_id"
    t.datetime "traite_le"
    t.integer "instruit_par"
    t.integer "liquider_par"
    t.integer "valider_service_par"
    t.integer "valider_chef_section_par"
    t.datetime "instruit_le"
    t.datetime "liquider_le"
    t.datetime "valider_service_le"
    t.datetime "valider_chef_section_le"
    t.boolean "validation_instruction"
    t.boolean "validation_liquidation"
    t.datetime "periode_variation_debut"
    t.datetime "periode_variation_fin"
    t.boolean "send_to_compta", default: false, null: false
    t.boolean "est_repris", default: false, null: false
  end

  create_table "echeance_veuves_caisse_enfants", force: :cascade do |t|
    t.bigint "echeance_veuves_caisse_id"
    t.bigint "dossier_prestation_id"
    t.bigint "echeance_veuves_caisse_epouse_id"
    t.bigint "enfant_id"
    t.integer "mois"
    t.float "montant", default: 2600.0
    t.boolean "document_valide", default: false
    t.boolean "liquide", default: false
    t.integer "numero_ordre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "conjoint_id"
    t.index ["conjoint_id"], name: "index_echeance_veuves_caisse_enfants_on_conjoint_id"
    t.index ["dossier_prestation_id"], name: "index_echeance_veuves_caisse_enfants_on_dossier_prestation_id"
    t.index ["echeance_veuves_caisse_epouse_id"], name: "echeance_caisse_epouse_id"
    t.index ["echeance_veuves_caisse_id"], name: "echeance_caisse_id"
    t.index ["enfant_id"], name: "index_echeance_veuves_caisse_enfants_on_enfant_id"
    t.index ["mois"], name: "index_echeance_veuves_caisse_enfants_on_mois"
  end

  create_table "echeance_veuves_caisse_epouses", force: :cascade do |t|
    t.bigint "echeance_veuves_caisse_id"
    t.string "workflow_state", limit: 50
    t.string "numero_affiliation"
    t.integer "conjoint_id"
    t.string "agence_id"
    t.string "prenom"
    t.string "nom"
    t.string "nin"
    t.integer "nombre_enfants"
    t.integer "nombre_total_enfants_eligibles"
    t.date "date_naissance"
    t.boolean "est_repris"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "admin_agence_id"
    t.bigint "dossier_prestation_id"
    t.index ["admin_agence_id"], name: "index_echeance_veuves_caisse_epouses_on_admin_agence_id"
    t.index ["agence_id"], name: "index_echeance_veuves_caisse_epouses_on_agence_id"
    t.index ["conjoint_id"], name: "index_echeance_veuves_caisse_epouses_on_conjoint_id"
    t.index ["dossier_prestation_id"], name: "index_echeance_veuves_caisse_epouses_on_dossier_prestation_id"
    t.index ["echeance_veuves_caisse_id"], name: "echeance_veuves_caisse_id"
    t.index ["numero_affiliation"], name: "index_echeance_veuves_caisse_epouses_on_numero_affiliation"
  end

  create_table "echeance_veuves_caisse_liquidations", force: :cascade do |t|
    t.bigint "echeance_veuves_caisse_lot_liquidation_id"
    t.bigint "echeance_veuves_caisse_enfant_id"
    t.integer "compta_transaction_id"
    t.boolean "liquide", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["compta_transaction_id"], name: "idx_cp_trans"
    t.index ["echeance_veuves_caisse_enfant_id"], name: "idx_ech_liq"
    t.index ["echeance_veuves_caisse_lot_liquidation_id"], name: "idx_ech_lot_liq"
  end

  create_table "echeance_veuves_caisse_lot_liquidations", force: :cascade do |t|
    t.bigint "echeance_veuves_caisse_id"
    t.boolean "liquide", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "liquide_par_id"
    t.integer "valide_ca_par_id"
    t.integer "valide_comptable_par_id"
    t.date "date_liquidation"
    t.date "date_validation_ca"
    t.date "date_validation_comptable"
    t.index ["echeance_veuves_caisse_id"], name: "idx_ech_ve"
  end

  create_table "echeance_veuves_caisses", force: :cascade do |t|
    t.integer "annee"
    t.integer "trimestre"
    t.string "workflow_state", limit: 50
    t.date "periode_debut"
    t.date "periode_fin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "motif_retour"
  end

  create_table "employeur_exterieurs", force: :cascade do |t|
    t.string "prenom_employeur"
    t.string "nom_employeur"
    t.string "raison_sociale"
    t.string "email"
    t.string "adresse"
    t.string "telephone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "enfants", force: :cascade do |t|
    t.bigint "user_id"
    t.string "prenom", null: false
    t.string "nom", null: false
    t.date "date_naissance", null: false
    t.string "nom_mere"
    t.string "prenom_mere"
    t.string "nom_pere"
    t.string "prenom_pere"
    t.integer "etat", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "conjoint_id"
    t.string "numero_affiliation"
    t.integer "ajoute_par_id"
    t.integer "origine_enfant"
    t.integer "type_piece"
    t.string "numero_piece"
    t.string "nom_salarie"
    t.string "prenom_salarie"
    t.string "full_name_conjoint"
    t.integer "sexe"
    t.string "numero_registre"
    t.string "code_etat_civil"
    t.string "nom_mere_naturel"
    t.string "prenom_mere_naturel"
    t.string "nin_generer"
    t.string "lieu_naissance"
    t.date "date_delivrance_piece"
    t.date "date_transcription"
    t.date "date_expiration_piece"
    t.date "date_deces"
    t.boolean "est_repris", default: false, null: false
    t.string "old_conjoint_id", limit: 250
    t.string "old_id", limit: 250
    t.string "old_created_par", limit: 100
    t.date "date_declaration_deces"
    t.date "migrated_document_exp_date"
    t.date "date_debut_eligibilite_af"
    t.date "date_fin_eligibilite_af"
    t.integer "reprise_site"
    t.boolean "deleted", default: false
    t.boolean "incomplete", default: false
    t.index ["conjoint_id"], name: "index_enfants_on_conjoint_id"
    t.index ["date_debut_eligibilite_af"], name: "enfants_date_debut_eligibilite_af_idx"
    t.index ["date_deces"], name: "enfants_date_deces_idx"
    t.index ["date_expiration_piece"], name: "enfants_date_expiration_piece_idx"
    t.index ["date_fin_eligibilite_af"], name: "enfants_date_fin_eligibilite_af_idx"
    t.index ["date_naissance"], name: "enfants_date_naissance_idx"
    t.index ["deleted"], name: "enfants_deleted_idx"
    t.index ["incomplete"], name: "enfants_incomplete_idx"
    t.index ["migrated_document_exp_date"], name: "enfants_migrated_document_exp_date_idx"
    t.index ["numero_affiliation"], name: "enfants_numero_affiliation_idx"
    t.index ["old_id"], name: "enfants_old_id_idx"
    t.index ["origine_enfant"], name: "enfants_origine_enfant_idx"
    t.index ["user_id"], name: "index_enfants_on_user_id"
  end

  create_table "enrolement_regularisation_pointage_lignes", force: :cascade do |t|
    t.bigint "enrolement_regularisation_pointage_id"
    t.bigint "allocataire_id"
    t.boolean "supprime", default: false
    t.boolean "comptabilise", default: false
    t.integer "supprime_par_id"
    t.datetime "supprime_le"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "numero_allocataire", limit: 30
    t.string "source", limit: 3
    t.integer "pointage_id"
    t.string "source_matching", limit: 50
    t.string "pres_prenom", limit: 250
    t.string "pres_nom", limit: 250
    t.string "pres_date_naissance", limit: 15
    t.string "enr_prenom", limit: 250
    t.string "enr_nom", limit: 250
    t.string "enr_date_naissance", limit: 15
    t.index ["allocataire_id"], name: "idx_regularisation_pointage_lignes_on_allocataire_id"
    t.index ["comptabilise"], name: "index_enrolement_regularisation_pointage_lignes_on_comptabilise"
    t.index ["enrolement_regularisation_pointage_id"], name: "idx_regularisation_pointage_lignes_on_rp_id"
    t.index ["supprime"], name: "index_enrolement_regularisation_pointage_lignes_on_supprime"
  end

  create_table "enrolement_regularisation_pointages", force: :cascade do |t|
    t.string "workflow_state"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "error_missing_lignes", force: :cascade do |t|
    t.string "nom"
    t.string "prenom"
    t.string "matricule"
    t.string "message"
    t.bigint "missing_declaration_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["missing_declaration_id"], name: "index_error_missing_lignes_on_missing_declaration_id"
  end

  create_table "extinction_allocataires", force: :cascade do |t|
    t.string "numero_allocataire"
    t.date "date_soumission"
    t.integer "ajoute_par_id"
    t.date "date_validation"
    t.integer "valide_par_id"
    t.string "motif_extinction"
    t.integer "affectation_allocataire"
    t.date "affectation_allocataire_date"
    t.integer "etat"
    t.string "motif_rejet"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.string "workflow_state"
    t.integer "verifie_par_id"
    t.datetime "date_verification"
    t.boolean "information_valide"
    t.boolean "document_valide"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date_deces"
  end

  create_table "factures", force: :cascade do |t|
    t.string "reference_facture"
    t.date "date_facture"
    t.date "periode"
    t.date "echeance"
    t.float "montant"
    t.float "solde"
    t.bigint "declaration_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "statut", default: 0
    t.date "date_paiement"
    t.bigint "moratoire_id"
    t.bigint "user_id"
    t.date "date_debut"
    t.date "date_fin"
    t.float "montant_principal"
    t.float "majorations"
    t.float "dette"
    t.float "penalite"
    t.float "montant_verse"
    t.float "dette_input"
    t.float "montant_paye"
    t.string "type_facture"
    t.string "url"
    t.index ["declaration_id"], name: "index_factures_on_declaration_id"
  end

  create_table "gestion_retours", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grossesses", force: :cascade do |t|
    t.bigint "dossier_prestation_id", null: false
    t.date "date_grossesse", null: false
    t.integer "etat", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_interruption"
    t.boolean "est_repris", default: false
    t.integer "old_grossesse_id"
    t.index ["dossier_prestation_id"], name: "index_grossesses_on_dossier_prestation_id"
  end

  create_table "historic_ech_exclusions", force: :cascade do |t|
    t.bigint "echeance_caisse_id"
    t.bigint "echeance_caisse_employeur_id"
    t.bigint "dossier_presttaion_id"
    t.integer "ajoute_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dossier_presttaion_id"], name: "index_historic_ech_exclusions_on_dossier_presttaion_id"
    t.index ["echeance_caisse_employeur_id"], name: "index_historic_ech_exclusions_on_echeance_caisse_employeur_id"
    t.index ["echeance_caisse_id"], name: "index_historic_ech_exclusions_on_echeance_caisse_id"
  end

  create_table "historiques", force: :cascade do |t|
    t.date "date_valide"
    t.date "date_soumission"
    t.date "date_suspension"
    t.date "date_reversion"
    t.date "date_extinction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "allocataire_id"
    t.integer "user_id"
    t.integer "etat"
    t.date "date_lever_suspension"
    t.string "evenement"
    t.string "field"
    t.string "new_value"
    t.string "old_value"
    t.index ["allocataire_id"], name: "historiques_allocataire_id_idx"
  end

  create_table "icm_modifier_info_personnelles", force: :cascade do |t|
    t.integer "dossier_maternite_id"
    t.string "prenom"
    t.string "nom"
    t.string "sexe"
    t.string "nin"
    t.string "type_piece"
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.string "email"
    t.string "telephone"
    t.string "adresse_domicile"
    t.datetime "debut_grossesse"
    t.datetime "debut_conges"
    t.datetime "date_suspension_salaire"
    t.integer "mode_paiement"
    t.integer "etat", default: 0, null: false
    t.integer "ajoute_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "immatriculation_societes", force: :cascade do |t|
    t.string "raison_sociale"
    t.integer "type_etablissement"
    t.integer "type_immatriculation"
    t.integer "ninea"
    t.bigint "ninet"
    t.string "registre_commerce"
    t.integer "statut_juridique"
    t.string "code_identification_fiscale"
    t.datetime "date_immatriculation"
    t.datetime "date_identification_fiscale"
    t.datetime "date_identification_rc"
    t.datetime "date_ouverture"
    t.string "siege_social"
    t.integer "activite_principale"
    t.integer "secteur_activite"
    t.string "website"
    t.string "zoneCss"
    t.string "zoneIpres"
    t.string "sectorCss"
    t.string "sectorIpres"
    t.string "agencyCss"
    t.string "agencyIpres"
    t.integer "effectif_employe"
    t.integer "effectif_cadre"
    t.date "embauche_cadre"
    t.date "embauche_employer"
    t.bigint "process_flow_id"
    t.bigint "employer_registration_form_id"
    t.bigint "employee_registration_form_id"
    t.text "message"
    t.integer "type_of_identity"
    t.string "boite_postale"
    t.string "sigle"
    t.string "statut_demande"
    t.integer "region"
    t.integer "commune"
    t.integer "quartier"
    t.string "address"
    t.string "landLineNumber"
    t.string "mobileNumber"
    t.string "email"
    t.boolean "etat_civil_demandeur_valide", default: false, null: false
    t.boolean "representant_valide", default: false, null: false
    t.boolean "salarie_valide", default: false, null: false
    t.boolean "documents_valide", default: false, null: false
    t.integer "etat", default: 1, null: false
    t.date "date_soumission"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "departement"
    t.integer "ville"
    t.string "adresse"
    t.integer "type_employeur"
    t.float "taux_at"
    t.string "url"
    t.index ["user_id"], name: "index_immatriculation_societes_on_user_id"
  end

  create_table "immatriculations", force: :cascade do |t|
    t.integer "type_immatriculation"
    t.integer "type_employeur"
    t.string "raison_sociale"
    t.integer "type_etablissement"
    t.string "ninea"
    t.string "ninet"
    t.string "registre_commerce"
    t.integer "statut_juridique"
    t.string "code_identification_fiscale"
    t.datetime "date_immatriculation"
    t.datetime "date_identification_fiscale"
    t.datetime "date_identification_rc"
    t.datetime "date_ouverture"
    t.string "siege_social"
    t.integer "activite_principale"
    t.integer "secteur_activite"
    t.string "email_employeur"
    t.string "adresse"
    t.string "telephone_employeur"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "etat_civil_demandeur_valide", default: false, null: false
    t.boolean "representant_valide", default: false, null: false
    t.boolean "salarie_valide", default: false, null: false
    t.boolean "documents_valide", default: false, null: false
    t.integer "etat", default: 1, null: false
    t.date "date_soumission"
    t.integer "region", default: 0
    t.integer "departement", default: 0
    t.integer "ville", default: 0
    t.integer "commune", default: 0
    t.integer "quartier", default: 0
    t.bigint "user_id"
    t.string "nom"
    t.string "prenom"
    t.string "website"
    t.string "zoneCss"
    t.string "zoneIpres"
    t.string "sectorCss"
    t.string "sectorIpres"
    t.string "agencyCss"
    t.string "agencyIpres"
    t.string "lastName"
    t.string "firstName"
    t.date "birthdate"
    t.integer "nationality"
    t.integer "nin"
    t.string "placeOfBirth"
    t.string "cityOfBirth"
    t.string "identityIdNumber"
    t.integer "ninCedeo"
    t.string "region_legal"
    t.string "department_legal"
    t.string "arondissement_legal"
    t.string "commune_legal"
    t.string "qartier_legal"
    t.string "address_legal"
    t.string "landLineNumber"
    t.string "mobileNumber"
    t.string "email"
    t.date "issuedDate"
    t.date "expiryDate"
    t.integer "effectif_employe"
    t.integer "effectif_cadre"
    t.date "embauche_cadre"
    t.date "embauche_employer"
    t.bigint "process_flow_id"
    t.bigint "employer_registration_form_id"
    t.bigint "employee_registration_form_id"
    t.text "message"
    t.integer "type_of_identity"
    t.string "boite_postale"
    t.string "sigle"
    t.string "statut_demande"
  end

  create_table "indemnite_conges_maternite_migrees", force: :cascade do |t|
    t.integer "dossier_maternite_id"
    t.integer "montant_paiement"
    t.integer "num_tranche"
    t.integer "jours_prolongation"
    t.integer "numdro_liquidation"
    t.date "debut_grossesse"
    t.date "debut_conges"
    t.date "date_accouchement"
    t.date "date_reprise_service"
    t.date "date_liquidation"
    t.date "date_reprise_reelle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "indemnite_conges_maternites", force: :cascade do |t|
    t.date "date_soumission"
    t.date "date_validation"
    t.integer "valide_par_id"
    t.bigint "user_id"
    t.integer "ajoute_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.string "motif_rejet"
    t.integer "montant_paiement"
    t.integer "etat"
    t.integer "tranche_paiement"
    t.date "debut_conges"
    t.date "date_accouchement"
    t.date "date_reprise_service"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date_paiement"
    t.datetime "date_liquidation"
    t.integer "dossier_maternite_id"
    t.string "numero_liquidation"
    t.boolean "paiement", default: false, null: false
    t.string "rapport_controle"
    t.float "impot_ir"
    t.float "impot_trimf"
    t.integer "paiement_id"
    t.date "date_echeance"
    t.integer "nbre_jr_repos", default: 0, null: false
    t.integer "nbre_jr_payes", default: 0, null: false
    t.integer "num_tranche", default: 1
    t.boolean "decedee", default: false
    t.date "date_deces"
    t.string "nom_mandataire"
    t.string "prenom_mandataire"
    t.string "nin_mandataire"
    t.boolean "cas_force_majeur", default: false
    t.bigint "ordre_paiement_id"
    t.integer "lieu_accouchement"
    t.datetime "date_rapport"
    t.boolean "prolongation", default: false
    t.datetime "date_reprise_reelle"
    t.integer "jours_prolongation"
    t.boolean "est_repris", default: false, null: false
    t.integer "retourne_par_id"
    t.date "retourne_le"
    t.text "motif_retour"
    t.index ["ordre_paiement_id"], name: "index_indemnite_conges_maternites_on_ordre_paiement_id"
    t.index ["user_id"], name: "index_indemnite_conges_maternites_on_user_id"
  end

  create_table "indemnites_prestation_exterieure_assocs", force: :cascade do |t|
    t.bigint "indemnites_prestation_exterieure_id"
    t.bigint "caf_enfant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ordre_paiement_id"
    t.index ["caf_enfant_id"], name: "index_indemnites_prestation_exterieure_assocs_on_caf_enfant_id"
    t.index ["indemnites_prestation_exterieure_id"], name: "indemnite_id"
    t.index ["ordre_paiement_id"], name: "index_ipe_assocs_on_op_id"
  end

  create_table "indemnites_prestation_exterieures", force: :cascade do |t|
    t.float "montant"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_debut"
    t.date "date_fin"
    t.string "workflow_state_dt"
    t.date "date_liquidation"
    t.date "date_validation_chef_grp"
    t.date "date_validation_chef_sub"
    t.date "date_validation_cpt"
    t.integer "liquide_par_id"
    t.integer "valide_chef_grp_par_id"
    t.integer "valide_chef_sub_par_id"
    t.integer "valide_cpt_par_id"
    t.bigint "prestation_exterieure_id"
    t.boolean "est_repris", default: false
    t.boolean "paiement", default: false
    t.string "motif_retour"
    t.date "date_retour"
    t.integer "retourne_par_id"
    t.index ["prestation_exterieure_id"], name: "prestation_id"
  end

  create_table "lastep", id: false, force: :cascade do |t|
    t.integer "DERNIEREENTREPRISE"
    t.text "RAISONSOCIALE"
    t.text "ADRESSE"
    t.integer "T�l�phone"
    t.text "BP"
  end

  create_table "ligne_pf_avis_tier_transactions", force: :cascade do |t|
    t.bigint "dossier_prestation_avis_tiers_id"
    t.bigint "ordre_paiements_id"
    t.float "montant"
    t.integer "ajoute_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "montant_paye"
    t.index ["dossier_prestation_avis_tiers_id"], name: "avis_tiers_is"
    t.index ["ordre_paiements_id"], name: "index_ligne_pf_avis_tier_transactions_on_ordre_paiements_id"
  end

  create_table "liq_enf_nor_veuf", id: false, force: :cascade do |t|
    t.string "code_site", limit: 2500
    t.string "libelle_site", limit: 2500
    t.string "nin_enfant", limit: 2500
    t.string "prenom_enfant", limit: 2500
    t.string "nom_enfant", limit: 2500
    t.string "nin_allocataire", limit: 2500
    t.string "prenom_allocataire", limit: 2500
    t.string "nom_allocataire", limit: 2500
    t.string "sexe_enfant", limit: 2500
    t.string "sexe_allocataire", limit: 2500
    t.string "date_naissance_enfant", limit: 2500
    t.string "date_naissance_allocataire", limit: 2500
    t.string "type_prestation", limit: 2500
    t.string "nin_beneficiaire", limit: 2500
    t.string "prenom_beneficiaire", limit: 2500
    t.string "nom_beneficiaire", limit: 2500
    t.string "sexe_beneficiaire", limit: 2500
    t.string "statut_beneficiaire", limit: 2500
    t.string "num_liquidation", limit: 2500
    t.string "date_depot_dossier", limit: 2500
    t.string "date_liquidation", limit: 2500
    t.string "montant_liquidation", limit: 2500
    t.string "date_paiement", limit: 2500
    t.string "montant_paye_pour_la_liquidation", limit: 2500
    t.string "annee_de_liquidation", limit: 2500
    t.string "montant_liquide_est_il_paye", limit: 2500
    t.string "date_fin_prestation", limit: 2500
    t.string "motif_fin_prestation", limit: 2500
    t.string "old_id", limit: 2500
    t.string "num_dossier", limit: 2500
  end

  create_table "liquidation_retraite_frances", force: :cascade do |t|
    t.bigint "user_id"
    t.string "numero_affiliation", null: false
    t.string "prenom", null: false
    t.string "nom", null: false
    t.date "date_naissance", null: false
    t.string "lieu_naissance", null: false
    t.string "adresse_reception_allocation"
    t.string "adresse_domicile"
    t.integer "mode_paiement"
    t.string "compte_bancaire_numero_compte", limit: 50
    t.integer "etat", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "etat_civil_demandeur_valide", default: false, null: false
    t.boolean "epouses_valide", default: false, null: false
    t.boolean "enfants_valide", default: false, null: false
    t.boolean "carriere_valide", default: false, null: false
    t.boolean "documents_valide", default: false, null: false
    t.date "date_cessation_activite"
    t.datetime "date_soumission"
    t.integer "type_retraite", default: 1, null: false
    t.date "date_jouissance"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.text "motif"
    t.integer "ajoute_par_id"
    t.datetime "affectation_allocataire_date"
    t.integer "affectation_allocataire"
    t.boolean "recap_point_valide", default: false
    t.integer "affectation_salarie"
    t.datetime "affectation_salarie_date"
    t.string "workflow_state"
    t.integer "instruit_par_id"
    t.datetime "instruit_le"
    t.integer "valider_par_id"
    t.datetime "valider_le"
    t.string "email", default: ""
    t.string "num_dossier"
    t.bigint "allocataire_id"
    t.integer "motif_remboursement"
    t.string "periode_remboursement"
    t.boolean "remboursement_cotisation", default: false
    t.date "debut_periode"
    t.date "fin_periode"
    t.string "telephone"
    t.datetime "date_soumission_carriere"
    t.datetime "date_validation_carriere"
    t.datetime "date_soumission_validation"
    t.datetime "date_validation_liquidation"
    t.integer "soumission_carriere_par"
    t.integer "validation_carriere_par"
    t.integer "soumission_validation_par"
    t.integer "validation_liquidation_par"
    t.integer "admin_banque_id"
    t.text "commentaire"
    t.integer "admin_banque_agence_id"
    t.string "compte_bancaire_cle_rib", limit: 2
    t.integer "zone"
    t.bigint "admin_region_id"
    t.integer "sexe", default: 1
    t.datetime "date_generation"
    t.bigint "admin_agence_id"
    t.string "adresse_paiement"
    t.string "commentaire_soumission"
    t.string "commentaire_instruction"
    t.string "commentaire_carriere"
    t.string "commentaire_validation_carriere"
    t.string "commentaire_tableau"
    t.string "commentaire_validation_tableau"
    t.string "commentaire_validation"
    t.string "commentaire_affectation_salaire"
    t.string "commentaire_affectation_allocataire"
    t.integer "agence_creation_id"
    t.datetime "date_ouverture"
    t.datetime "update_fullname_date"
    t.integer "update_fullname_id"
    t.string "update_fullname_commentaire"
    t.boolean "not_completed", default: false
    t.integer "motif_not_completed"
    t.text "documents_deposes_obligatoires", default: [], array: true
    t.text "documents_deposes_facultatifs", default: [], array: true
    t.string "motif_rejet_allocataire"
    t.integer "rejet_allocataire_par_id"
    t.datetime "date_rejet_allocataire"
    t.string "nom_jeune_fille"
    t.string "prenom_pere"
    t.string "prenom_mere"
    t.string "nom_pere"
    t.string "nom_mere"
    t.integer "nationalite_id", null: false
    t.integer "situation_familiale"
    t.date "date_mariage"
    t.date "date_situation_fam"
    t.string "adresse_residence"
    t.boolean "inapte", default: false, null: false
    t.date "date_depart_inapt"
    t.date "date_decision_inapt"
    t.boolean "titulaire_pens_invalidite", default: false
    t.boolean "titre_reg_gl", default: false
    t.boolean "titre_reg_agric", default: false
    t.boolean "titre_reg_minier", default: false
    t.boolean "titre_reg_special", default: false
    t.string "institution_reg_spec"
    t.string "num_pension_inapt"
    t.date "date_cess_act_sn"
    t.integer "total_an_carriere_sn", default: 0
    t.date "date_cess_act_fr"
    t.integer "total_an_carriere_fr", default: 0
    t.integer "sens_convention", null: false
    t.integer "decide_points", default: 0
    t.integer "decide_montant_annuel", default: 0
    t.integer "precision_carriere"
    t.date "decide_date"
    t.boolean "activite_prof_valid", default: false, null: false
    t.boolean "assur_residence_valid", default: false, null: false
    t.boolean "assur_second_pays_valid", default: false, null: false
    t.boolean "charge_second_pays_valid", default: false, null: false
    t.string "numero_piece"
    t.integer "type_piece"
    t.string "numero_securite_sociale", null: false
    t.string "adresse_postale"
    t.boolean "ressources_conjoint_valid"
    t.boolean "carriere_conjoint", default: false
    t.float "salaire_trimestre_conjoint"
    t.float "salaire_annuel_conjoint"
    t.date "date_cess_act_conjoint"
    t.boolean "avantage_viellesse_conjoint", default: false
    t.integer "nature_avantage_conjoint"
    t.string "nom_instit_deb_conjoint"
    t.string "adresse_instit_deb_conjoint"
    t.string "numero_pension_conjoint"
    t.float "montant_pension_conjoint"
    t.boolean "autres_revenus_conjoint", default: false
    t.boolean "biens_perso_conjoint", default: false
    t.boolean "biens_donation_conjoint", default: false
    t.boolean "affiliation", default: false
    t.integer "situation_matrimoniale"
    t.boolean "numero_trouve", default: false
    t.integer "regime_matrimoniale"
    t.integer "nombre_femmes"
    t.index ["admin_agence_id"], name: "index_liquidation_retraite_frances_on_admin_agence_id"
    t.index ["admin_region_id"], name: "index_liquidation_retraite_frances_on_admin_region_id"
    t.index ["allocataire_id"], name: "index_liquidation_retraite_frances_on_allocataire_id"
    t.index ["num_dossier"], name: "index_liquidation_retraite_frances_on_num_dossier", unique: true
    t.index ["user_id"], name: "index_liquidation_retraite_frances_on_user_id"
  end

  create_table "liquidation_retraites", force: :cascade do |t|
    t.bigint "user_id"
    t.string "numero_affiliation", null: false
    t.string "prenom", null: false
    t.string "nom", null: false
    t.date "date_naissance", null: false
    t.string "lieu_naissance", null: false
    t.string "adresse_reception_allocation"
    t.string "adresse_domicile"
    t.integer "mode_paiement"
    t.string "compte_bancaire_numero_compte", limit: 50
    t.integer "etat", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "etat_civil_demandeur_valide", default: false, null: false
    t.boolean "epouses_valide", default: false, null: false
    t.boolean "enfants_valide", default: false, null: false
    t.boolean "carriere_valide", default: false, null: false
    t.boolean "documents_valide", default: false, null: false
    t.date "date_cessation_activite"
    t.datetime "date_soumission"
    t.integer "type_retraite", default: 1, null: false
    t.date "date_jouissance"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.text "motif"
    t.integer "ajoute_par_id"
    t.datetime "affectation_allocataire_date"
    t.integer "affectation_allocataire"
    t.boolean "recap_point_valide", default: false
    t.integer "affectation_salarie"
    t.datetime "affectation_salarie_date"
    t.string "workflow_state"
    t.integer "instruit_par_id"
    t.datetime "instruit_le"
    t.integer "valider_par_id"
    t.datetime "valider_le"
    t.string "email", default: ""
    t.string "num_dossier"
    t.integer "motif_remboursement"
    t.string "periode_remboursement"
    t.boolean "remboursement_cotisation", default: false
    t.date "debut_periode"
    t.date "fin_periode"
    t.bigint "allocataire_id"
    t.string "telephone"
    t.datetime "date_soumission_carriere"
    t.datetime "date_validation_carriere"
    t.datetime "date_soumission_validation"
    t.datetime "date_validation_liquidation"
    t.integer "soumission_carriere_par"
    t.integer "validation_carriere_par"
    t.integer "soumission_validation_par"
    t.integer "validation_liquidation_par"
    t.integer "admin_banque_id"
    t.text "commentaire"
    t.integer "admin_banque_agence_id"
    t.string "compte_bancaire_cle_rib", limit: 2
    t.integer "zone"
    t.bigint "admin_region_id"
    t.integer "sexe", default: 1
    t.datetime "date_generation"
    t.bigint "admin_agence_id"
    t.string "adresse_paiement"
    t.string "commentaire_soumission"
    t.string "commentaire_instruction"
    t.string "commentaire_carriere"
    t.string "commentaire_validation_carriere"
    t.string "commentaire_tableau"
    t.string "commentaire_validation_tableau"
    t.string "commentaire_validation"
    t.string "commentaire_affectation_salaire"
    t.string "commentaire_affectation_allocataire"
    t.integer "agence_creation_id"
    t.datetime "date_ouverture"
    t.datetime "update_fullname_date"
    t.integer "update_fullname_id"
    t.string "update_fullname_commentaire"
    t.boolean "not_completed", default: false
    t.integer "motif_not_completed"
    t.text "documents_deposes_obligatoires", default: [], array: true
    t.text "documents_deposes_facultatifs", default: [], array: true
    t.string "motif_rejet_allocataire"
    t.integer "rejet_allocataire_par_id"
    t.datetime "date_rejet_allocataire"
    t.string "cip_id"
    t.index ["admin_agence_id"], name: "index_liquidation_retraites_on_admin_agence_id"
    t.index ["admin_region_id"], name: "index_liquidation_retraites_on_admin_region_id"
    t.index ["allocataire_id"], name: "index_liquidation_retraites_on_allocataire_id"
    t.index ["num_dossier"], name: "index_liquidation_retraites_on_num_dossier", unique: true
    t.index ["user_id"], name: "index_liquidation_retraites_on_user_id"
  end

  create_table "maintien_prestations", force: :cascade do |t|
    t.bigint "dossier_prestations_id"
    t.integer "type_maintien"
    t.date "date_demande_maintien"
    t.date "date_arret_maintien"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "commentaire"
    t.integer "etat"
    t.date "date_effective"
    t.date "date_arret_activite"
    t.index ["dossier_prestations_id"], name: "index_maintien_prestations_on_dossier_prestations_id"
  end

  create_table "maladie_professionnelles", force: :cascade do |t|
    t.string "raison_sociale_employeur"
    t.string "numero_employeur"
    t.string "adresse_employeur"
    t.string "boite_postale_employeur"
    t.string "email_employeur"
    t.string "telephone_employeur"
    t.string "fax_employeur"
    t.string "activite_principale_entreprise"
    t.string "nin_salarie"
    t.string "numero_affiliation"
    t.string "carnet_accident_travail"
    t.string "prenom_salarie"
    t.string "nom_salarie"
    t.date "date_de_naissance_salarie"
    t.integer "situation_matrimoniale_salarie"
    t.integer "nationalite_salarie"
    t.string "adresse_domiciliaire_salarie"
    t.string "telephone_salarie"
    t.string "qualification_professionnelle_salarie"
    t.date "date_embauche_salarie"
    t.integer "anciennete_salarie"
    t.integer "type_de_contrat_travail_salarie"
    t.string "nature_du_travail_au_moment_accident"
    t.boolean "infirmite_anterieure_accident"
    t.float "taux_infirmite_anterieure_accident"
    t.string "numero_rente_infirmite_anterieure_accident"
    t.string "duree_exposition"
    t.string "type_de_travaux"
    t.integer "horaire_travail"
    t.text "histoire_professionnelle"
    t.string "nature_de_la_maladie"
    t.text "produits_utilises"
    t.text "condition_travail"
    t.text "autre"
    t.integer "etat"
    t.date "date_premier_constatation_maladie"
    t.text "circonstance_apparition_maladie"
    t.integer "numero_tableau_mp_correspondante"
    t.boolean "salaire_verse_en_totalite_en_mp"
    t.datetime "date_declaration"
    t.string "nom_declarant"
    t.string "prenom_declarant"
    t.string "lieu_declaration"
    t.boolean "info_salarie_valid"
    t.boolean "info_employeur_valid"
    t.boolean "detail_maladie_valid"
    t.boolean "document_valid"
    t.boolean "frais_indemnité_valid"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "numero_ipress_css_salarie"
    t.string "dossier_initial_salarie"
    t.date "date_rechute_salarie"
    t.float "salaire_du_jour"
    t.float "salaire_du_mois"
    t.string "numero_unique_ipress_css_employeur"
    t.string "ancien_numero_ipress_employeur"
    t.string "ancien_numero_css_employeur"
    t.integer "status_ipress"
    t.integer "status_css"
    t.integer "status_ipress_css"
    t.float "solde_total_ipress_css"
    t.float "solde_branche_vieillesse"
    t.float "solde_branche_at"
    t.float "solde_branche_pf"
    t.string "agence_gestion_ipress"
    t.string "agence_gestion_css"
    t.float "taux_at"
    t.float "taux_pf"
    t.index ["user_id"], name: "index_maladie_professionnelles_on_user_id"
  end

  create_table "mats", id: false, force: :cascade do |t|
    t.string "numero_unique"
    t.float "MATRIC"
    t.text "MATSOL"
  end

  create_table "mats1", id: false, force: :cascade do |t|
    t.string "numero_unique"
    t.float "MATRIC"
  end

  create_table "mats2", id: false, force: :cascade do |t|
    t.float "MATRIC"
    t.string "numero_unique"
    t.text "NOM"
    t.text "PRENOM"
    t.integer "REGIM"
    t.integer "AE"
    t.integer "ME"
    t.integer "JE"
    t.integer "AS"
    t.integer "MS"
    t.integer "JS"
    t.text "MATSOL"
    t.integer "DERNIEREENTREPRISE"
    t.text "RAISONSOCIALE_1"
    t.text "ADRESSE"
    t.text "T�l�phone"
    t.text "BP"
  end

  create_table "missing_declarations", force: :cascade do |t|
    t.string "numero_ipres"
    t.string "exercice"
    t.string "regime"
    t.string "agence_ipres"
    t.string "agence_css"
    t.string "versement1"
    t.string "versement2"
    t.string "versement3"
    t.string "versement4"
    t.string "date_immatriculation_css"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "etat", default: 3
    t.text "commentaire"
    t.integer "soumis_par_id"
    t.datetime "soumis_le"
  end

  create_table "missing_ligne_declarations", force: :cascade do |t|
    t.string "exercice"
    t.string "nom"
    t.string "prenom"
    t.date "date_entree"
    t.date "date_sortie"
    t.string "matricule"
    t.integer "etat"
    t.string "numero_identite"
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.integer "profession_id"
    t.integer "nationalite_id"
    t.integer "sexe"
    t.integer "regime"
    t.datetime "date_validation"
    t.integer "valider_par_id"
    t.bigint "missing_declaration_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "motif_sortie"
    t.decimal "salaire_soumis"
    t.decimal "salaire_reel"
    t.index ["missing_declaration_id"], name: "index_missing_ligne_declarations_on_missing_declaration_id"
  end

  create_table "modifier_adresses", force: :cascade do |t|
    t.bigint "allocataire_id"
    t.string "numero_allocataire", null: false
    t.string "prenom", null: false
    t.string "nom", null: false
    t.string "adresse_rue", limit: 250
    t.string "adresse_ville", limit: 250
    t.string "code_pays", limit: 250
    t.string "code_region", limit: 250
    t.string "code_commune", limit: 250
    t.date "date_soumission"
    t.date "date_validation"
    t.bigint "user_id"
    t.integer "valide_par_id"
    t.integer "ajoute_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.string "motif_rejet"
    t.integer "etat", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "affectation_allocataire"
    t.datetime "affectation_allocataire_date"
    t.boolean "modification_valide", default: false
    t.boolean "modification_soumis", default: false
    t.string "workflow_state"
    t.string "motif"
    t.string "numero_dossier"
    t.boolean "etat_civil_demandeur_valide", default: false
    t.boolean "documents_valide", default: false
    t.string "old_adresse_rue"
    t.string "old_adresse_ville"
    t.integer "soumis_par"
    t.index ["allocataire_id"], name: "index_modifier_adresses_on_allocataire_id"
    t.index ["user_id"], name: "index_modifier_adresses_on_user_id"
  end

  create_table "modifier_mode_paiements", force: :cascade do |t|
    t.bigint "allocataire_id"
    t.string "numero_allocataire", null: false
    t.string "prenom", null: false
    t.string "nom", null: false
    t.integer "mode_paiement"
    t.string "compte_bancaire_nom_banque"
    t.string "compte_bancaire_numero_compte", limit: 50
    t.datetime "date_soumission"
    t.datetime "date_validation"
    t.bigint "user_id"
    t.integer "valide_par_id"
    t.integer "ajoute_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.string "motif_rejet"
    t.integer "etat", default: 1, null: false
    t.integer "affectation_allocataire"
    t.datetime "affectation_allocataire_date"
    t.string "adresse_domicile"
    t.string "telephone"
    t.string "numero_identification_nationale"
    t.date "date_debut_changement"
    t.integer "motif_virement"
    t.string "workflow_state"
    t.string "motif"
    t.integer "instruit_par_id"
    t.datetime "instruit_le"
    t.string "numero_dossier"
    t.boolean "etat_civil_demandeur_valide", default: false
    t.boolean "documents_valide", default: false
    t.boolean "recap_regularisation", default: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.boolean "modification_valide", default: false
    t.boolean "modification_soumis", default: false
    t.string "old_mode_paiement"
    t.string "old_compte_bancaire_nom_banque"
    t.string "old_compte_bancaire_code_banque"
    t.string "old_compte_bancaire_code_guichet"
    t.string "old_compte_bancaire_numero_compte"
    t.integer "soumis_par"
    t.integer "admin_banque_agence_id"
    t.string "compte_bancaire_cle_rib", limit: 2
    t.bigint "admin_agence_id"
    t.integer "affecte_par_id"
    t.integer "agence_creation_id"
    t.index ["admin_agence_id"], name: "index_modifier_mode_paiements_on_admin_agence_id"
    t.index ["allocataire_id"], name: "index_modifier_mode_paiements_on_allocataire_id"
    t.index ["numero_allocataire"], name: "modifier_mode_paiements_numero_allocataire_idx"
    t.index ["user_id"], name: "index_modifier_mode_paiements_on_user_id"
  end

  create_table "montant_revisions", force: :cascade do |t|
    t.integer "annee"
    t.integer "point_revision"
    t.float "montant_revision"
    t.integer "revision_pension_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "periode_debut", null: false
    t.date "periode_fin", null: false
    t.integer "points_cotisation"
    t.integer "points_minoration"
    t.integer "points_base"
    t.integer "point_majoration"
    t.float "montant_revision_total"
    t.integer "points_servis"
    t.integer "points_gratuits"
    t.float "montant_revision_rc"
    t.integer "points_cotisation_rc"
    t.integer "points_minoration_rc"
    t.integer "points_base_rc"
    t.integer "points_majoration_rc"
    t.integer "points_servis_rc"
    t.integer "points_gratuits_rc"
    t.float "montant_revision_rg"
    t.integer "points_cotisation_rg"
    t.integer "points_minoration_rg"
    t.integer "points_base_rg"
    t.integer "points_majoration_rg"
    t.integer "points_servis_rg"
    t.integer "points_gratuits_rg"
  end

  create_table "moratoires", force: :cascade do |t|
    t.date "date_debut"
    t.integer "nombre_echeance"
    t.text "commentaire"
    t.date "date_fin"
    t.float "premier_montant"
    t.float "dernier_montant"
    t.float "montant"
    t.integer "statut"
    t.bigint "immatriculation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "references", default: [], array: true
    t.bigint "user_id"
    t.index ["immatriculation_id"], name: "index_moratoires_on_immatriculation_id"
  end

  create_table "mp_documents", force: :cascade do |t|
    t.string "libelle"
    t.string "code"
    t.integer "type_document"
    t.text "description"
    t.bigint "maladie_professionnelle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["maladie_professionnelle_id"], name: "index_mp_documents_on_maladie_professionnelle_id"
  end

  create_table "ordre_paiements", force: :cascade do |t|
    t.string "dossier_type"
    t.bigint "dossier_id"
    t.bigint "echeance_paiement_id"
    t.string "numero_allocataire"
    t.string "numero", limit: 20, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "statut", default: 0, null: false
    t.datetime "paye_le"
    t.datetime "impaye_le"
    t.datetime "regularise_le"
    t.integer "paye_par_id"
    t.integer "impaye_par_id"
    t.integer "regularise_par_id"
    t.integer "ordre_paiement_regularise_id"
    t.string "motif_impaye"
    t.datetime "impaye_ajoute_le"
    t.integer "impaye_ajoute_par_id"
    t.boolean "est_repris", default: false, null: false
    t.boolean "send_to_caisse_paiement", default: false, null: false
    t.integer "beneficiaire_id"
    t.integer "regularisation_pointage_id"
    t.string "num_echeance"
    t.string "type_beneficiary"
    t.integer "echeance_caisse_lot_liquidation_id"
    t.integer "echeance_veuves_caisse_lot_liquidation_id"
    t.index ["created_at"], name: "ordre_paiements_created_at_idx"
    t.index ["dossier_type", "dossier_id"], name: "index_ordre_paiements_on_dossier_type_and_dossier_id"
    t.index ["echeance_paiement_id"], name: "index_ordre_paiements_on_echeance_paiement_id"
    t.index ["numero"], name: "ordre_paiements_numero_idx"
    t.index ["numero_allocataire"], name: "ordre_paiements_numero_allocataire_idx"
    t.index ["regularisation_pointage_id"], name: "ordre_paiements_regularisation_pointage_id_idx"
  end

  create_table "paiement_allocataires", force: :cascade do |t|
    t.string "numero_allocataire", null: false
    t.integer "annee", null: false
    t.integer "periode"
    t.integer "numero_periode"
    t.integer "numero_paiement"
    t.string "regime"
    t.string "categorie"
    t.string "code_pays"
    t.string "code_region"
    t.integer "nombre_enfants"
    t.float "points_gratuits"
    t.float "points_cotisations"
    t.float "points_minores"
    t.float "enfant_points_majores"
    t.float "points_complementaires"
    t.float "points_servis"
    t.float "points_base"
    t.integer "type_paiement"
    t.float "montant_brut"
    t.float "montant_net"
    t.float "montant_igr"
    t.float "montant_mf"
    t.float "montant_ipres"
    t.float "avis_tiers", default: 0.0
    t.string "code"
    t.float "ipm"
    t.string "tutelle"
    t.float "valeur_point"
    t.string "observations"
    t.string "mode_paiement"
    t.date "date_rejet"
    t.date "date_generation"
    t.date "date_paiement"
    t.integer "etat", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "echeance_paiement_id"
    t.integer "conjoint_id"
    t.index ["echeance_paiement_id"], name: "index_paiement_allocataires_on_echeance_paiement_id"
  end

  create_table "paiement_allocataires_pret_allocataire_lignes", id: false, force: :cascade do |t|
    t.bigint "paiement_allocataire_id", null: false
    t.bigint "pret_allocataire_ligne_id", null: false
    t.index ["paiement_allocataire_id", "pret_allocataire_ligne_id"], name: "index_paiement_allocataires_pret_allocataire_lignes"
  end

  create_table "paiements", force: :cascade do |t|
    t.string "reference_paiement"
    t.date "date_paiement"
    t.float "montant"
    t.integer "mode_paiement"
    t.bigint "factures_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "references", default: [], array: true
    t.bigint "user_id"
    t.index ["factures_id"], name: "index_paiements_on_factures_id"
  end

  create_table "partdr", id: false, force: :cascade do |t|
    t.string "numero_unique"
    t.float "MATRIC"
    t.text "NOM"
    t.text "PRENOM"
    t.integer "REGIM"
    t.integer "AE"
    t.integer "ME"
    t.integer "JE"
    t.integer "AS"
    t.integer "MS"
    t.integer "JS"
    t.text "MATSOL"
    t.integer "DERNIEREENTREPRISE"
    t.text "RAISONSOCIALE_1"
    t.text "ADRESSE"
    t.text "T�l�phone"
    t.text "BP"
  end

  create_table "pension_alimentaires", force: :cascade do |t|
    t.string "numero_dossier"
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "telephone"
    t.string "email"
    t.float "montant"
    t.datetime "date_naissance"
    t.datetime "date_jouissance"
    t.string "numero_allocataire"
    t.string "commentaire"
    t.integer "etat"
    t.datetime "valider_le"
    t.integer "valider_par_id"
    t.integer "ajouter_par_id"
    t.integer "gest_allocataire_id"
    t.datetime "affecter_le"
    t.datetime "traite_le"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "numero_jugement"
    t.float "montant_versement"
  end

  create_table "periode_assurances", force: :cascade do |t|
    t.bigint "cfs_reversion_veuve_id"
    t.date "date_debut"
    t.date "date_fin"
    t.integer "trimestre_assurance"
    t.integer "trimestre_equivalente"
    t.integer "type_periode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "provenance"
    t.bigint "liquidation_retraite_france_id"
    t.index ["cfs_reversion_veuve_id"], name: "index_periode_assurances_on_cfs_reversion_veuve_id"
  end

  create_table "pre_retraite_1b", id: false, force: :cascade do |t|
    t.string "numero_unique"
    t.float "MATRIC"
    t.text "NOM"
    t.text "PRENOM"
    t.integer "REGIM"
    t.integer "AE"
    t.integer "ME"
    t.integer "JE"
    t.integer "AS"
    t.integer "MS"
    t.integer "JS"
    t.integer "ENTREP"
    t.text "MATSOL"
    t.integer "EXER"
    t.integer "ME2"
    t.integer "JE3"
    t.integer "SAL1"
    t.integer "SAL2"
    t.text "MOTIF"
    t.integer "SREEL"
    t.integer "DERNIEREENTREPRISE"
    t.text "RAISONSOCIALE"
    t.text "ADRESSE"
    t.text "T�l�phone"
    t.text "BP"
  end

  create_table "pre_retraite_1bx", id: false, force: :cascade do |t|
    t.string "prenom", limit: 100
    t.string "nom", limit: 100
    t.string "ipres_ancien_matric"
    t.string "matric", limit: 20
    t.date "date_naissance"
    t.string "regime", limit: 5
    t.string "fhnum", limit: 20
    t.string "fhrsoc"
    t.date "date_debut_periode_cotisation"
    t.date "date_fin_periode_cotisation"
    t.float "sal_rg"
    t.float "sal_rc"
    t.integer "points_rg"
    t.integer "points_rc"
  end

  create_table "pre_retraite_1bz", id: false, force: :cascade do |t|
    t.string "numero_unique"
    t.float "MATRIC"
    t.text "NOM"
    t.text "PRENOM"
    t.integer "REGIM"
    t.integer "AE"
    t.integer "ME"
    t.integer "JE"
    t.integer "AS"
    t.integer "MS"
    t.integer "JS"
    t.text "MATSOL"
    t.integer "DERNIEREENTREPRISE"
    t.text "RAISONSOCIALE_1"
    t.text "ADRESSE"
    t.text "T�l�phone"
    t.text "BP"
    t.integer "ENTREP"
    t.text "RAISONSOCIALE"
    t.integer "EXER"
    t.integer "ME_1"
    t.integer "JE_1"
    t.integer "MS_1"
    t.integer "JS_1"
    t.integer "SAL1"
    t.integer "SAL2"
    t.text "MOTIF"
    t.integer "SREEL"
  end

  create_table "pre_retraite_fv", id: false, force: :cascade do |t|
    t.text "prenom"
    t.text "nom"
    t.string "ipres_ancien_matric"
    t.string "numero_affiliation"
    t.date "date_naissance"
    t.date "date_entree"
    t.date "date_sortie"
    t.integer "type_regime_id"
    t.integer "exercice"
    t.string "ref_employeur"
    t.text "raison_sociale"
  end

  create_table "prestation_exterieures", force: :cascade do |t|
    t.string "prenom"
    t.string "nom"
    t.string "nom_jeune_fille"
    t.integer "sexe_salarie"
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.string "nin_salarie"
    t.integer "situation_matrimoniale_salarie"
    t.integer "nationalite_salarie"
    t.string "adresse_pays_origine"
    t.string "adresse_pays_emploi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "type_piece"
    t.integer "etat"
    t.boolean "document_valid"
    t.boolean "information_valid"
    t.boolean "conjoint_valid"
    t.boolean "indemnite_valid"
    t.integer "numero_caf"
    t.string "numero_dossier"
    t.string "numero_secu_social"
    t.integer "ajoute_par_id"
    t.string "motif_rejet_etf"
    t.integer "droit_liquidation"
    t.bigint "admin_cities_id"
    t.string "workflow_state"
    t.boolean "etat_famille_valid", default: false
    t.integer "soumis_etf_par_id"
    t.datetime "date_soumission_etf"
    t.integer "valide_etf_par_id"
    t.datetime "date_validation_etf"
    t.integer "soumis_liq_par_id"
    t.datetime "date_soumission_liq"
    t.integer "valide_liq_par_chef_grp_id"
    t.datetime "date_validation_liq_chef_grp"
    t.integer "valide_liq_par_chef_sub_id"
    t.datetime "date_validation_liq_chef_sub"
    t.integer "valide_liq_comptable_id"
    t.datetime "date_validation_liq_comptable"
    t.bigint "admin_country_id"
    t.string "telephone", limit: 30
    t.string "email"
    t.date "date_rejet_etf"
    t.boolean "enfant_valid"
    t.boolean "est_repris", default: false
    t.integer "suspendu_par_id"
    t.date "date_suspension"
    t.index ["admin_cities_id"], name: "index_prestation_exterieures_on_admin_cities_id"
    t.index ["admin_country_id"], name: "index_prestation_exterieures_on_admin_country_id"
  end

  create_table "pret_allocataire_lignes", force: :cascade do |t|
    t.float "montant"
    t.float "montant_mensuel"
    t.date "date_debut"
    t.string "numero_allocataire"
    t.integer "regime"
    t.integer "pret_allocataire_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "est_verse", default: false
    t.float "montant_restant", default: 0.0, null: false
    t.date "date_premier_prelevement"
    t.date "date_dernier_prelevement"
  end

  create_table "pret_allocataires", force: :cascade do |t|
    t.string "numero_allocataire"
    t.integer "type_pret"
    t.integer "duree_mois"
    t.string "commentaire"
    t.integer "regime_id"
    t.date "date_paiement"
    t.date "date_debut"
    t.date "date_fin"
    t.integer "etat"
    t.date "validation_date"
    t.integer "validation_id"
    t.integer "ajouter_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "psrm_carrieres", force: :cascade do |t|
    t.string "matric", limit: 20
    t.string "fhnum", limit: 20
    t.string "prenom", limit: 100
    t.string "nom", limit: 100
    t.string "fhrsoc"
    t.string "regime", limit: 5
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
    t.integer "edi_id"
    t.index ["date_debut_periode_cotisation"], name: "psrm_carrieres_date_debut_periode_cotisation_idx"
    t.index ["date_fin_periode_cotisation"], name: "psrm_carrieres_date_fin_periode_cotisation_idx"
    t.index ["edi_id"], name: "index_psrm_carrieres_on_edi_id"
    t.index ["fhnum"], name: "psrm_carrieres_fhnum_idx"
    t.index ["matric"], name: "psrm_carrieres_matric_idx"
    t.index ["regime"], name: "psrm_carrieres_regime_idx"
  end

  create_table "psrm_employeurs", force: :cascade do |t|
    t.string "fhnum", limit: 20, null: false
    t.string "ancien_num_ipres", limit: 30
    t.string "ancien_num_css", limit: 100
    t.string "fhrsoc", limit: 254, null: false
    t.string "activite_prinicipal"
    t.string "fhbp", limit: 100
    t.string "fhadr"
    t.string "fhtel", limit: 100
    t.date "fheffa"
    t.string "taux_at"
    t.float "solde_pf", default: 0.0
    t.float "solde_at", default: 0.0
    t.float "solde_ve", default: 0.0
    t.float "solde_total", default: 0.0
    t.string "statut"
    t.string "ancien_statut_ipres"
    t.string "ancien_statut_css"
    t.string "code_agence_css", limit: 50
    t.string "code_agence_ipres", limit: 50
    t.string "description_agence_css", limit: 100
    t.string "description_agence_ipres", limit: 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ancien_num_css"], name: "psrm_employeurs_ancien_num_css_idx"
    t.index ["ancien_num_ipres"], name: "psrm_employeurs_ancien_num_ipres_idx"
    t.index ["fhnum"], name: "psrm_employeurs_fhnum_idx"
  end

  create_table "psrm_histo_v2", id: false, force: :cascade do |t|
    t.integer "id"
    t.string "matricule", limit: 100
    t.string "regime", limit: 100
    t.string "fhcat", limit: 100
    t.string "exercice", limit: 100
    t.string "trimestre", limit: 100
    t.string "occurence", limit: 100
    t.string "fhnet", limit: 100
    t.string "fhobsv", limit: 100
    t.string "fhreje", limit: 100
    t.string "fhmtnl", limit: 100
    t.string "fhetat", limit: 100
    t.string "fhnenf", limit: 100
    t.string "fhgrat_rg", limit: 100
    t.string "fhcoti_rg", limit: 100
    t.string "fhmino_rg", limit: 100
    t.string "fhmajo_rg", limit: 100
    t.string "fhcmpl_rg", limit: 100
    t.string "fhserv_rg", limit: 100
    t.string "fhbase_rg", limit: 100
    t.string "fhtypp", limit: 100
    t.string "fhbrut_rg", limit: 100
    t.string "fhgrat_rcc", limit: 100
    t.string "fhcoti_rcc", limit: 100
    t.string "fhmino_rcc", limit: 100
    t.string "fhmajo_rcc", limit: 100
    t.string "fhcmpl_rcc", limit: 100
    t.string "fhserv_rcc", limit: 100
    t.string "fhbase_rcc", limit: 100
    t.string "fhbrut_rcc", limit: 100
    t.string "fhiprs", limit: 100
    t.string "fhavis", limit: 100
    t.string "fhtutl", limit: 100
    t.string "fhvalp_rg", limit: 100
    t.string "fhvalp_rcc", limit: 100
    t.string "fhmodp", limit: 100
    t.index ["exercice"], name: "psrm_histo_v2_exercice_idx"
    t.index ["id"], name: "psrm_histo_v2_id_idx"
    t.index ["matricule"], name: "psrm_histo_v2_matricule_idx"
    t.index ["trimestre"], name: "psrm_histo_v2_trimestre_idx"
  end

  create_table "psrm_participants", force: :cascade do |t|
    t.string "matric", null: false
    t.string "ipres_ancien_matric"
    t.string "css_ancien_matric"
    t.string "prenom"
    t.string "nom"
    t.string "type_piece"
    t.string "numero_piece"
    t.text "profession"
    t.string "emploi"
    t.string "regime"
    t.string "addr"
    t.string "phone"
    t.date "date_naissance"
    t.string "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "id_employeur", limit: 20
    t.string "contrat_en_cours", limit: 20
    t.date "date_debut_contrat"
    t.date "date_fin_contrat"
    t.integer "edi_id"
    t.boolean "from_psrm", default: false, null: false
    t.index ["css_ancien_matric"], name: "index_psrm_participants_on_css_ancien_matric"
    t.index ["edi_id"], name: "index_psrm_participants_on_edi_id"
    t.index ["genre"], name: "psrm_participants_genre_idx"
    t.index ["id_employeur"], name: "index_psrm_participants_on_id_employeur"
    t.index ["ipres_ancien_matric"], name: "index_psrm_participants_on_ipres_ancien_matric"
    t.index ["matric"], name: "index_psrm_participants_on_matric"
    t.index ["nom"], name: "index_psrm_participants_on_nom"
    t.index ["numero_piece"], name: "index_psrm_participants_on_numero_piece"
    t.index ["prenom"], name: "index_psrm_participants_on_prenom"
  end

  create_table "reg_beneficiaries", force: :cascade do |t|
    t.string "prenom"
    t.string "nom"
    t.date "date_naissance"
    t.string "nin"
    t.string "telephone"
    t.bigint "regularisation_pensions_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["regularisation_pensions_id"], name: "index_reg_beneficiaries_on_regularisation_pensions_id"
  end

  create_table "regularisation_impayes", force: :cascade do |t|
    t.bigint "regularisation_pension_id"
    t.bigint "ordre_paiement_id"
    t.string "numero_allocataire"
    t.string "numero_ordre", limit: 20, null: false
    t.integer "etat", default: 0, null: false
    t.integer "periode"
    t.integer "numero_periode"
    t.string "annee"
    t.string "code_operations"
    t.integer "montant"
    t.string "dossier_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["etat"], name: "regularisation_impayes_etat_idx"
    t.index ["numero_allocataire"], name: "regularisation_impayes_numero_allocataire_idx"
    t.index ["ordre_paiement_id"], name: "index_regularisation_impayes_on_ordre_paiement_id"
    t.index ["regularisation_pension_id"], name: "index_regularisation_impayes_on_regularisation_pension_id"
  end

  create_table "regularisation_pensions", force: :cascade do |t|
    t.bigint "allocataire_id"
    t.string "numero_allocataire"
    t.string "prenom"
    t.string "nom"
    t.date "date_regularisation"
    t.date "date_soumission"
    t.date "date_validation"
    t.integer "valide_par_id"
    t.bigint "user_id"
    t.integer "ajoute_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.integer "motif_regularisation_pension"
    t.integer "montant_regularisation"
    t.integer "affectation_allocataire"
    t.date "affectation_allocataire_date"
    t.integer "duree_suspension"
    t.integer "etat"
    t.string "attachment"
    t.string "motif_rejet"
    t.string "workflow_state"
    t.string "motif"
    t.integer "instruit_par_id"
    t.datetime "instruit_le"
    t.string "numero_dossier"
    t.boolean "etat_civil_demandeur_valide", default: false
    t.boolean "documents_valide", default: false
    t.boolean "recap_regularisation", default: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.float "pourcentage_majoration", default: 0.0
    t.integer "nb_enfant_a_regulariser", default: 0
    t.integer "nb_mois_retournes", default: 0
    t.datetime "date_validation_agence"
    t.datetime "date_validation_service"
    t.datetime "date_validation_dp"
    t.datetime "date_validation_inspection"
    t.integer "validation_agence_par_id"
    t.integer "validation_service_par_id"
    t.integer "validation_direction_par_id"
    t.integer "validation_inspection_par_id"
    t.integer "soumis_par_id"
    t.integer "agence_creation_id"
    t.integer "admin_agence_id"
    t.datetime "date_validation_chef_section"
    t.integer "validation_chef_section_par_id"
    t.datetime "date_suspension_allocataire"
    t.date "date_fin_regularisation"
    t.date "date_debut_regularisation"
    t.float "autre_montant"
    t.boolean "beneficiaire_valide"
    t.text "comment_gestionnaire"
    t.index ["allocataire_id"], name: "index_regularisation_pensions_on_allocataire_id"
    t.index ["numero_allocataire"], name: "regularisation_pensions_numero_allocataire_idx"
    t.index ["user_id"], name: "index_regularisation_pensions_on_user_id"
    t.index ["workflow_state"], name: "regularisation_pensions_workflow_state_idx"
  end

  create_table "regulation_pensions", force: :cascade do |t|
    t.bigint "allocataire_id"
    t.string "numero_allocataire"
    t.string "prenom"
    t.string "nom"
    t.date "date_regulation"
    t.date "date_soumission"
    t.date "date_validation"
    t.integer "valide_par_id"
    t.bigint "user_id"
    t.integer "ajoute_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.integer "motif_regulation_pension"
    t.integer "montant_regulation"
    t.integer "etat"
    t.string "attachment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "affectation_allocataire"
    t.datetime "affectation_allocataire_date"
    t.index ["allocataire_id"], name: "index_regulation_pensions_on_allocataire_id"
    t.index ["user_id"], name: "index_regulation_pensions_on_user_id"
  end

  create_table "remboursement_cotisations", force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "carriere_id"
    t.integer "ajoute_par_id"
    t.date "ajouter_le"
    t.integer "valider_par_id"
    t.date "valider_le"
    t.integer "affecter_a"
    t.date "affecter_le"
  end

  create_table "rentiers", force: :cascade do |t|
    t.string "numero_rentier", limit: 20, null: false
    t.string "nom", limit: 250
    t.string "prenom", limit: 250
    t.date "date_naissance", null: false
    t.string "lieu_naissance", null: false
    t.string "email"
    t.string "sexe"
    t.string "telephone", limit: 30
    t.integer "etat"
    t.integer "montant_net"
    t.integer "prix_franc_rente"
    t.integer "salaire_mensuel"
    t.integer "salaire_annuel"
    t.string "type_versement"
    t.float "taux_utile"
    t.integer "age_conversion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_consolidation"
    t.date "date_depart_rente"
    t.date "date_deces"
    t.date "date_liquidation"
    t.date "date_activation_dg"
    t.date "date_rejet"
    t.date "date_suspension"
    t.date "date_eteint"
    t.date "date_activation_dir_at"
    t.integer "taux_ipp_retenu"
    t.integer "montant_rente_mensuel"
    t.integer "montant_rente_trimestre"
    t.string "type_rente"
    t.integer "montant_versement_unique"
    t.integer "montant_majoration"
    t.integer "rente_majoree"
    t.string "numero_sinistre"
    t.integer "capital_rente"
    t.text "motif_rejet"
    t.integer "rejete_par"
  end

  create_table "representant_legals", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.date "birthdate"
    t.integer "nationality"
    t.integer "nin"
    t.integer "place_of_birth"
    t.string "city_of_birth"
    t.integer "type_of_identity"
    t.bigint "identity_number"
    t.integer "nin_cedeo"
    t.date "issued_date"
    t.date "expiry_date"
    t.integer "region"
    t.integer "departement"
    t.integer "ville"
    t.integer "commune"
    t.integer "quartier"
    t.string "address"
    t.string "land_line_number"
    t.string "mobile_number"
    t.string "email"
    t.bigint "user_id"
    t.bigint "immatriculation_societe_prive_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type_employeur"
    t.index ["immatriculation_societe_prive_id"], name: "index_representant_legals_on_immatriculation_societe_prive_id"
    t.index ["user_id"], name: "index_representant_legals_on_user_id"
  end

  create_table "retr_dr", id: false, force: :cascade do |t|
    t.float "MATRIC"
    t.text "NOM"
    t.text "PRENOM"
    t.integer "AE"
    t.integer "ME"
    t.integer "JE"
    t.integer "AS"
    t.integer "MS"
    t.integer "JS"
    t.integer "ENTREP"
    t.text "MATSOL"
    t.integer "EXER"
    t.integer "ME_1"
    t.integer "JE_1"
    t.integer "MS_1"
    t.integer "JS_1"
    t.integer "SAL1"
    t.integer "SAL2"
    t.text "MOTIF"
    t.integer "SREEL"
    t.integer "DERNIEREENTREPRISE"
    t.text "RAISONSOCIALE"
    t.text "ADRESSE"
    t.integer "TEL"
    t.integer "BP"
  end

  create_table "retr_dr1", id: false, force: :cascade do |t|
    t.float "MATRIC"
    t.text "NOM"
    t.text "PRENOM"
    t.integer "REGIM"
    t.integer "AE"
    t.integer "ME"
    t.integer "JE"
    t.integer "AS"
    t.integer "MS"
    t.integer "JS"
    t.integer "ENTREP"
    t.text "MATSOL"
    t.integer "EXER"
    t.integer "ME2"
    t.integer "JE3"
    t.integer "SAL1"
    t.integer "SAL2"
    t.text "MOTIF"
    t.integer "SREEL"
    t.integer "DERNIEREENTREPRISE"
    t.text "RAISONSOCIALE"
    t.text "ADRESSE"
    t.text "T�l�phone"
    t.text "BP"
  end

  create_table "retr_pr_3", id: false, force: :cascade do |t|
    t.string "numero_allocataire_donneur", limit: 20
  end

  create_table "retr_pr_4", id: false, force: :cascade do |t|
    t.string "numero_allocataire", limit: 20
    t.text "num_donn"
  end

  create_table "retraites_dr", id: false, force: :cascade do |t|
    t.float "MATRIC"
    t.text "NOM"
    t.text "PRENOM"
    t.integer "AE"
    t.integer "ME"
    t.integer "JE"
    t.integer "AS"
    t.integer "MS"
    t.integer "JS"
    t.integer "ENTREP"
    t.integer "MATSOL"
    t.integer "EXER"
    t.integer "ME_1"
    t.integer "JE_1"
    t.integer "MS_1"
    t.integer "JS_1"
    t.integer "SAL1"
    t.integer "SAL2"
    t.text "MOTIF"
    t.integer "SREEL"
    t.integer "DERNIEREENTREPRISE"
    t.text "RAISONSOCIALE"
    t.text "ADRESSE"
    t.integer "TEL"
    t.integer "BP"
  end

  create_table "revaloriser_pensions", force: :cascade do |t|
    t.integer "type_operation"
    t.integer "type_revalorisation"
    t.float "montant"
    t.datetime "date_debut"
    t.string "numero_allocataire"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "revenu_conjoints", force: :cascade do |t|
    t.bigint "liquidation_retraite_france_id"
    t.string "nature"
    t.float "montant_trimestriel"
    t.float "montant_annuel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["liquidation_retraite_france_id"], name: "index_revenu_conjoints_on_liquidation_retraite_france_id"
  end

  create_table "reversion_veuves", force: :cascade do |t|
    t.string "workflow_state"
    t.string "prenom", null: false
    t.string "nom", null: false
    t.date "date_naissance", null: false
    t.string "lieu_naissance"
    t.string "numero_allocataire", null: false
    t.string "adresse"
    t.integer "mode_paiement"
    t.string "compte_bancaire_numero_compte", limit: 50
    t.string "adresse_reception_allocation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.integer "type_ayant_droit", default: 1
    t.boolean "eligible", default: false, null: false
    t.bigint "conjoint_id"
    t.string "numero_dossier", null: false
    t.datetime "date_soumis"
    t.integer "ajoute_par_id"
    t.datetime "ajouter_le"
    t.integer "affecter_a"
    t.datetime "affecter_le"
    t.integer "instruit_par_id"
    t.datetime "instruit_le"
    t.integer "valider_par_id"
    t.datetime "valider_le"
    t.bigint "enfant_id"
    t.string "nom_tuteur"
    t.string "prenom_tuteur"
    t.string "motif"
    t.string "telephone"
    t.string "email"
    t.integer "admin_banque_agence_id"
    t.string "compte_bancaire_cle_rib", limit: 2
    t.integer "admin_agence_id"
    t.date "date_ouverture"
    t.integer "agence_paiement_id"
    t.bigint "allocataire_id"
    t.string "motif_rejet_allocataire"
    t.integer "rejet_allocataire_par_id"
    t.datetime "date_rejet_allocataire"
    t.integer "affecte_a_id"
    t.index ["allocataire_id"], name: "index_reversion_veuves_on_allocataire_id"
    t.index ["conjoint_id"], name: "index_reversion_veuves_on_conjoint_id"
    t.index ["enfant_id"], name: "index_reversion_veuves_on_enfant_id"
  end

  create_table "revision_pensions", force: :cascade do |t|
    t.integer "type_motif"
    t.string "numero_affiliation", null: false
    t.string "numero_allocataire"
    t.string "numero_dossier"
    t.integer "etat"
    t.datetime "ajouter_le"
    t.integer "ajouter_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.datetime "affecter_allocataire_date"
    t.integer "affecter_allocataire"
    t.datetime "affecter_salarie_date"
    t.integer "affecter_salarie"
    t.integer "allocation_id"
    t.datetime "date_reception"
    t.string "commentaire"
    t.string "motif"
    t.datetime "date_soumission"
    t.string "workflow_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "instruit_par_id"
    t.datetime "instruit_le"
    t.integer "valider_par_id"
    t.datetime "valider_le"
    t.integer "soumis_par_id"
    t.string "commentaire_allocataire"
    t.integer "admin_agence_id"
    t.text "motif_retour"
    t.integer "retourne_par_id"
    t.date "retourne_le"
    t.integer "previous_points_rc"
    t.integer "previous_points_base_rc"
    t.integer "previous_point_majoration_rc"
    t.integer "previous_point_minoration_rc"
    t.integer "previous_points_servis_rc"
    t.integer "previous_points_rg"
    t.integer "previous_points_base_rg"
    t.integer "previous_point_majoration_rg"
    t.integer "previous_point_minoration_rg"
    t.integer "previous_points_servis_rg"
  end

  create_table "salarie_immatriculations", force: :cascade do |t|
    t.string "nom"
    t.string "prenom"
    t.string "matricule"
    t.integer "sexe"
    t.integer "etat_civil"
    t.date "date_naissance"
    t.integer "numero_registre_naiss"
    t.string "prenom_pere"
    t.string "nom_pere"
    t.string "prenom_mere"
    t.integer "type_piece"
    t.string "numero_piece"
    t.string "nin"
    t.string "nin_cedeao"
    t.date "date_delivrance"
    t.date "date_expiration"
    t.string "employer_precedent"
    t.string "adresse"
    t.string "boite_postal"
    t.string "type_mouvement"
    t.date "date_debut_contrat"
    t.date "date_fin_contrat"
    t.string "emploi"
    t.string "categorie"
    t.bigint "immatriculation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "etat", default: 1
    t.integer "nationalite"
    t.integer "pays_delivrance"
    t.integer "ville_naissance"
    t.integer "pays"
    t.integer "nature_contrat"
    t.integer "profession"
    t.integer "convention_applicable"
    t.integer "region"
    t.integer "departement"
    t.integer "commune"
    t.integer "quartier"
    t.integer "pays_naissance"
    t.string "nom_mere"
    t.boolean "est_cadre"
    t.integer "arondissement"
    t.integer "temps_travail"
    t.bigint "user_id"
    t.float "salaire_contractuel", default: 0.0
    t.date "date_effet_cadre"
    t.index ["immatriculation_id"], name: "index_salarie_immatriculations_on_immatriculation_id"
  end

  create_table "salaries", force: :cascade do |t|
    t.string "matric", limit: 20, null: false
    t.string "nom", limit: 250
    t.string "prenom", limit: 250
    t.integer "sexe"
    t.string "libelle_regime"
    t.string "regime_matrimoniale"
    t.string "nin"
    t.bigint "conjoints_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_naissance"
    t.integer "nombre_femme"
    t.integer "etat"
    t.date "date_deces"
    t.index ["conjoints_id"], name: "index_salaries_on_conjoints_id"
  end

  create_table "salary_modification_historiques", force: :cascade do |t|
    t.text "prenom"
    t.text "nom"
    t.text "numero_piece"
    t.text "profession"
    t.text "genre"
    t.text "addr"
    t.text "phone"
    t.text "date_naissance"
    t.bigint "psrm_participant_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["psrm_participant_id"], name: "index_salary_modification_historiques_on_psrm_participant_id"
    t.index ["user_id"], name: "index_salary_modification_historiques_on_user_id"
  end

  create_table "suspension_allocataires", force: :cascade do |t|
    t.string "numero_allocataire"
    t.string "prenom"
    t.string "nom"
    t.date "date_soumission"
    t.integer "ajoute_par_id"
    t.date "date_validation"
    t.integer "valide_par_id"
    t.string "motif_suspension"
    t.integer "affectation_allocataire"
    t.date "affectation_allocataire_date"
    t.integer "duree_suspension"
    t.integer "etat"
    t.string "attachment"
    t.string "motif_rejet"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "workflow_state"
    t.integer "verifie_par_id"
    t.datetime "date_verification"
  end

  create_table "trackings", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id"
    t.string "type_requete", limit: 7
    t.string "path", limit: 500
    t.string "path_source", limit: 500
    t.string "ip", limit: 40
    t.string "controller", limit: 100
    t.string "action", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "trackings_created_at_idx"
    t.index ["path"], name: "trackings_path_idx"
    t.index ["user_id"], name: "index_trackings_on_user_id"
  end

  create_table "update_grappe_familiales", force: :cascade do |t|
    t.integer "conjoint_id"
    t.integer "enfant_id"
    t.string "num_affiliation"
    t.string "prenom"
    t.string "nom"
    t.date "date_soumission"
    t.date "date_deces"
    t.string "lieu_deces"
    t.date "date_validation"
    t.integer "valide_par_id"
    t.bigint "user_id"
    t.integer "ajoute_par_id"
    t.datetime "traite_le"
    t.integer "traite_par_id"
    t.string "motif_rejet"
    t.integer "montant_paiement"
    t.boolean "paiement"
    t.integer "etat"
    t.integer "trimestre"
    t.integer "annee"
    t.string "attachment"
    t.string "num_dossier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "type_demande"
    t.integer "affectation_allocataire"
    t.datetime "affectation_allocataire_date"
    t.index ["user_id"], name: "index_update_grappe_familiales_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "type_profil", default: 201, null: false
    t.string "prenom", null: false
    t.string "nom", null: false
    t.string "telephone"
    t.string "numero_salarie"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "num_css"
    t.string "num_ipres"
    t.string "ninea"
    t.string "raison_sociale"
    t.string "adresse"
    t.string "num_immatriculation"
    t.integer "created_by_id"
    t.boolean "actif", default: false, null: false
    t.integer "activated_by_id"
    t.string "agence_css"
    t.string "agence_ipres"
    t.string "statut_employeur_ipres"
    t.string "statut_employeur_css"
    t.string "activite"
    t.string "secteur_geo"
    t.string "pays"
    t.string "localite"
    t.string "ville_commune"
    t.string "sigle"
    t.integer "sexe"
    t.integer "agence_id"
    t.integer "type_employeur"
    t.string "fonction"
    t.string "numero_unique"
    t.date "date_naissance"
    t.string "lieu_naissance"
    t.string "nin"
    t.string "numero_matricule_solde"
    t.string "autres_informations_utiles"
    t.string "telephone_bureau"
    t.string "cni_file"
    t.string "image_profile"
    t.string "raison_sociale_employeur_actuel"
    t.string "certificat_travail_actuel"
    t.string "telephone_employeur_actuel"
    t.string "raison_sociale_employeur_precedent"
    t.string "certificat_travail_precedent"
    t.string "telephone_employeur_precedent"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "workflow_histories", force: :cascade do |t|
    t.string "dossier_type", null: false
    t.bigint "dossier_id", null: false
    t.string "from"
    t.string "to", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dossier_type", "dossier_id"], name: "index_workflow_histories_on_dossier_type_and_dossier_id"
    t.index ["user_id"], name: "index_workflow_histories_on_user_id"
  end

  create_table "xxipres_css_op_det", id: false, force: :cascade do |t|
    t.integer "legal_entity_id"
    t.integer "entity_id"
    t.integer "event_id"
    t.string "code_type_ligne_operation", limit: 100
    t.string "desc_ligne_paiement", limit: 200
    t.integer "montant_ligne"
    t.string "attribute1", limit: 150
    t.string "attribute2", limit: 150
    t.string "attribute3", limit: 150
    t.string "attribute4", limit: 150
    t.string "attribute5", limit: 150
    t.string "attribute6", limit: 150
    t.string "attribute7", limit: 150
    t.string "attribute8", limit: 150
    t.string "attribute9", limit: 150
    t.string "attribute10", limit: 150
    t.string "attribute11", limit: 150
    t.string "attribute12", limit: 150
    t.string "attribute13", limit: 150
    t.string "attribute14", limit: 150
    t.string "attribute15", limit: 150
    t.date "creation_date"
    t.integer "created_by"
    t.string "last_update_date", limit: 100
    t.integer "last_updated_by"
    t.integer "last_update_login"
    t.index ["event_id"], name: "xxdetl170", unique: true
  end

  create_table "xxipres_css_op_ent", id: false, force: :cascade do |t|
    t.integer "legal_entity_id"
    t.integer "entity_id"
    t.string "code_type_evenement", limit: 100
    t.date "date_evenement"
    t.string "security_id_int_1", limit: 100
    t.integer "ledger_id"
    t.string "id_allocataire", limit: 100
    t.string "nom_allocataire", limit: 200
    t.string "pnom_allocataire", limit: 200
    t.string "adresse_allocataire", limit: 200
    t.string "adresse_rue", limit: 200
    t.string "adrese_ville", limit: 200
    t.string "pays", limit: 100
    t.string "region", limit: 100
    t.float "montant_op"
    t.string "mode_de_paiement", limit: 100
    t.string "code_banque", limit: 100
    t.string "code_agence", limit: 100
    t.string "numero_compte_alloc", limit: 100
    t.string "zone_de_paiement", limit: 100
    t.string "code_agence_paiement", limit: 100
    t.string "code_caisse_paiement", limit: 100
    t.string "numero_ordre_paiement", limit: 100
    t.string "desc_ord_paiement", limit: 100
    t.string "nin", limit: 100
    t.string "num_tel", limit: 100
    t.string "email", limit: 100
    t.string "categ_allocataire", limit: 100
    t.string "num_echeance", limit: 100
    t.string "code_statut_transaction", limit: 100
    t.string "code_processus_transaction", limit: 100
    t.string "branche_liq", limit: 100
    t.string "attribute1", limit: 150
    t.string "attribute2", limit: 150
    t.string "attribute3", limit: 150
    t.string "attribute4", limit: 150
    t.string "attribute5", limit: 150
    t.string "attribute6", limit: 150
    t.string "attribute7", limit: 150
    t.string "attribute8", limit: 150
    t.string "attribute9", limit: 150
    t.string "attribute10", limit: 150
    t.string "attribute11", limit: 150
    t.string "attribute12", limit: 150
    t.string "attribute13", limit: 150
    t.string "attribute14", limit: 150
    t.string "attribute15", limit: 150
    t.date "creation_date"
    t.integer "created_by"
    t.date "last_update_date"
    t.integer "last_updated_by"
    t.integer "last_update_login"
    t.index ["entity_id"], name: "xxentl160", unique: true
    t.index ["legal_entity_id", "creation_date", "security_id_int_1"], name: "iopcss"
    t.index ["legal_entity_id", "entity_id"], name: "xxentl150", unique: true
    t.index ["numero_ordre_paiement"], name: "xxentl170", unique: true
  end

  create_table "zz_nbr_heure", id: false, force: :cascade do |t|
    t.string "no_sinistre", limit: 50, null: false
    t.integer "nb_jj_numerique", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_recommandations", "dossier_audit_activities", column: "dossier_audit_activities_id"
  add_foreign_key "activity_recommandations", "dossier_audits", column: "dossier_audits_id"
  add_foreign_key "admin_activite_principales", "admin_secteur_activites"
  add_foreign_key "admin_banque_agences", "admin_banques"
  add_foreign_key "admin_bareme_pensions", "admin_type_regimes"
  add_foreign_key "admin_baremes", "admin_type_regimes"
  add_foreign_key "admin_communes", "admin_villes"
  add_foreign_key "admin_departements", "admin_regions"
  add_foreign_key "admin_quartiers", "admin_communes"
  add_foreign_key "admin_regions", "admin_countries"
  add_foreign_key "admin_villes", "admin_departements"
  add_foreign_key "affectation_dossier_juridiques", "dossier_juridiques", column: "dossier_juridiques_id"
  add_foreign_key "allocataire_cnavs", "dossier_cnavs"
  add_foreign_key "allocataire_cnavs", "users"
  add_foreign_key "allocataires", "admin_agences"
  add_foreign_key "allocataires", "admin_regions"
  add_foreign_key "allocation_familiales", "dossier_prestations"
  add_foreign_key "allocation_familiales", "echeance_caisse_lot_liquidations"
  add_foreign_key "allocation_familiales", "echeance_caisses"
  add_foreign_key "allocation_familiales", "echeance_veuves_caisse_lot_liquidations"
  add_foreign_key "allocation_familiales", "echeance_veuves_caisses", column: "echeance_veuves_caisse_id"
  add_foreign_key "allocation_familiales", "enfants"
  add_foreign_key "allocation_familiales", "users"
  add_foreign_key "allocation_postnatales", "dossier_prestations"
  add_foreign_key "allocation_postnatales", "users"
  add_foreign_key "allocation_prenatales", "dossier_prestations"
  add_foreign_key "allocation_prenatales", "grossesses"
  add_foreign_key "allocation_prenatales", "users"
  add_foreign_key "arret_travails", "users"
  add_foreign_key "ascendants_salaries", "users"
  add_foreign_key "at_avis", "arret_travails"
  add_foreign_key "at_base_reversion_rentes", "arret_travails"
  add_foreign_key "at_code_prime_salaires", "arret_travails"
  add_foreign_key "at_consolidations", "arret_travails"
  add_foreign_key "at_decomptes", "arret_travails"
  add_foreign_key "at_decomptes", "ordre_paiements"
  add_foreign_key "at_documents", "arret_travails"
  add_foreign_key "at_events", "arret_travails"
  add_foreign_key "at_frais_engages", "arret_travails"
  add_foreign_key "at_frais_engages", "ordre_paiements"
  add_foreign_key "at_incapacites", "arret_travails"
  add_foreign_key "at_lesions", "arret_travails"
  add_foreign_key "avocats_huissiers", "dossier_juridiques"
  add_foreign_key "bien_pers_conjoints", "liquidation_retraite_frances"
  add_foreign_key "caf_conjoints", "prestation_exterieures"
  add_foreign_key "caf_enfants", "caf_conjoints"
  add_foreign_key "caf_enfants", "prestation_exterieures"
  add_foreign_key "carriere_dossier_maternites", "dossier_maternites"
  add_foreign_key "carriere_dossier_prestations", "dossier_prestations"
  add_foreign_key "carriere_dossier_prestations", "echeance_caisse_lot_liquidations"
  add_foreign_key "carriere_dossier_prestations", "echeance_caisses"
  add_foreign_key "carrieres_exterieures", "cfs_reversion_veuves"
  add_foreign_key "carrieres_exterieures", "employeur_exterieurs"
  add_foreign_key "carrires_prest_exterieures", "cfs_reversion_veuves", column: "prestation_ext_frances_id"
  add_foreign_key "carrires_prest_exterieures", "employeur_exterieurs", column: "employeur_exterieurs_id"
  add_foreign_key "cfs_conjoints", "liquidation_retraite_frances"
  add_foreign_key "cfs_conjoints", "users"
  add_foreign_key "cfs_correspondances", "liquidation_retraite_frances"
  add_foreign_key "cfs_enfants", "cfs_conjoints"
  add_foreign_key "cfs_enfants", "liquidation_retraite_frances"
  add_foreign_key "cfs_enfants", "users"
  add_foreign_key "cfs_reversion_veuves", "users"
  add_foreign_key "composant_salaire_icms", "dossier_maternites"
  add_foreign_key "compta_transactions", "admin_agences"
  add_foreign_key "compta_transactions", "admin_regions"
  add_foreign_key "compta_transactions", "echeance_paiements"
  add_foreign_key "compta_transactions_2015", "admin_agences"
  add_foreign_key "compta_transactions_2015", "admin_regions"
  add_foreign_key "compta_transactions_2015", "echeance_paiements"
  add_foreign_key "compta_transactions_2016", "admin_agences"
  add_foreign_key "compta_transactions_2016", "admin_regions"
  add_foreign_key "compta_transactions_2016", "echeance_paiements"
  add_foreign_key "compta_transactions_2017", "admin_agences"
  add_foreign_key "compta_transactions_2017", "admin_regions"
  add_foreign_key "compta_transactions_2017", "echeance_paiements"
  add_foreign_key "compta_transactions_2018", "admin_agences"
  add_foreign_key "compta_transactions_2018", "admin_regions"
  add_foreign_key "compta_transactions_2018", "echeance_paiements"
  add_foreign_key "compta_transactions_2019", "admin_agences"
  add_foreign_key "compta_transactions_2019", "admin_regions"
  add_foreign_key "compta_transactions_2019", "echeance_paiements"
  add_foreign_key "compta_transactions_2020", "admin_agences"
  add_foreign_key "compta_transactions_2020", "admin_regions"
  add_foreign_key "compta_transactions_2020", "echeance_paiements"
  add_foreign_key "compta_transactions_2021", "admin_agences"
  add_foreign_key "compta_transactions_2021", "admin_regions"
  add_foreign_key "compta_transactions_2021", "echeance_paiements"
  add_foreign_key "compta_transactions_2022", "admin_agences"
  add_foreign_key "compta_transactions_2022", "admin_regions"
  add_foreign_key "compta_transactions_2022", "echeance_paiements"
  add_foreign_key "compta_transactions_2023", "admin_agences"
  add_foreign_key "compta_transactions_2023", "admin_regions"
  add_foreign_key "compta_transactions_2023", "echeance_paiements"
  add_foreign_key "compta_transactions_2024", "admin_agences"
  add_foreign_key "compta_transactions_2024", "admin_regions"
  add_foreign_key "compta_transactions_2024", "echeance_paiements"
  add_foreign_key "compta_transactions_2025", "admin_agences"
  add_foreign_key "compta_transactions_2025", "admin_regions"
  add_foreign_key "compta_transactions_2025", "echeance_paiements"
  add_foreign_key "compta_transactions_legacy", "admin_agences"
  add_foreign_key "compta_transactions_legacy", "admin_regions"
  add_foreign_key "compta_transactions_legacy", "echeance_paiements"
  add_foreign_key "conjoints", "users"
  add_foreign_key "declaration_carrieres", "declaration_chargements"
  add_foreign_key "declaration_chargement_lignes", "declaration_chargements"
  add_foreign_key "declaration_chargements", "declaration_salaire_manquantes"
  add_foreign_key "declaration_participants", "declaration_chargements"
  add_foreign_key "declarations", "immatriculations"
  add_foreign_key "demande_carte_allocataires", "allocataires"
  add_foreign_key "demande_carte_allocataires", "users"
  add_foreign_key "document_allocat_familiales", "allocation_familiales"
  add_foreign_key "document_dossier_maternites", "dossier_maternites"
  add_foreign_key "document_dossier_prestations", "dossier_prestations"
  add_foreign_key "document_immatriculations", "immatriculations"
  add_foreign_key "document_prestation_exterieures", "prestation_exterieures"
  add_foreign_key "donation_conjoints", "liquidation_retraite_frances"
  add_foreign_key "dossier_audit_activities", "dossier_audits", column: "dossier_audits_id"
  add_foreign_key "dossier_audit_affectations", "dossier_audits", column: "dossier_audits_id"
  add_foreign_key "dossier_audits", "admin_agences"
  add_foreign_key "dossier_cnavs", "users"
  add_foreign_key "dossier_juridique_honoraires", "avocats_huissiers"
  add_foreign_key "dossier_juridique_honoraires", "dossier_juridiques"
  add_foreign_key "dossier_juridiques", "admin_type_dossier_juridiques"
  add_foreign_key "dossier_maternites", "users"
  add_foreign_key "dossier_prestations", "conjoints"
  add_foreign_key "dossier_prestations", "users"
  add_foreign_key "dossier_reversion_salaries", "allocataires"
  add_foreign_key "dossier_reversion_salaries", "base_reversion_salaries"
  add_foreign_key "dossier_reversion_salaries", "conjoints"
  add_foreign_key "dossier_reversion_salaries", "enfants"
  add_foreign_key "echeance_caisse_dossiers", "dossier_prestations"
  add_foreign_key "echeance_caisse_dossiers", "echeance_caisse_employeurs"
  add_foreign_key "echeance_caisse_dossiers", "echeance_caisses"
  add_foreign_key "echeance_caisse_employeurs", "echeance_caisses"
  add_foreign_key "echeance_caisse_enfants", "dossier_prestations"
  add_foreign_key "echeance_caisse_enfants", "echeance_caisse_dossiers"
  add_foreign_key "echeance_caisse_enfants", "echeance_caisses"
  add_foreign_key "echeance_caisse_enfants", "enfants"
  add_foreign_key "echeance_caisse_liquidations", "echeance_caisse_employeurs"
  add_foreign_key "echeance_caisse_liquidations", "echeance_caisse_enfants"
  add_foreign_key "echeance_caisse_liquidations", "echeance_caisse_lot_liquidations"
  add_foreign_key "echeance_caisse_lot_liquidations", "echeance_caisse_employeurs"
  add_foreign_key "echeance_caisse_lot_liquidations", "echeance_caisses"
  add_foreign_key "echeance_veuves_caisse_enfants", "conjoints"
  add_foreign_key "echeance_veuves_caisse_enfants", "dossier_prestations"
  add_foreign_key "echeance_veuves_caisse_enfants", "echeance_veuves_caisse_epouses"
  add_foreign_key "echeance_veuves_caisse_enfants", "echeance_veuves_caisses", column: "echeance_veuves_caisse_id"
  add_foreign_key "echeance_veuves_caisse_enfants", "enfants"
  add_foreign_key "echeance_veuves_caisse_epouses", "admin_agences"
  add_foreign_key "echeance_veuves_caisse_epouses", "dossier_prestations"
  add_foreign_key "echeance_veuves_caisse_epouses", "echeance_veuves_caisses", column: "echeance_veuves_caisse_id"
  add_foreign_key "echeance_veuves_caisse_liquidations", "echeance_veuves_caisse_enfants"
  add_foreign_key "echeance_veuves_caisse_liquidations", "echeance_veuves_caisse_lot_liquidations"
  add_foreign_key "echeance_veuves_caisse_lot_liquidations", "echeance_veuves_caisses", column: "echeance_veuves_caisse_id"
  add_foreign_key "enfants", "conjoints"
  add_foreign_key "enfants", "users"
  add_foreign_key "enrolement_regularisation_pointage_lignes", "enrolement_regularisation_pointages"
  add_foreign_key "error_missing_lignes", "missing_declarations"
  add_foreign_key "factures", "declarations"
  add_foreign_key "grossesses", "dossier_prestations"
  add_foreign_key "indemnite_conges_maternites", "ordre_paiements"
  add_foreign_key "indemnite_conges_maternites", "users"
  add_foreign_key "indemnites_prestation_exterieure_assocs", "ordre_paiements"
  add_foreign_key "indemnites_prestation_exterieures", "prestation_exterieures"
  add_foreign_key "liquidation_retraites", "admin_agences"
  add_foreign_key "liquidation_retraites", "admin_regions"
  add_foreign_key "maintien_prestations", "dossier_prestations", column: "dossier_prestations_id"
  add_foreign_key "maladie_professionnelles", "users"
  add_foreign_key "missing_ligne_declarations", "missing_declarations"
  add_foreign_key "modifier_adresses", "allocataires"
  add_foreign_key "modifier_adresses", "users"
  add_foreign_key "modifier_mode_paiements", "admin_agences"
  add_foreign_key "modifier_mode_paiements", "allocataires"
  add_foreign_key "modifier_mode_paiements", "users"
  add_foreign_key "moratoires", "immatriculations"
  add_foreign_key "mp_documents", "maladie_professionnelles"
  add_foreign_key "paiement_allocataires", "echeance_paiements"
  add_foreign_key "paiements", "factures", column: "factures_id"
  add_foreign_key "periode_assurances", "cfs_reversion_veuves"
  add_foreign_key "prestation_exterieures", "admin_cities", column: "admin_cities_id"
  add_foreign_key "prestation_exterieures", "admin_countries"
  add_foreign_key "regularisation_pensions", "allocataires"
  add_foreign_key "regularisation_pensions", "users"
  add_foreign_key "regulation_pensions", "allocataires"
  add_foreign_key "regulation_pensions", "users"
  add_foreign_key "revenu_conjoints", "liquidation_retraite_frances"
  add_foreign_key "reversion_veuves", "allocataires"
  add_foreign_key "reversion_veuves", "conjoints"
  add_foreign_key "reversion_veuves", "enfants"
  add_foreign_key "salarie_immatriculations", "immatriculations"
  add_foreign_key "salaries", "conjoints", column: "conjoints_id"
  add_foreign_key "trackings", "users"
  add_foreign_key "update_grappe_familiales", "users"
end
