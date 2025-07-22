class AddColumnsEstReprisAndNoSinistreToAtCodePrimeSalaires < ActiveRecord::Migration[5.2]
  def change
    add_column :at_code_prime_salaires, :est_repris, :boolean, default: false
    add_column :at_code_prime_salaires, :no_sinistre, :string
  end
end
