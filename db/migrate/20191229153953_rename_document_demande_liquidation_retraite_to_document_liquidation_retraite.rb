class RenameDocumentDemandeLiquidationRetraiteToDocumentLiquidationRetraite < ActiveRecord::Migration[5.2]
  def self.up
    rename_table :document_demande_liquidations, :document_liquidation_retraites
    ActiveStorage::Attachment.where(record_type: 'DocumentDemandeLiquidation').update(record_type: 'DocumentLiquidationRetraite')
  end

  def self.down
    rename_table :document_liquidation_retraites, :document_demande_liquidations
    ActiveStorage::Attachment.where(record_type: 'DocumentLiquidationRetraite').update(record_type: 'DocumentDemandeLiquidation')
  end
end
