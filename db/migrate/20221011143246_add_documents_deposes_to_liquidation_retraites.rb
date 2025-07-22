class AddDocumentsDeposesToLiquidationRetraites < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :documents_deposes_obligatoires, :text, array: true, default: []
    add_column :liquidation_retraites, :documents_deposes_facultatifs, :text, array: true, default: []
  end
end
