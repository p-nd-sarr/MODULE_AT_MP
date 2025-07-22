class AddTypeArretToAtLesion < ActiveRecord::Migration[5.2]
  def change
    add_column :at_lesions, :type_arret, :string
  end
end
