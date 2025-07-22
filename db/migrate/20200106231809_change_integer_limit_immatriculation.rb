class ChangeIntegerLimitImmatriculation < ActiveRecord::Migration[5.2]
  def change
    change_column :immatriculations, :process_flow_id, :integer, limit: 8
    change_column :immatriculations, :employee_registration_form_id, :integer, limit: 8
    change_column :immatriculations, :employer_registration_form_id, :integer, limit: 8
  end
end
