class AddNinAndPhoneAndMailToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :nin_allocataire, :string
    add_column :compta_transactions, :telephone_allocataire, :string
    add_column :compta_transactions, :mail_allocataire, :string
  end
end
