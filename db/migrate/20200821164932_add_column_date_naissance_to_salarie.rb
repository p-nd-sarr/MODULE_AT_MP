class AddColumnDateNaissanceToSalarie < ActiveRecord::Migration[5.2]
  def change
    add_column :salaries, :date_naissance, :date
  end
end
