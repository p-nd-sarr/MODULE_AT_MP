class AddFieldupdateFullnameDateLiquidation < ActiveRecord::Migration[5.2]
  def change

    add_column :liquidation_retraites, :update_fullname_date, :datetime
    add_column :liquidation_retraites, :update_fullname_id, :integer
    add_column :liquidation_retraites, :update_fullname_commentaire, :string
  end
end
