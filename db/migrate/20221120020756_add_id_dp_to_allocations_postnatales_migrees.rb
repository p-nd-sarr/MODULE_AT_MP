class AddIdDpToAllocationsPostnatalesMigrees < ActiveRecord::Migration[5.2]
  def change
    add_reference :allocations_postnatales_migrees, :dossier_prestation
  end
end
