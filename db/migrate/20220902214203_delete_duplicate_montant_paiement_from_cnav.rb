class DeleteDuplicateMontantPaiementFromCnav < ActiveRecord::Migration[5.2]
  def change
    remove_column :allocataire_cnavs, :montant_paiement
  end
end
