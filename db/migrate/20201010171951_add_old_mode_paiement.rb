class AddOldModePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_mode_paiements, :old_mode_paiement, :string
    add_column :modifier_mode_paiements, :old_compte_bancaire_nom_banque, :string
    add_column :modifier_mode_paiements, :old_compte_bancaire_code_banque, :string
    add_column :modifier_mode_paiements, :old_compte_bancaire_code_guichet, :string
    add_column :modifier_mode_paiements, :old_compte_bancaire_numero_compte, :string
  end
end
