class AddPaiementToPrestationExtFrance < ActiveRecord::Migration[5.2]
  def change
    add_column :cfs_reversion_veuves, :mode_paiement, :integer
    add_column :cfs_reversion_veuves, :compte_bancaire_nom_banque, :string
    add_column :cfs_reversion_veuves, :compte_bancaire_code_banque, :string
    add_column :cfs_reversion_veuves, :compte_bancaire_code_guichet, :string
    add_column :cfs_reversion_veuves, :compte_bancaire_numero_compte, :string

    add_column :cfs_reversion_veuves, :numero_dossier, :string
    rename_column :cfs_reversion_veuves, :num_affiliation, :numero_affiliation

  end
end
