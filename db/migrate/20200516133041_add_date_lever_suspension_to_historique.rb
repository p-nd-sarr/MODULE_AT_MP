class AddDateLeverSuspensionToHistorique < ActiveRecord::Migration[5.2]
  def change
    add_column :historiques, :date_lever_suspension, :date
  end
end