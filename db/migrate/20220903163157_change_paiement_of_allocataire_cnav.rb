class ChangePaiementOfAllocataireCnav < ActiveRecord::Migration[5.2]
  def change
    change_column_default :allocataire_cnavs, :paiement, false
    AllocataireCnav.where(paiement: nil).update_all(paiement: false )
  end
end
