class AddMigrationSocietePrivate < ActiveRecord::Migration[5.2]
  def change

    remove_column :immatriculation_private_societes, :arondissement
    remove_column :immatriculation_private_societes, :department

    add_column :immatriculation_private_societes, :departement, :string
    add_column :immatriculation_private_societes, :ville, :string

  end
end
