class CreateAdminDossierJuridiqueHonoraires < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_juridique_honoraires do |t|

      t.integer :montant
      t.string :nom_complet_juge
      t.date :date_eff
      t.references :dossier_juridique, foreign_key: true
      t.references :avocats_huissier, foreign_key: true

      t.timestamps
    end
  end
end
