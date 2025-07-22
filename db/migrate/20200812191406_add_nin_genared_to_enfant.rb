class AddNinGenaredToEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :nin_generer, :string
  end
end
