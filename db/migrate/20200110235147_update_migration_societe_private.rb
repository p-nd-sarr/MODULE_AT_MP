class UpdateMigrationSocietePrivate < ActiveRecord::Migration[5.2]
  def change

    change_column :immatriculation_private_societes, :ninet, :integer, limit: 8

  end
end
