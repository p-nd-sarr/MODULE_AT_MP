class ChangeTypeAvisTiersFromPaiementMarchand < ActiveRecord::Migration[5.2]
  def change
    change_column :paiement_allocataires, :avis_tiers, :float, default: 0, using: 'avis_tiers::double precision'
  end
end

# , using: 'type_immatriculation::integer'