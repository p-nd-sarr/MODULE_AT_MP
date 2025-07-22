class ChangeDefaultModePaiementOnAllocataire < ActiveRecord::Migration[5.2]
  def change
    change_column_default :allocataires, :mode_paiement, from: nil, to: 4
  end
end
