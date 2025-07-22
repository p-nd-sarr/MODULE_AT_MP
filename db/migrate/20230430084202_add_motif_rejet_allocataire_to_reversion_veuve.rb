class AddMotifRejetAllocataireToReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuves, :motif_rejet_allocataire, :string
    add_column :reversion_veuves, :rejet_allocataire_par_id, :integer
    add_column :reversion_veuves, :date_rejet_allocataire, :datetime
  end
end
