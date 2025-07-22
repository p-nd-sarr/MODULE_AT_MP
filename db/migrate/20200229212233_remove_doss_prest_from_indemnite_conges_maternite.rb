class RemoveDossPrestFromIndemniteCongesMaternite < ActiveRecord::Migration[5.2]
  def change
    remove_column :indemnite_conges_maternites, :dossier_prestation_id
  end
end
