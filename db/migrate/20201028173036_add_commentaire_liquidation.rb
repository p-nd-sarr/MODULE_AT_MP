class AddCommentaireLiquidation < ActiveRecord::Migration[5.2]
  def change

    add_column :liquidation_retraites, :commentaire, :text
  end
end
