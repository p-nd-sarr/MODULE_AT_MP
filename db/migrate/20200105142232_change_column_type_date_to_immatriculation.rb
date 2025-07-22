class ChangeColumnTypeDateToImmatriculation < ActiveRecord::Migration[5.2]
  def change
    remove_column :immatriculations, :issuedDate
    remove_column :immatriculations, :expiryDate

    add_column :immatriculations, :issuedDate, :date
    add_column :immatriculations, :expiryDate, :date

    change_column :immatriculations, :nationality, :integer, using: 'nationality::integer'
  end
end
