class AddInfosTraiteursToReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuves, :traite_le, :datetime
    add_column :reversion_veuves, :traite_par_id, :integer
  end
end
