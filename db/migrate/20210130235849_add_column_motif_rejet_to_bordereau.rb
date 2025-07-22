class AddColumnMotifRejetToBordereau < ActiveRecord::Migration[5.2]
  def change
    add_column :bordereau_collectifs, :motif_rejet, :string
  end
end
