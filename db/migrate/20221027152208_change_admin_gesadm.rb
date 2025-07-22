class ChangeAdminGesadm < ActiveRecord::Migration[5.2]
  def change
    change_column :admin_gesadms, :CDBKNB, :string
  end
end
