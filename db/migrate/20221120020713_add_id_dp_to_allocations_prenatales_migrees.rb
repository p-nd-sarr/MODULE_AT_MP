class AddIdDpToAllocationsPrenatalesMigrees < ActiveRecord::Migration[5.2]
  def change
    add_reference :allocations_prenatales_migrees, :dossier_prestation
  end
end
