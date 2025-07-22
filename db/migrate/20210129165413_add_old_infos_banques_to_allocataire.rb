class AddOldInfosBanquesToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :old_code_banque, :string, limit: 2
    add_column :allocataires, :old_compte_banque, :string, limit: 15
  end
end
