class AddColumnsMereNaturelToEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :nom_mere_naturel, :string
    add_column :enfants, :prenom_mere_naturel, :string
  end
end
