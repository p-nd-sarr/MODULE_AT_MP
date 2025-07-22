class CreateAdminTypeDossierJuridiques < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_type_dossier_juridiques do |t|
      t.string :title
      t.string :description
      t.timestamps
    end
  end
end
