class AddAfecteAToBaseRevrsionSalaries < ActiveRecord::Migration[5.2]
  def change
    add_column :base_reversion_salaries, :affecte_a_id, :integer
  end
end
