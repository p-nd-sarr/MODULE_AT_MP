class AddDateLiquidationCircuit < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :date_soumission_carriere, :datetime
    add_column :liquidation_retraites, :date_validation_carriere, :datetime
    add_column :liquidation_retraites, :date_soumission_validation, :datetime
    add_column :liquidation_retraites, :date_validation_liquidation, :datetime


    add_column :liquidation_retraites, :soumission_carriere_par, :integer
    add_column :liquidation_retraites, :validation_carriere_par, :integer
    add_column :liquidation_retraites, :soumission_validation_par, :integer
    add_column :liquidation_retraites, :validation_liquidation_par, :integer
  end
end
