class AddFieldBanqueLiquidation < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :admin_banque_id, :integer
  end
end
