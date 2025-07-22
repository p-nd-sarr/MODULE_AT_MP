class ChangeColumnEtatCivilDemandeurValide < ActiveRecord::Migration[5.2]
  def change
    rename_column :at_consolidations, :etat_civil_demandeur_valide, :information_consolidation_valide
    add_column :at_consolidations, :date_affectation_technicien, :datetime, null: true
    add_column :at_consolidations, :affectation_technicien, :integer, null: true
    add_column :at_consolidations, :date_verification, :datetime, null: true
    add_column :at_consolidations, :date_validation_chef_agence, :datetime, null: true
    add_column :at_consolidations, :date_validation_directeur_at, :datetime, null: true
    add_column :at_consolidations, :date_validation_audit, :datetime, null: true
    add_column :at_consolidations, :date_validation_directeur_general, :datetime, null: true
    add_column :at_consolidations, :taux_ipp_medecin_expert, :integer
  end
end
