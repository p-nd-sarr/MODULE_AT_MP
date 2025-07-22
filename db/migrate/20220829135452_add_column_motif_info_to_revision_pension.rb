class AddColumnMotifInfoToRevisionPension < ActiveRecord::Migration[5.2]
  def change
    add_column :revision_pensions, :retourne_par_id, :integer
    add_column :revision_pensions, :retourne_le, :date
  end
end
