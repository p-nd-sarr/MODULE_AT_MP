class AddCircuitToPrestationExtFrance < ActiveRecord::Migration[5.2]
  def change
    add_column :cfs_reversion_veuves, :affectation_allocataire, :integer
    add_column :cfs_reversion_veuves, :affectation_allocataire_date, :datetime
    add_column :cfs_reversion_veuves, :recap_point_valide, :boolean, default: false
    add_column :cfs_reversion_veuves, :affectation_salarie, :integer
    add_column :cfs_reversion_veuves, :affectation_salarie_date, :datetime
    add_column :cfs_reversion_veuves, :instruit_par_id, :integer
    add_column :cfs_reversion_veuves, :instruit_le, :datetime
    add_column :cfs_reversion_veuves, :allocataire_id, :bigint
    add_column :cfs_reversion_veuves, :workflow_state, :string
    add_column :cfs_reversion_veuves, :type_retraite, :integer
  end
end
