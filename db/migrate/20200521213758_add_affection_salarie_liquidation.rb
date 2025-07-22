class AddAffectionSalarieLiquidation < ActiveRecord::Migration[5.2]
  def self.up
    add_column :liquidation_retraites, :affectation_salarie, :integer
    add_column :liquidation_retraites, :affectation_salarie_date, :datetime


    rename_column :liquidation_retraites, :affecter_id, :affectation_allocataire
    rename_column :liquidation_retraites, :affecter_le, :affectation_allocataire_date
  end

  def self.down
    remove_column :liquidation_retraites, :affectation_salarie
    remove_column :liquidation_retraites, :affectation_salarie_date
  end
end
