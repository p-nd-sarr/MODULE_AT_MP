class AddColumnOpToCafIndemniteAssocs < ActiveRecord::Migration[5.2]
  def change
    add_reference :indemnites_prestation_exterieure_assocs, :ordre_paiement, index: { name: 'index_ipe_assocs_on_op_id' }, foreign_key: true
  end
end
