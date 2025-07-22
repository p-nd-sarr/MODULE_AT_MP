class DropDocumentIcMat < ActiveRecord::Migration[5.2]
  def change
    drop_table :document_ic_mats
  end
end
