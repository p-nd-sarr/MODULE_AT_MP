class CreateAdminDecesSalaries < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_deces_salaries do |t|
      t.string :numero_affiliation
      t.string :prenom
      t.string :nom
      t.date :date_deces
      t.string :numero_piece

      t.timestamps
    end
  end
end
