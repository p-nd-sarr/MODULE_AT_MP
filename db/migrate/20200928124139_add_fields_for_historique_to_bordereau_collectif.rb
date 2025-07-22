class AddFieldsForHistoriqueToBordereauCollectif < ActiveRecord::Migration[5.2]
  def change
    add_column :bordereau_collectifs, :workflow_state, :string
    add_column :bordereau_collectifs, :date_liquidation, :date
    add_column :bordereau_collectifs, :date_validation_chef_agence, :date
    add_column :bordereau_collectifs, :date_validation_comptable, :date
    add_column :bordereau_collectifs, :liquide_par_id, :integer
    add_column :bordereau_collectifs, :valide_chef_agence_par_id, :integer
    add_column :bordereau_collectifs, :valide_comptable_par_id, :integer

  end
end
