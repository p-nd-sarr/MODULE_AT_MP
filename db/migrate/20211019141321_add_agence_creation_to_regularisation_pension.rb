class AddAgenceCreationToRegularisationPension < ActiveRecord::Migration[5.2]
  def change
    add_column :regularisation_pensions, :agence_creation_id, :integer
    add_column :regularisation_pensions, :admin_agence_id, :integer
    add_column :regularisation_pensions, :date_validation_chef_section, :datetime
    add_column :regularisation_pensions, :validation_chef_section_par_id, :integer
  end
end
