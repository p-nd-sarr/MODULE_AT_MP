class AddDeclarantColumnToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :declarant, :integer
  end
end
