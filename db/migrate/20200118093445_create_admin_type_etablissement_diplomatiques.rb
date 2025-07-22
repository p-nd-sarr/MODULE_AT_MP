class CreateAdminTypeEtablissementDiplomatiques < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_type_etablissement_diplomatiques do |t|
      t.string :code
      t.string :description

      t.timestamps
    end
  end
end
