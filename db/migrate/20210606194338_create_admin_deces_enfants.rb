class CreateAdminDecesEnfants < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_deces_enfants do |t|
      t.string :numero_affiliation
      t.string :prenom
      t.string :nom
      t.date :date_naissance
      t.string :date_deces
      t.string :prenom_salarie
      t.string :nom_salarie
      t.integer :type_piece
      t.string :numero_piece

      t.timestamps
    end
  end
end
