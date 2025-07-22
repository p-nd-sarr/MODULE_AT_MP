class AddSexeInBaseReversionSalaries < ActiveRecord::Migration[5.2]
  def change
    add_column :base_reversion_salaries, :sexe, :string
  end
end
