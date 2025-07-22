class AddColmnsEmployerToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :agence_css, :string
    add_column :users, :agence_ipres, :string
    add_column :users, :statut_employeur_ipres, :string
    add_column :users, :statut_employeur_css, :string
    add_column :users, :activite, :string
    add_column :users, :secteur_geo, :string
    add_column :users, :pays, :string
    add_column :users, :localite, :string
    add_column :users, :ville_commune, :string
    add_column :users, :sigle, :string
  end
end