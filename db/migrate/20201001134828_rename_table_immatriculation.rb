class RenameTableImmatriculation < ActiveRecord::Migration[5.2]
  def change
    rename_table :immatriculation_private_societes, :immatriculation_societes
  end
end
