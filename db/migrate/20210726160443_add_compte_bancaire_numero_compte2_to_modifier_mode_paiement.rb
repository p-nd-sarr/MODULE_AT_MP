class AddCompteBancaireNumeroCompte2ToModifierModePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_mode_paiements, :compte_bancaire_numero_compte2, :string, limit: 25
  end
end
