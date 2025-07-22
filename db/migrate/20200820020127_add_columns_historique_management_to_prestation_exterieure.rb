class AddColumnsHistoriqueManagementToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :soumis_etf_par_id, :integer
    add_column :prestation_exterieures, :date_soumission_etf, :datetime

    add_column :prestation_exterieures, :valide_etf_par_id, :integer
    add_column :prestation_exterieures, :date_validation_etf, :datetime

    add_column :prestation_exterieures, :soumis_liq_par_id, :integer
    add_column :prestation_exterieures, :date_soumission_liq, :datetime

    add_column :prestation_exterieures, :valide_liq_par_chef_grp_id, :integer
    add_column :prestation_exterieures, :date_validation_liq_chef_grp, :datetime

    add_column :prestation_exterieures, :valide_liq_par_chef_sub_id, :integer
    add_column :prestation_exterieures, :date_validation_liq_chef_sub, :datetime

    add_column :prestation_exterieures, :valide_liq_comptable_id, :integer
    add_column :prestation_exterieures, :date_validation_liq_comptable, :datetime


  end
end
