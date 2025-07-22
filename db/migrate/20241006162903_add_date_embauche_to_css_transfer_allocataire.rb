class AddDateEmbaucheToCssTransferAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :css_transfert_allocataires, :date_embauche, :date
  end
end
