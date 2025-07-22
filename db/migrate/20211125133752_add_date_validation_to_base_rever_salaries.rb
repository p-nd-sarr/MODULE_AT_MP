class AddDateValidationToBaseReverSalaries < ActiveRecord::Migration[5.2]
  def change
    
    add_column :base_reversion_salaries, :date_soumission_carriere, :datetime
    add_column :base_reversion_salaries, :date_validation_carriere, :datetime
    add_column :base_reversion_salaries, :date_soumission_validation, :datetime
    add_column :base_reversion_salaries, :date_validation_liquidation, :datetime


    add_column :base_reversion_salaries, :soumission_carriere_par, :integer
    add_column :base_reversion_salaries, :validation_carriere_par, :integer
    add_column :base_reversion_salaries, :soumission_validation_par, :integer
    add_column :base_reversion_salaries, :validation_liquidation_par, :integer
  end
end
