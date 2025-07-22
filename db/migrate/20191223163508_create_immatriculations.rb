class CreateImmatriculations < ActiveRecord::Migration[5.2]
  def change
    create_table :immatriculations do |t|
      t.integer :type_immatriculation
      t.integer :type_employeur
      t.string :raison_sociale
      t.integer :type_etablissement
      t.string :ninea
      t.string :ninet
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
      t.string :email_employeur
      t.string :adresse
      t.string :telephone_employeur

      t.timestamps
    end
  end
end
