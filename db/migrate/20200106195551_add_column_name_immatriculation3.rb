class AddColumnNameImmatriculation3 < ActiveRecord::Migration[5.2]
  def change

    remove_column :immatriculations, :typeOfIdentity

    add_column :immatriculations, :type_of_identity, :integer
    add_column :immatriculations, :boite_postale, :string

  end
end
