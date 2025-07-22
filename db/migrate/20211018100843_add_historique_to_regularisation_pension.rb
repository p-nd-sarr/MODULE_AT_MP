class AddHistoriqueToRegularisationPension < ActiveRecord::Migration[5.2]
  def change
    add_column :regularisation_pensions, :date_validation_agence, :datetime
    add_column :regularisation_pensions, :date_validation_service, :datetime
    add_column :regularisation_pensions, :date_validation_dp, :datetime
    add_column :regularisation_pensions, :date_validation_inspection, :datetime
    add_column :regularisation_pensions, :validation_agence_par_id, :integer
    add_column :regularisation_pensions, :validation_service_par_id, :integer
    add_column :regularisation_pensions, :validation_direction_par_id, :integer
    add_column :regularisation_pensions, :validation_inspection_par_id, :integer
    add_column :regularisation_pensions, :soumis_par_id, :integer
    
  end
end
