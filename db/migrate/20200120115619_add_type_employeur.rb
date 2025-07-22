class AddTypeEmployeur < ActiveRecord::Migration[5.2]
  def change

    add_column :immatriculation_private_societes , :type_employeur, :integer
  end
end
