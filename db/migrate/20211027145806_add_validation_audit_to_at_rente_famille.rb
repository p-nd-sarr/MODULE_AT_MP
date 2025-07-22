class AddValidationAuditToAtRenteFamille < ActiveRecord::Migration[5.2]
  def change
    add_column :at_rente_familles, :date_validation_audit, :datetime
    add_column :at_rente_familles, :validation_audit_par_id, :integer
  end
end
