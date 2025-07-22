class AddAgenceToEcheanceVeuves < ActiveRecord::Migration[5.2]
  def change
    add_reference :echeance_veuves_caisse_epouses, :admin_agence, foreign_key: true
  end
end
