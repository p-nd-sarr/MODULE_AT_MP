class AddTypeAyantDroitToReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuves, :type_ayant_droit, :integer, default: 1
  end
end
