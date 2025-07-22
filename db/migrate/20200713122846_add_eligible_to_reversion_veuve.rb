class AddEligibleToReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuves, :eligible, :boolean, null: false, default: false
  end
end
