class CreateAdminTypeStatutJuridiques < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_type_statut_juridiques do |t|
      t.string :code
      t.string :description

      t.timestamps
    end
  end
end
