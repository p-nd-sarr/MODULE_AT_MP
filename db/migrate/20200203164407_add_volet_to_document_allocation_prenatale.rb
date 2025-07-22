class AddVoletToDocumentAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_prenatales, :volet, :integer
  end
end
