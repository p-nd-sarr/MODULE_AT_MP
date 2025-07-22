class AddColmnDeclarationCumul < ActiveRecord::Migration[5.2]
  def change

    add_column :declarations, :cumul_pf, :float
    add_column :declarations, :cumul_at, :float
    add_column :declarations, :cumul_rg, :float
    add_column :declarations, :cumul_rcc  , :float

  end
end
