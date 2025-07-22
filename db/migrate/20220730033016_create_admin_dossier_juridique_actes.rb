class CreateAdminDossierJuridiqueActes < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_juridique_actes do |t|

      t.integer :type_act
      t.date :date_act
      t.string :comment
      t.references :dossier_juridique

      t.timestamps
    end
  end
end
