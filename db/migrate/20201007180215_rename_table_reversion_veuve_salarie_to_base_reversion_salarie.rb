class RenameTableReversionVeuveSalarieToBaseReversionSalarie < ActiveRecord::Migration[5.2]
  def change
    rename_table :reversion_veuve_salaries, :base_reversion_salaries
  end
end
