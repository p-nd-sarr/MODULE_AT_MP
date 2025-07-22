class RemoveNumeroCompte2ToModificationModePaiement < ActiveRecord::Migration[5.2]
  def change
    remove_column :modifier_mode_paiements, :compte_bancaire_numero_compte2, :string
  end
end
