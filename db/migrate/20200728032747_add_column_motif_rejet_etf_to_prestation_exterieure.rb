class AddColumnMotifRejetEtfToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :motif_rejet_etf, :string
  end
end
