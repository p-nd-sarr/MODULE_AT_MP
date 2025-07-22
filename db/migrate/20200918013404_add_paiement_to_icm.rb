class AddPaiementToIcm < ActiveRecord::Migration[5.2]
  def self.up
    add_column :indemnite_conges_maternites, :paiement_id, :integer
    IndemniteCongesMaternite.where(paiement: nil).update_all(paiement: false)
  end

  def self.down
    remove_column :indemnite_conges_maternites, :paiement_id
  end
end
