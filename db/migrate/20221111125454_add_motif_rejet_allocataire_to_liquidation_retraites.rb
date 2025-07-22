# frozen_string_literal: true

class AddMotifRejetAllocataireToLiquidationRetraites < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :motif_rejet_allocataire, :string
    add_column :liquidation_retraites, :rejet_allocataire_par_id, :integer
    add_column :liquidation_retraites, :date_rejet_allocataire, :datetime
  end
end
