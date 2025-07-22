class AddAllocataireToReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_reference :reversion_veuves, :allocataire, foreign_key: true
  end
end
