class CreateAdminComposantSalaire < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_composant_salaires do |t|
      t.string :designation
      t.string :code
      t.boolean :prise_en_compte
      t.timestamps
    end
  end
end
