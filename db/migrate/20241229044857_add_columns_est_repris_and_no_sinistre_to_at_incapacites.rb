class AddColumnsEstReprisAndNoSinistreToAtIncapacites < ActiveRecord::Migration[5.2]
  def change
    add_column :at_incapacites, :est_repris, :boolean, default: false
    add_column :at_incapacites, :no_sinistre, :string
  end
end
