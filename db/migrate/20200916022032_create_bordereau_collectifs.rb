class CreateBordereauCollectifs < ActiveRecord::Migration[5.2]
  def change
    create_table :bordereau_collectifs do |t|
        t.references :employeur
      t.string :numero_bordereau, null: false
      t.integer :trimestre, null: false
      t.integer :annee, null: false

      t.timestamps
    end
  end
end
