class RemoveUniqueEmailToBaseReversionSalary < ActiveRecord::Migration[5.2]
  def change
    remove_index :base_reversion_salaries, :email
  end
end
