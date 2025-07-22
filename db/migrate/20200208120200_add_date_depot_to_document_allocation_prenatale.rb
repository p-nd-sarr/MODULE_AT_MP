class AddDateDepotToDocumentAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :document_allocation_prenatales, :date_depot, :date
  end
end
