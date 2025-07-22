class AddColumnsToCafConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :caf_conjoints, :est_repris, :boolean, default: false
    add_column :caf_conjoints, :ajoute_par_id, :integer
  end
end
