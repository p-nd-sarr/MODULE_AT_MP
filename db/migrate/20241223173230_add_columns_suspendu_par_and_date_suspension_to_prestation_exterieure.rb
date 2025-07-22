class AddColumnsSuspenduParAndDateSuspensionToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :suspendu_par_id, :integer
    add_column :prestation_exterieures, :date_suspension, :date
  end
end
