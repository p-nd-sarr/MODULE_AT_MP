class CreateAdminMandataire < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_mandataires do |t|

      t.references :employeur, null: false
      t.string :prenom, null: false
      t.string :nom, null: false
      t.string :nin, null: false
      t.string :telephone, null: false


      t.timestamps
    end
  end
end