class AddColumnToPaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :paiements, :references, :text, array:true, default: []

  end
end