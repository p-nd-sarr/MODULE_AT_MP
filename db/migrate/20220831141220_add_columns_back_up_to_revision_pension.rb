class AddColumnsBackUpToRevisionPension < ActiveRecord::Migration[5.2]
  def change
    add_column :revision_pensions, :previous_points_rc, :integer
    add_column :revision_pensions, :previous_points_base_rc, :integer
    add_column :revision_pensions, :previous_point_majoration_rc, :integer
    add_column :revision_pensions, :previous_point_minoration_rc, :integer
    add_column :revision_pensions, :previous_points_servis_rc, :integer
    add_column :revision_pensions, :previous_points_rg, :integer
    add_column :revision_pensions, :previous_points_base_rg, :integer
    add_column :revision_pensions, :previous_point_majoration_rg, :integer
    add_column :revision_pensions, :previous_point_minoration_rg, :integer
    add_column :revision_pensions, :previous_points_servis_rg, :integer
  end
end
