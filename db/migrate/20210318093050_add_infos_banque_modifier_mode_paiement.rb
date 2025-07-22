class AddInfosBanqueModifierModePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_mode_paiements, :admin_banque_agence_id, :integer
    remove_column :modifier_mode_paiements, :compte_bancaire_code_banque, :string
    remove_column :modifier_mode_paiements, :compte_bancaire_code_guichet, :string
    add_column :modifier_mode_paiements, :compte_bancaire_cle_rib, :string, limit: 2
    change_column :modifier_mode_paiements, :compte_bancaire_numero_compte, :string, limit: 12
    
 
  end
end
