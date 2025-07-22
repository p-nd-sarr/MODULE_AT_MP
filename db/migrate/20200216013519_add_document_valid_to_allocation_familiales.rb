class AddDocumentValidToAllocationFamiliales < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :document_valid, :boolean
    change_column :allocation_familiales, :etat, :integer, default: 1
  end
end
