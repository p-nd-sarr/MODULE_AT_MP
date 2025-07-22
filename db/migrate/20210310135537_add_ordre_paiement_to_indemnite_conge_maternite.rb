class AddOrdrePaiementToIndemniteCongeMaternite < ActiveRecord::Migration[5.2]
  def change
    add_reference :indemnite_conges_maternites, :ordre_paiement, foreign_key: true
  end
end
