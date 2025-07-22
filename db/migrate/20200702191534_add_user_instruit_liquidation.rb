class AddUserInstruitLiquidation < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :instruit_par_id, :integer
    add_column :liquidation_retraites, :instruit_le, :date
  end
end
