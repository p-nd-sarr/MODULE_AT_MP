class AddContactInformationsToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :telephone, :string, limit: 30
    add_column :prestation_exterieures, :email, :string
  end
end
