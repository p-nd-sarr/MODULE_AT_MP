class AddOldColumsToGrappe < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :old_created_par, :string, limit: 100
    add_column :conjoints, :old_conjoint_id, :string, limit: 250

    add_column :enfants, :old_conjoint_id, :string, limit: 250
    add_column :enfants, :old_id, :string, limit: 250
    add_column :enfants, :old_created_par, :string, limit: 100
  end
end
