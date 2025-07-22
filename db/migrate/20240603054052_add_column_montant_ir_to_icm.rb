class AddColumnMontantIrToIcm < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :montant_ir, :integer
  end
end
