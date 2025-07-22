class CreateAtLesions < ActiveRecord::Migration[5.2]
  def change
    create_table :at_lesions do |t|
      t.integer :nature_lesion
      t.string :code_nature_lesion
      t.integer :siege_lesion
      t.string :code_siege_lesion
      t.references :arret_travail, foreign_key: true

      t.timestamps
    end
    
  end
end
