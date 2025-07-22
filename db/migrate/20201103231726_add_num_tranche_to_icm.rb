class AddNumTrancheToIcm < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnite_conges_maternites, :num_tranche, :integer, default: 1
    IndemniteCongesMaternite.avant_acouchement.where(num_tranche: nil).update_all(num_tranche: 1)
    IndemniteCongesMaternite.apres_acouchement.where(num_tranche: nil).update_all(num_tranche: 2)
    IndemniteCongesMaternite.apres_reprise.where(num_tranche: nil).update_all(num_tranche: 3)
  end
end
