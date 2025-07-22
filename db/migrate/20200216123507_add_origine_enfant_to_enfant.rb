class AddOrigineEnfantToEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :origine_enfant, :integer
  end
end
