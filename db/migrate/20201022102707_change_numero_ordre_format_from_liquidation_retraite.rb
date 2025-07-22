class ChangeNumeroOrdreFormatFromLiquidationRetraite < ActiveRecord::Migration[5.2]
  def self.up
    LiquidationRetraite.all.order('created_at').each { |l|
      numero_ordre = LiquidationRetraite.where(numero_affiliation: l.numero_affiliation).
          where('created_at <= ?', l.created_at + 2.second).count

      l.num_dossier = "R/#{l.numero_affiliation}/#{l.created_at.year}/#{numero_ordre}"

      l.save
    }

    add_index :liquidation_retraites, :num_dossier, unique: true
  end

  def self.down
    remove_index :liquidation_retraites, :num_dossier
  end
end
