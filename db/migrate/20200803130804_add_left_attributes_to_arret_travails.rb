class AddLeftAttributesToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :sexe, :integer
    add_column :arret_travails, :lieu_de_naissance, :string
    add_column :arret_travails, :telephone, :string
    add_column :arret_travails, :adresse, :string
    add_column :arret_travails, :email, :string
    add_column :arret_travails, :nationalite, :string
    add_column :arret_travails, :type_de_piece, :integer
    add_column :arret_travails, :type_declaration, :integer
    add_column :arret_travails, :adresse_declarant, :string
    add_column :arret_travails, :telephone_declarant, :string
  end
end
