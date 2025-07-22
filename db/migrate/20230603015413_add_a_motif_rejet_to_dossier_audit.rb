class AddAMotifRejetToDossierAudit < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_audits, :motif_rejet, :text
  end
end
