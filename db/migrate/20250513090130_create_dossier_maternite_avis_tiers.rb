class CreateDossierMaterniteAvisTiers < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_maternite_avis_tiers do |t|
      t.integer :type_avis
      t.integer :etat
      t.integer :tranche_paiement
      t.float :montant_avis
      t.integer :status
      t.integer :mode_paiement
      t.integer :ajouter_par_id
      t.integer :soumis_par_id
      t.integer :valider_par_id
      t.integer :traite_par_id
      t.date :date_soumission
      t.date :date_validation
      t.date :traite_le
      t.integer :retourner_par_id
      t.date :date_retour
      t.text :motif_retour
      t.text :motif_avis
      t.text :commentaire
      t.integer :type_motif
      t.float :sal_ref_a_considere
      t.integer :nbre_jours_a_indemnise
      t.references :dossier_maternites

      t.timestamps
    end
  end
end
