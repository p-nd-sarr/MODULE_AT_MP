class CreateCfsCorrespondances < ActiveRecord::Migration[5.2]
  def change
    create_table :cfs_correspondances do |t|
      t.references :liquidation_retraite_france, foreign_key: true
      t.integer :type_lettre
      t.integer :provenance
      t.string :numero_correspondance
      t.string :numero_dossier
      t.string :numero_reference
      t.string :objet
      t.integer :titre_destinataire
      t.string :destinataire
      t.string :adresse_destinataire
      t.string :expediteur
      t.datetime :date
      t.string :corps
      t.integer :titre_demandeur
      t.boolean :piece_jointe
      t.string :nature_piece_jointe
      t.integer :etat
      t.integer :ajoute_par_id

      t.timestamps
    end
  end
end
