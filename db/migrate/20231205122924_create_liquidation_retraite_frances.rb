class CreateLiquidationRetraiteFrances < ActiveRecord::Migration[5.2]
  def change
    create_table :liquidation_retraite_frances do |t|
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

      t.string :nom_jeune_fille
      t.string :prenom_pere
      t.string :prenom_mere
      t.string :nom_pere
      t.string :nom_mere
      t.integer :nationalite_id, null: false
      t.string :num_immatric_ipres
      t.string :num_immatric_cfs
      t.integer :situation_familiale
      t.date :date_mariage
      t.date :date_situation_fam
      t.string :adresse_residence
      t.boolean :inapte, default: false, null: false
      t.date :date_depart_inapt
      t.date :date_decision_inapt
      t.boolean :titulaire_pens_invalidite, default: false
      t.boolean :titre_reg_gl, default: false
      t.boolean :titre_reg_agric, default: false
      t.boolean :titre_reg_minier, default: false
      t.boolean :titre_reg_special, default: false
      t.string :institution_reg_spec
      t.string :num_pension_inapt
      t.date :date_cess_act_sn
      t.integer :total_an_carriere_sn, default: 0
      t.date :date_cess_act_fr
      t.integer :total_an_carriere_fr, default: 0
      t.integer :sens_convention, null: false
      t.integer :decide_points, default: 0
      t.integer :decide_montant_annuel, default: 0
      t.integer :precision_carriere
      t.date :decide_date
      t.boolean :activite_prof_valid, default: false, null: false
      t.boolean :assur_residence_valid, default: false, null: false
      t.boolean :assur_second_pays_valid, default: false, null: false
      t.boolean :charge_second_pays_valid, default: false, null: false
      t.string :numero_piece
      t.integer :type_piece

      t.string :numero_securite_sociale, null: false
      t.string :adresse_postale, null: true
      t.boolean :ressources_conjoint_valid
      t.boolean :carriere_conjoint, default: false
      t.float :salaire_trimestre_conjoint
      t.float :salaire_annuel_conjoint
      t.date :date_cess_act_conjoint
      t.boolean :avantage_viellesse_conjoint, default: false
      t.integer :nature_avantage_conjoint
      t.string :nom_instit_deb_conjoint
      t.string :adresse_instit_deb_conjoint
      t.string :numero_pension_conjoint
      t.float :montant_pension_conjoint
      t.boolean :autres_revenus_conjoint, default: false
      t.boolean :biens_perso_conjoint, default: false
      t.boolean :biens_donation_conjoint, default: false


      t.timestamps

      t.index ["admin_agence_id"], name: "index_liquidation_retraite_frances_on_admin_agence_id"
      t.index ["admin_region_id"], name: "index_liquidation_retraite_frances_on_admin_region_id"
      t.index ["allocataire_id"], name: "index_liquidation_retraite_frances_on_allocataire_id"
      t.index ["num_dossier"], name: "index_liquidation_retraite_frances_on_num_dossier", unique: true
      t.index ["user_id"], name: "index_liquidation_retraite_frances_on_user_id"
    end
  end
end
