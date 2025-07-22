class AddColmnsFacturesToMoratoires < ActiveRecord::Migration[5.2]
  def change

    add_column :moratoires, :factures, :text, array:true, default: []
  end
end
