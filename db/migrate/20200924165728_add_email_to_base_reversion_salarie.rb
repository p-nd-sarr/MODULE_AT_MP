class AddEmailToBaseReversionSalarie < ActiveRecord::Migration[5.2]
  def change
    add_column :base_reversion_salaries, :email, :string
    add_index :base_reversion_salaries, :email, unique: true
    add_column :base_reversion_salaries, :phone, :string
    add_column :base_reversion_salaries, :date_mariage, :date
  end
end
