class AddDossierIncompletToBaseReversionSalaries < ActiveRecord::Migration[5.2]
  def change
    add_column :base_reversion_salaries, :not_completed, :boolean, default: false
    add_column :base_reversion_salaries, :motif_not_completed, :integer
  end
end
