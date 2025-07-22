class AddDateValidationColumnToAtFraisEngages < ActiveRecord::Migration[5.2]
  def change
    add_column :at_frais_engages, :date_validation, :date
    add_column :at_frais_engages, :date_validation_comptable, :date
  end
end
