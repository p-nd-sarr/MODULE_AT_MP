class AddAtRechuteIdToCodePrimeSalaire < ActiveRecord::Migration[5.2]
  def change
    add_column :at_code_prime_salaires, :at_rechute_id, :integer
  end
end
