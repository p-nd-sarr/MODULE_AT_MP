class AddDateConsolidationMc < ActiveRecord::Migration[5.2]
  def change
    add_column :at_consolidations, :date_consolidation_medecin_conseil, :datetime
    add_column :at_consolidations, :date_consolidation_medecin_expert, :datetime
    remove_column :at_consolidations, :date_consolidation, :datetime
    add_column :at_consolidations, :date_consolidation_medecin_traitant, :datetime
    add_column :at_consolidations, :taux_ipp_medecin_traitant, :float
    remove_column :at_consolidations, :taux_incapacite, :integer
    add_column :at_consolidations, :accord_taux_ipp, :boolean, default: false

  end
end
