class AddColumnsForHistoriqueToIndemnitesPrestations < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnites_prestation_exterieures, :date_liquidation, :date
    add_column :indemnites_prestation_exterieures, :date_validation_chef_grp, :date
    add_column :indemnites_prestation_exterieures, :date_validation_chef_sub, :date
    add_column :indemnites_prestation_exterieures, :date_validation_cpt, :date
    add_column :indemnites_prestation_exterieures, :liquide_par_id, :integer
    add_column :indemnites_prestation_exterieures, :valide_chef_grp_par_id, :integer
    add_column :indemnites_prestation_exterieures, :valide_chef_sub_par_id, :integer
    add_column :indemnites_prestation_exterieures, :valide_cpt_par_id, :integer
  end
end
