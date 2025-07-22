class AddUsageAndTrimestre < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_cnavs, :usage, :integer
    add_column :dossier_cnavs, :trimestre, :integer

    DossierCnav.where(usage: nil).update_all(usage: 1)
  end
end
