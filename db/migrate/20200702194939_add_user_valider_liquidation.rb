class AddUserValiderLiquidation < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :valider_par_id, :integer
    add_column :liquidation_retraites, :valider_le, :date
  end
end
