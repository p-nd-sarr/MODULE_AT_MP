class UpdateColummnMontantFromPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    change_column :indemnites_prestation_exterieures, :montant, :float
  end
end
