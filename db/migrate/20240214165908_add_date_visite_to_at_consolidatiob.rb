class AddDateVisiteToAtConsolidatiob < ActiveRecord::Migration[5.2]
  def change
    add_column :at_consolidations, :date_visite, :date
  end
end
