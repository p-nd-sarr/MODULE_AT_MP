class AddIdDpToAllocationsFamilialesMigrees < ActiveRecord::Migration[5.2]
  def change
    add_reference :allocations_familiales_migrees, :dossier_prestation
  end
end
