class AddColumnsForPaiementIndividuelToEcheanceCaisseDossier < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_caisse_dossiers, :is_individual_payment, :boolean, default: false
    add_column :echeance_caisse_dossiers, :individual_payment_by, :integer
  end
end
