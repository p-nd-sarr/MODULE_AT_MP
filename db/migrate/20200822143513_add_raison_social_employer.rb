class AddRaisonSocialEmployer < ActiveRecord::Migration[5.2]
  def change
    add_column :carrieres, :raison_sociale, :string
  end
end