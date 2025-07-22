class AddColumnNameImmatriculation2 < ActiveRecord::Migration[5.2]
  def change
    add_column :salarie_immatriculations, :temps_travail, :integer

    add_column :immatriculations, :process_flow_id, :integer
    add_column :immatriculations, :employer_registration_form_id, :integer
    add_column :immatriculations, :employee_registration_form_id, :integer
    add_column :immatriculations, :message, :text
  end
end
