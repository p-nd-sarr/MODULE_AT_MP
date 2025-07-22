class CreateAdminMouvementTravailFins < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_mouvement_travail_fins do |t|
      t.string :code
      t.string :description

      t.timestamps
    end
  end
end
