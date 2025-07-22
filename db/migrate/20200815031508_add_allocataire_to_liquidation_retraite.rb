class AddAllocataireToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def self.up
    add_reference :liquidation_retraites, :allocataire, foreign_key: false
    LiquidationRetraite.all.each { |liquidation_retraite|
      liquidation_retraite.allocataire = Allocataire.find_by(numero_allocataire: liquidation_retraite.numero_affiliation)
      liquidation_retraite.save
    }
  end

  def self.down
    remove_reference :liquidation_retraites, :allocation
  end
end
