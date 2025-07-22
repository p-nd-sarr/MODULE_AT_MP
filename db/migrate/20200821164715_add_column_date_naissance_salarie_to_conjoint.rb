class AddColumnDateNaissanceSalarieToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :date_naissance_salarie, :date
  end
end
