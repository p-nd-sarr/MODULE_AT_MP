class CreateDeclarationChargementLignes < ActiveRecord::Migration[5.2]
  def change
    create_table :declaration_chargement_lignes do |t|
      t.references :declaration_chargement, foreign_key: true, index: { name: 'idx_declaration_chargement_lignes_on_declaration_chargement_id' }

      t.integer :numero_ligne

      t.integer :exercice
      t.string :numero_affiliation, limit: 50
      t.string :nom
      t.string :prenom
      t.string :matricule_interne, limit: 100
      t.integer :jour_entree
      t.integer :mois_entree
      t.integer :annee_entree
      t.integer :jour_sortie
      t.integer :mois_sortie
      t.integer :annee_sortie
      t.string :motif_sortie
      t.float :salaire_soumis
      t.float :salaire_reel
      t.string :statut
      t.string :nin, limit: 30
      t.date :date_naissance
      t.string :lieu_naissance
      t.string :profession
      t.string :nationalite, limit: 100
      t.string :sexe, limit: 1

      t.boolean :erreur
      t.string :details_erreur, array: true, default: []

      t.timestamps
    end
  end
end
