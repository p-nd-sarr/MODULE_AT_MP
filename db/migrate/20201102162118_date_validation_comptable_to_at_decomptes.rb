class DateValidationComptableToAtDecomptes < ActiveRecord::Migration[5.2]
  def change
    add_column :at_decomptes, :date_validation_comptable, :datetime
  end
end
