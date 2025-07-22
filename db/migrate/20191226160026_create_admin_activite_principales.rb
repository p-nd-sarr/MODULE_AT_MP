class CreateAdminActivitePrincipales < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_activite_principales do |t|
      t.references :admin_secteur_activite, foreign_key: true
      t.string :description

      t.timestamps
    end
  end
end
