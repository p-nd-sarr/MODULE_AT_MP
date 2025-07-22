class UpdateLimitOnNumeroCompteBancaire < ActiveRecord::Migration[5.2]
  def self.up
    change_column :liquidation_retraites, :compte_bancaire_numero_compte, :string, limit: 50
    change_column :allocataires, :compte_bancaire_numero_compte, :string, limit: 50
    change_column :demande_remboursement_cotisations, :compte_bancaire_numero_compte, :string, limit: 50
    change_column :dossier_maternites, :compte_bancaire_numero_compte, :string, limit: 50
    change_column :dossier_reversion_salaries, :compte_bancaire_numero_compte, :string, limit: 50
    change_column :modifier_mode_paiements, :compte_bancaire_numero_compte, :string, limit: 50
    change_column :cfs_reversion_veuves, :compte_bancaire_numero_compte, :string, limit: 50
    change_column :reversion_veuves, :compte_bancaire_numero_compte, :string, limit: 50
  end
end
