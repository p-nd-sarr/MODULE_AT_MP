class AddDateValidateAlocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :date_activation_dp, :datetime
    add_column :allocataires, :date_activation_insp, :datetime
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
