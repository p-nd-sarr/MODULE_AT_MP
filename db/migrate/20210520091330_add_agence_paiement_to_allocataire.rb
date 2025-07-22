class AddAgencePaiementToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_reference :allocataires, :admin_agence, foreign_key: true, null: true
  end
end
