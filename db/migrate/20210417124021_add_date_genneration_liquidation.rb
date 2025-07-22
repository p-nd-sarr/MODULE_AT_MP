class AddDateGennerationLiquidation < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :date_generation, :datetime
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end