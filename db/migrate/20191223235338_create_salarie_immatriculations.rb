class CreateSalarieImmatriculations < ActiveRecord::Migration[5.2]
  def change
    create_table :salarie_immatriculations do |t|
      t.string :nom
      t.string :prenom
      t.string :matricule
      t.integer :sexe
      t.integer :etat_civil
      t.date    :date_naissance
      t.integer :numero_registre_naiss
      t.string  :prenom_pere
      t.string  :nom_pere
      t.string  :nommere
      t.string  :prenom_mere
      t.string  :nationalite
      t.integer :type_piece
      t.string  :numero_piece
      t.string  :nin
      t.string  :nin_cedeao
      t.date    :date_delivrance
      t.date    :date_expiration
      t.string  :pays_delivrance
      t.string  :ville_naissance
      t.string  :employer_precedent
      t.string  :pays
      t.string  :adresse
      t.string :boite_postal
      t.string  :type_mouvement
      t.integer :nature_contrat
      t.date    :date_debut_contrat
      t.date    :date_fin_contrat
      t.string  :profession
      t.string  :emploi
      t.boolean :cadre
      t.string  :convention_applicable
      t.string  :salaire_contractuel
      t.string  :categorie

      t.references :immatriculation, foreign_key: true

      t.timestamps
    end
  end
end
