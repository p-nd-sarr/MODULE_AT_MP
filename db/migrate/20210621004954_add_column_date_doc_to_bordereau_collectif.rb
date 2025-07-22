class AddColumnDateDocToBordereauCollectif < ActiveRecord::Migration[5.2]
  def change
    add_column :bordereau_collectifs, :date_document, :date
  end
end
