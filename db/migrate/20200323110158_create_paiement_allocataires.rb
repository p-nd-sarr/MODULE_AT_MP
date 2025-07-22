class CreatePaiementAllocataires < ActiveRecord::Migration[5.2]
  def change
    create_table :paiement_allocataires do |t|
      t.string :numero_allocataire, null: false
      t.integer :annee, null: false
      t.integer :periode
      t.integer :numero_periode
      t.integer :numero_paiement
      t.string :regime
      t.string :categorie
      t.string :code_pays
      t.string :code_region
      t.integer :nombre_enfants
      t.float :points_gratuits
      t.float :points_cotisations
      t.float :points_minores
      t.float :enfant_points_majores
      t.float :points_complementaires
      t.float :points_servis
      t.float :points_base
      t.integer :type_paiement
      t.float :montant_brut
      t.float :montant_net
      t.float :montant_igr
      t.float :montant_mf
      t.float :montant_ipres
      t.string :avis_tiers
      t.string :code
      t.float :ipm
      t.string :tutelle
      t.float :valeur_point
      t.string :observations
      t.string :mode_paiement
      t.date :date_rejet
      t.date :date_generation
      t.date :date_paiement
      t.integer :etat, default: 0

      t.timestamps
    end
  end
end
