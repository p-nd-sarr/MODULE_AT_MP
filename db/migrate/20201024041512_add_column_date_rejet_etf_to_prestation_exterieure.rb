class AddColumnDateRejetEtfToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :date_rejet_etf, :date
  end
end
