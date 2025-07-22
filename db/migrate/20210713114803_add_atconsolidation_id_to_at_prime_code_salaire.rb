class AddAtconsolidationIdToAtPrimeCodeSalaire < ActiveRecord::Migration[5.2]
  def change
    add_reference :at_code_prime_salaires, :at_consolidation_id, null: true
    add_reference :at_code_prime_salaires, :at_rente_familles_id, null: true
  end
end
