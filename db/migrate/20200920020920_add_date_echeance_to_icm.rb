class AddDateEcheanceToIcm < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnite_conges_maternites, :date_echeance, :date

    add_column :dossier_maternites, :date_accouchement_reel, :date
    remove_column :dossier_maternites, :date_reprise
    add_column :dossier_maternites, :date_fin_cong_reel, :date
  end
end
