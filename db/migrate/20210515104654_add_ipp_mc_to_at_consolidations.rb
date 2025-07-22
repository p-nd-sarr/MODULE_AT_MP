class AddIppMcToAtConsolidations < ActiveRecord::Migration[5.2]
  def change
    add_column :at_consolidations, :taux_ipp_mc, :integer
    add_column :at_consolidations, :avis_mc, :string
    add_column :at_consolidations, :date_validation_mc, :datetime
    add_column :at_consolidations, :date_validation_chef_service, :datetime
    add_column :at_consolidations, :date_soumission_chef_agence, :datetime
    add_column :at_consolidations, :date_soumission_tech, :datetime
    add_column :at_consolidations, :date_soumission_chef_service, :datetime
    add_column :at_consolidations, :decision_mc_valide,:boolean, default: false
  end
end
