class AddEnfantToReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_reference :reversion_veuves, :enfant, foreign_key: true
  end
end
