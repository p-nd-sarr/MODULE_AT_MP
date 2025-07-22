class AddColumnsDateRangeToIndemnitesPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnites_prestation_exterieures, :date_debut, :date
    add_column :indemnites_prestation_exterieures, :date_fin, :date
  end
end
