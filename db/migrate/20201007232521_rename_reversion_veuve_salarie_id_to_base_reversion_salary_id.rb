class RenameReversionVeuveSalarieIdToBaseReversionSalaryId < ActiveRecord::Migration[5.2]
  def change
    rename_column :dossier_reversion_salaries, :reversion_veuve_salarie_id, :base_reversion_salary_id
  end
end
