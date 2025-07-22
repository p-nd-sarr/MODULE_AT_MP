class AddValidLiquidToDossierCnav < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_cnavs, :valider_liq_par_id, :integer
    add_column :dossier_cnavs, :valider_liq_le, :datetime
    add_column :dossier_cnavs, :valider_insp_par_id, :integer
    add_column :dossier_cnavs, :valider_insp_le, :datetime

    add_column :allocataire_cnavs, :valider_liq_par_id, :integer
    add_column :allocataire_cnavs, :valider_liq_le, :datetime
    add_column :allocataire_cnavs, :valider_insp_par_id, :integer
    add_column :allocataire_cnavs, :valider_insp_le, :datetime
  end
end
