class AddProvenanceToCfs < ActiveRecord::Migration[5.2]
  def change
    add_column :periode_assurances, :provenance, :integer
    add_column :periode_assurances, :liquidation_retraite_france_id, :bigint, null: true
    add_column :carrieres_exterieures, :provenance, :integer
    add_column :carrieres_exterieures, :liquidation_retraite_france_id, :bigint, null: true
  end
end
