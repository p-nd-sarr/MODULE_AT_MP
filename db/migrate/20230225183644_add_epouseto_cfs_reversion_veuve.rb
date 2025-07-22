class AddEpousetoCfsReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_column :cfs_reversion_veuves, :nom_defunt, :string
    add_column :cfs_reversion_veuves, :prenom_defunt, :string
    add_column :cfs_reversion_veuves, :numero_securite_sociale_defunt, :string
    add_column :cfs_reversion_veuves, :numero_securite_sociale_veuve, :string
    add_column :cfs_reversion_veuves, :adresse_postale, :string
  end
end
