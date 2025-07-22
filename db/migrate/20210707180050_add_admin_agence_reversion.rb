class AddAdminAgenceReversion < ActiveRecord::Migration[5.2]
  def change

    add_column :reversion_veuves, :admin_agence_id, :integer
  end
end
