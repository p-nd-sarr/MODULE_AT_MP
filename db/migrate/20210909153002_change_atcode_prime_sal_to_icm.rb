class ChangeAtcodePrimeSalToIcm < ActiveRecord::Migration[5.2]
  def change
    remove_column :composant_salaire_icms, :at_code_prime_salaire_id
    add_column :composant_salaire_icms, :composant_salaire_id, :integer
  end
end
