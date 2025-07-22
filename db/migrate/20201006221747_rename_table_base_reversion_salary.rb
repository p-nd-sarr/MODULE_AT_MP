class RenameTableBaseReversionSalary < ActiveRecord::Migration[5.2]
  def change
    rename_table :base_reversion_salaries, :dossier_reversion_salaries
  end
end
