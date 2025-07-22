class AddColmnDeclarationCumulSalaire < ActiveRecord::Migration[5.2]
  def change
    add_column :declarations, :cumul_salaire , :float, default: 0

  end
end
