class AddChangeAdminBanque < ActiveRecord::Migration[5.2]
  def change
    Admin::Banque.destroy_all

    rename_column :admin_banques, :description, :nom
    add_column :admin_banques, :bank_id, :integer
    add_column :admin_banques, :code_swift, :string, limit: 11
    change_column_default :admin_banques, :actif, from: nil, to: true
    change_column_null :admin_banques, :actif, false
  end
end
