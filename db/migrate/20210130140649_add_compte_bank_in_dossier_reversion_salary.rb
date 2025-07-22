class AddCompteBankInDossierReversionSalary < ActiveRecord::Migration[5.2]
  def change
    remove_column :dossier_reversion_salaries, :compte_bancaire_nom_banque
    remove_column :dossier_reversion_salaries, :compte_bancaire_code_banque
    remove_column :dossier_reversion_salaries, :compte_bancaire_numero_compte

    add_column :dossier_reversion_salaries, :admin_banque_agence_id, :integer
    add_column :dossier_reversion_salaries, :compte_bancaire_cle_rib, :string, limit: 2
    add_column :dossier_reversion_salaries, :compte_bancaire_numero_compte, :string, limit: 12
  end
end
