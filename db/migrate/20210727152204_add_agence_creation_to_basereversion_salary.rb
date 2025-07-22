class AddAgenceCreationToBasereversionSalary < ActiveRecord::Migration[5.2]
  def change
    add_column :base_reversion_salaries, :agence_creation_id, :integer
    add_column :base_reversion_salaries, :admin_agence_id, :integer
    add_column :base_reversion_salaries, :nombre_epouses_eligible, :integer
    add_column :base_reversion_salaries, :nombre_enfant_eligible, :integer
  end
end
