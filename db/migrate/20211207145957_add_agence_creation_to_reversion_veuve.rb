class AddAgenceCreationToReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuves, :agence_paiement_id, :integer
  end
end
