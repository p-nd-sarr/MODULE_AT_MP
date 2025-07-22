class AddDateSuspensionToRegularisationPensions < ActiveRecord::Migration[5.2]
  def change
    add_column :regularisation_pensions, :date_suspension_allocataire, :datetime
  end
end
