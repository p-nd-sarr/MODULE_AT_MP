class CreateAllocataireCnavs < ActiveRecord::Migration[5.2]
  def change
    create_table :allocataire_cnavs do |t|
      t.references :dossier_cnav, foreign_key: true
      t.date :date_import
      t.string :numero
      t.string :prenom
      t.string :nom
      t.integer :admin_region_id
      t.integer :montant
      t.string :origine
      t.string :compte
      t.integer :caisse_bk
      t.date :date_soumission
      t.date :date_validation
      t.integer :valide_par_id
      t.references :user, foreign_key: true
      t.integer :ajoute_par_id
      t.datetime :traite_le
      t.integer :traite_par_id
      t.string :motif_rejet
      t.integer :montant_paiement
      t.boolean :paiement
      t.integer :etat
      t.integer :mode_paiement
      t.string :numero_liquidation

      t.timestamps
    end
  end
end
