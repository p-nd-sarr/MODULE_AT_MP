class AddDateCessationActiviteToDemandeLiquidation < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :date_cessation_activite, :date
    add_column :liquidation_retraites, :date_soumission, :date
  end
end
