class AddAgenceCreationToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def self.up
    add_column :liquidation_retraites, :agence_creation_id, :integer
    LiquidationRetraite.all.each { |l|
      l.agence_creation_id = l.ajoute_par.try(:admin_agence).try(:id)
      l.save
    }
  end

  def self.down
    remove_column :liquidation_retraites, :agence_creation_id
  end
end
