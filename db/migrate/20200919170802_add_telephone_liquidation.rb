class AddTelephoneLiquidation < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :telephone, :string
  end
end
