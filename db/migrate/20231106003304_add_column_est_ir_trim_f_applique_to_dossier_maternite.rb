class AddColumnEstIrTrimFAppliqueToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :est_ir_trimf_applique, :boolean, default: true
  end
end
