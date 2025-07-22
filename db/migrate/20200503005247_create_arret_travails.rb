class CreateArretTravails < ActiveRecord::Migration[5.2]
  def change
    create_table :arret_travails do |t|
      t.string :raison_sociale_employeur
      t.string :numero_employeur
      t.string :adresse_employeur
      t.string :boite_postale_employeur
      t.string :email_employeur
      t.string :telephone_employeur
      t.string :fax_employeur
      t.string :activite_principale_entreprise
      t.string :nin_salarie
      t.string :numero_affiliation
      t.string :carnet_accident_travail
      t.string :prenom_salarie
      t.string :nom_salarie
      t.date :date_de_naissance_salarie
      t.integer :situation_matrimoniale_salarie
      t.integer :nationalite_salarie
      t.string :adresse_domiciliaire_salarie
      t.string :telephone_salarie
      t.integer :qualification_professionnelle_salarie
      t.date :date_embauche_salarie
      t.integer :anciennete_salarie
      t.integer :type_de_contrat_travail_salarie
      t.string :nature_du_travail_au_moment_accident
      t.boolean :infirmite_anterieure_accident
      t.float :taux_infirmite_anterieure_accident
      t.string :numero_rente_infirmite_anterieure_accident
      t.datetime :date_accident
      t.integer :nombre_hr_entre_accident_et_prise_travail
      t.integer :lieu_accident
      t.boolean :accident_mortel
      t.datetime :debut_arret_travail
      t.integer :agent_materiel
      t.string :code_agent_materiel
      t.text :cause_circonstances_acccident
      t.boolean :avec_constat
      t.string :detail_constat
      t.boolean :avec_temoin
      t.string :nom_temoin
      t.string :adresse_temoin
      t.boolean :personne_avisee
      t.string :nom_personne_avisee
      t.string :adresse_personne_avisee
      t.string :personne_avisee_quand
      t.string :personne_avisee_par_qui
      t.boolean :accident_cause_par_tiers
      t.string :prenom_tiers
      t.string :nom_tiers
      t.string :adresse_tiers
      t.string :prenom_civilement_responsable
      t.string :nom_civilement_responsable
      t.string :prenom_civilement_responsable
      t.string :adresse_civilement_responsable
      t.boolean :salaire_verse_en_totalite_en_at
      t.datetime :date_declaration
      t.string :nom_declarant
      t.string :prenom_declarant
      t.string :lieu_declaration
      t.integer :etat
      t.boolean :est_ipp
      t.float :taux_ipp
      t.float :taux_itt
      t.boolean :info_salarie_valid, :default => false
      t.boolean :info_employeur_valid, :default => false
      t.boolean :detail_accident_valid, :default => false
      t.boolean :document_valid, :default => false
      t.boolean :frais_indemnité_valid, :default => false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
