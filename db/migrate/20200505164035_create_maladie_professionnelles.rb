class CreateMaladieProfessionnelles < ActiveRecord::Migration[5.2]
  def change
    create_table :maladie_professionnelles do |t|
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
      t.string :qualification_professionnelle_salarie
      t.date :date_embauche_salarie
      t.integer :anciennete_salarie
      t.integer :type_de_contrat_travail_salarie
      t.string :nature_du_travail_au_moment_accident
      t.boolean :infirmite_anterieure_accident
      t.float :taux_infirmite_anterieure_accident
      t.string :numero_rente_infirmite_anterieure_accident
      
      t.string :duree_exposition
      t.string :type_de_travaux
      t.integer :horaire_travail
      t.text :histoire_professionnelle
      t.string :nature_de_la_maladie
      t.text :produits_utilises
      t.text :condition_travail
      t.text :autre
      t.integer :etat
      t.date :date_premier_constatation_maladie
      t.text :circonstance_apparition_maladie
      t.integer :numero_tableau_mp_correspondante
      t.boolean :salaire_verse_en_totalite_en_mp
      t.datetime :date_declaration
      t.string :nom_declarant
      t.string :prenom_declarant
      t.string :lieu_declaration
      t.boolean :info_salarie_valid
      t.boolean :info_employeur_valid
      t.boolean :detail_maladie_valid
      t.boolean :document_valid
      t.boolean :frais_indemnité_valid
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
