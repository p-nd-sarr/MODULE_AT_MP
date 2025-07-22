class AddNotProlongationIndemniteConge < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnite_conges_maternites, :prolongation, :boolean, :default => false
  end
end
