class AddEmailToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :email, :string, default: ""
    add_column :liquidation_retraites, :num_dossier, :string

  end
end
