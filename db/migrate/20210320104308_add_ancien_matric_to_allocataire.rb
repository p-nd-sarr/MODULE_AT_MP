class AddAncienMatricToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :ipres_ancien_matric, :string
    add_column :allocataires, :css_ancien_matric, :string
  end
end
