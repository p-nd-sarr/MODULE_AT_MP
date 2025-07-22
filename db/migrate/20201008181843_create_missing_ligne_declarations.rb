class CreateMissingLigneDeclarations < ActiveRecord::Migration[5.2]
  def change
    create_table :missing_ligne_declarations do |t|
      t.string :exercice
      t.string :nom
      t.string :prenom
      t.date :date_entree
      t.date :date_sortie
      t.string :matricule
      t.string :motif_sortie
      t.string :salaire_soumis
      t.string :salaire_reel
      t.integer :etat
      t.string :numero_identite
      t.date :date_naissance
      t.string :lieu_naissance
      t.integer :profession_id
      t.integer :nationalite_id
      t.integer :sexe
      t.integer :regime
      t.datetime :date_validation
      t.integer :valider_par_id

      t.references :missing_declaration, foreign_key: true

      t.timestamps
    end
  end
end
