class AddMontantSubventionToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :montant_subvention, :float, default: 0
  end
end
