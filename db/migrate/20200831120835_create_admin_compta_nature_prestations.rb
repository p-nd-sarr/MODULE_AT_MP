class CreateAdminComptaNaturePrestations < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_compta_nature_prestations do |t|
      t.string :code, null: false
      t.string :libelle, null: false
      t.integer :entite, null: false
      t.integer :branche, null: false

      t.timestamps
    end
  end
end
