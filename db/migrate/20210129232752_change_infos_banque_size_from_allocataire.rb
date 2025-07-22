class ChangeInfosBanqueSizeFromAllocataire < ActiveRecord::Migration[5.2]
  def change
    change_column :allocataires, :old_code_banque, :string, limit: 5
    change_column :allocataires, :old_compte_banque, :string, limit: 50
  end
end
