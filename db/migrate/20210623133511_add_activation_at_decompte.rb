class AddActivationAtDecompte < ActiveRecord::Migration[5.2]
  def change
    add_column :at_decomptes, :active_par, :integer
    add_column :at_decomptes, :date_activation, :datetime
  end
end
