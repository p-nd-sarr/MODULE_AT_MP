class CreateAdminDossierJuridiqueAvocatsHuissiers < ActiveRecord::Migration[5.2]
  def change
    create_table :avocats_huissiers do |t|

      t.string :prenom
      t.string :nom
      t.string :adresse
      t.string :tel
      t.string :email
      t.string :nin
      t.references :dossier_juridique, foreign_key: true

      t.timestamps
    end
  end
end
