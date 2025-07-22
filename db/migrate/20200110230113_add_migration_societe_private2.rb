class AddMigrationSocietePrivate2 < ActiveRecord::Migration[5.2]
  def change

    remove_column :immatriculation_private_societes, :departement
    remove_column :immatriculation_private_societes, :ville

    add_column :immatriculation_private_societes, :departement, :integer
    add_column :immatriculation_private_societes, :ville, :integer

    add_column :immatriculation_private_societes, :adresse, :string

  end
end
