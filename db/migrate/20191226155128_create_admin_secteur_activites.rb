class CreateAdminSecteurActivites < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_secteur_activites do |t|
      t.string :description

      t.timestamps
    end
  end
end
