class ChangeCaisseBkOfAllocataireCnav < ActiveRecord::Migration[5.2]
  def change
    remove_column :allocataire_cnavs, :caisse_bk
    add_column :allocataire_cnavs, :admin_banque_id, :integer
    add_column :allocataire_cnavs, :delta, :integer
  end
end
