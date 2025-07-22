class CreateImmatriculationPrivateSocietes < ActiveRecord::Migration[5.2]
  def change
    create_table :immatriculation_private_societes do |t|
      t.string :raison_sociale
      t.integer :type_etablissement
      t.integer :type_immatriculation
      t.integer :ninea
      t.integer :ninet
      t.string :registre_commerce
      t.integer :statut_juridique
      t.string :code_identification_fiscale
      t.datetime :date_immatriculation
      t.datetime :date_identification_fiscale
      t.datetime :date_identification_rc
      t.datetime :date_ouverture
      t.string :siege_social
      t.integer :activite_principale
      t.integer :secteur_activite
      t.string :website
      t.string :zoneCss
      t.string :zoneIpres
      t.string :sectorCss
      t.string :sectorIpres
      t.string :agencyCss
      t.string :agencyIpres
      t.integer :effectif_employe
      t.integer :effectif_cadre
      t.date :embauche_cadre
      t.date :embauche_employer
      t.bigint :process_flow_id
      t.bigint :employer_registration_form_id
      t.bigint :employee_registration_form_id
      t.text :message
      t.integer :type_of_identity
      t.string :boite_postale
      t.string :sigle
      t.string :statut_demande
      t.integer :region
      t.integer :department
      t.integer :arondissement
      t.integer :commune
      t.integer :quartier
      t.string :address
      t.string :landLineNumber
      t.string :mobileNumber
      t.string :email
      t.boolean :etat_civil_demandeur_valide, default: false, null: false
      t.boolean :representant_valide, default: false, null: false
      t.boolean :salarie_valide, default: false, null: false
      t.boolean :documents_valide, default: false, null: false
      t.integer :etat, default: 1, null: false
      t.date :date_soumission

      t.references :user

      t.timestamps
    end
  end
end
