class AddQualiteDeclarantColumnToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :qualite_declarant, :string
  end
end
