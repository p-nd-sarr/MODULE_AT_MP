class AddColumnExpirationDateMigratedToEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :migrated_document_exp_date, :date
  end
end
