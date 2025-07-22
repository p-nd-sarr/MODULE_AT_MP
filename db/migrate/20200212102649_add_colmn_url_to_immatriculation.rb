class AddColmnUrlToImmatriculation < ActiveRecord::Migration[5.2]
  def change

    add_column :immatriculation_private_societes, :url , :string

  end
end
