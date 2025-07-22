class CreatePrestationExtFrances < ActiveRecord::Migration[5.2]
  def change
    create_table :cfs_reversion_veuves do |t|
      t.integer :sexe_salarie
      t.string :num_affiliation
      t.string :prenom
      t.string :nom
      t.string :nom_jeune_fille
      t.date :date_naissance
      t.string :lieu_naissance
      t.string :adresse_residence
      t.string :prenom_pere
      t.string :prenom_mere
      t.string :nom_pere
      t.string :nom_mere
      t.integer :nationalite_id
      t.string :num_immatric_ipres
      t.string :num_immatric_cfs
      t.integer :situation_familiale
      t.date :date_mariage
      t.date :date_situation_fam
      t.date :date_ouverture_dossier
      t.integer :nature
      t.boolean :inapte, default: false
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
      t.integer :total_an_carr_sn
      t.date :date_cess_act_fr
      t.integer :total_an_carr_fr
      t.integer :sens_convention
      t.integer :decide_points
      t.integer :decide_montant_annuel
      t.date :decide_date
      t.integer :etat, default: 1
      t.date :date_soumission
      t.date :date_validation
      t.integer :valide_par_id
      t.integer :ajoute_par_id
      t.datetime :traite_le
      t.integer :traite_par_id
      t.integer :soumis_par_id
      t.boolean :etat_civil_demandeur_valid, default: false
      t.boolean :grappe_fam_valid, default: false
      t.boolean :activite_prof_valid, default: false
      t.boolean :assur_residence_valid, default: false
      t.boolean :assur_second_pays_valid, default: false
      t.boolean :charge_second_pays_valid, default: false
      t.boolean :document_valid, default: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
