class AddColumnDossierPrestationIdToEcheanceVeuvesEpouses < ActiveRecord::Migration[5.2]
  def change
    add_reference :echeance_veuves_caisse_epouses, :dossier_prestation, foreign_key: true
  end
end
