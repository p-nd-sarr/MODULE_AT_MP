class UpdateDateLiquidation < ActiveRecord::Migration[5.2]
  def change
    change_column :liquidation_retraites, :date_soumission, :datetime
    change_column :liquidation_retraites, :valider_le, :datetime
    change_column :liquidation_retraites, :instruit_le, :datetime

  end
end
