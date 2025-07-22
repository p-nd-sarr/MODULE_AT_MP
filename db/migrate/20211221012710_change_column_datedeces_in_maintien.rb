class ChangeColumnDatedecesInMaintien < ActiveRecord::Migration[5.2]
  def change
    rename_column :maintien_prestations, :date_deces, :date_effective
  end
end
