class CreateDocumentDemandeLiquidations < ActiveRecord::Migration[5.2]
  def change
    create_table :document_demande_liquidations do |t|
      t.references :demande_liquidation
      t.integer :type_document, null: false
      t.text :commentaire

      t.timestamps
    end
  end
end
