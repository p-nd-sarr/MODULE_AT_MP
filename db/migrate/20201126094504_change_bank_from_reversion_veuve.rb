class ChangeBankFromReversionVeuve < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuves, :admin_banque_agence_id, :integer
    add_column :reversion_veuves, :compte_bancaire_cle_rib, :string, limit: 2

    remove_column :reversion_veuves, :compte_bancaire_code_guichet, :string
    remove_column :reversion_veuves, :compte_bancaire_code_banque, :string
    remove_column :reversion_veuves, :compte_bancaire_nom_banque, :string
  end
end
