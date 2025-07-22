class AddRappelPensionToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :old_montant_net_m1, :float, default: 0
    add_column :allocataires, :old_montant_net_m2, :float, default: 0
    add_column :allocataires, :old_montant_net_m3, :float, default: 0
    add_column :allocataires, :new_montant_net_m1, :float, default: 0
    add_column :allocataires, :new_montant_net_m2, :float, default: 0
    add_column :allocataires, :new_montant_net_m3, :float, default: 0
    add_column :allocataires, :diff_montant_net_m1, :float, default: 0
    add_column :allocataires, :diff_montant_net_m2, :float, default: 0
    add_column :allocataires, :diff_montant_net_m3, :float, default: 0
  end
end
