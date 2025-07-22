class AddVoletCarnetToDocumentAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :document_allocation_prenatales, :volet, :integer
  end
end
