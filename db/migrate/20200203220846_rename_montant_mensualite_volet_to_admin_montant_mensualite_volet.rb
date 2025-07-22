class RenameMontantMensualiteVoletToAdminMontantMensualiteVolet < ActiveRecord::Migration[5.2]
  def change
    rename_table :montant_mensualite_volets , :admin_montant_mensualite_volets
  end
end
