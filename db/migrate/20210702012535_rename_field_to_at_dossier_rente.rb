class RenameFieldToAtDossierRente < ActiveRecord::Migration[5.2]
  def change
    add_column :at_dossier_reversion_rentes, :at_rente_famille_id, :integer
    remove_column :at_dossier_reversion_rentes, :at_base_reversion_rente_id, :integer
  end
end
