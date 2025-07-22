class AddColumnsToPaiementAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :paiement_allocataires, :conjoint_id, :integer
  end
end
