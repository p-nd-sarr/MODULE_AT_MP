class AddEstTiersToAtFraisEngages < ActiveRecord::Migration[5.2]
  def change
    add_column :at_frais_engages, :remboursement_tiers,  :boolean, default: false, null: false
  end
end
