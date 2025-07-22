class AddEstValiderColumnToAtIncapacites < ActiveRecord::Migration[5.2]
  def change
    add_column :at_incapacites, :est_valide, :boolean, default: :false
    add_column :at_incapacites, :at_decompte_id, :integer
  end
end
