class AddColumnDateNaissanceSalarieToAscendant < ActiveRecord::Migration[5.2]
  def change
    add_column :ascendants_salaries, :date_naissance_salarie, :date
  end
end
