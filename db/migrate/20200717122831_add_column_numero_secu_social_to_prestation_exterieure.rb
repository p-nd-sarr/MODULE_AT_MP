class AddColumnNumeroSecuSocialToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :numero_secu_social, :string
  end
end
