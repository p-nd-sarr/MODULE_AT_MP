class RemoveAllocationPrenataleFromMontantMensualiteVolet < ActiveRecord::Migration[5.2]
  def change
    remove_column :montant_mensualite_volets , :allocation_prenatale_id
  end
end
