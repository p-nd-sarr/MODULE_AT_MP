class AddJrPayesToIcm < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnite_conges_maternites, :nbre_jr_payes, :integer, default: 0, null: false

    add_column :dossier_maternites, :suspendu_par_id, :integer
    add_column :dossier_maternites, :date_suspension, :date
    add_column :dossier_maternites, :suspendu, :boolean, default: false, null: false
    DossierMaternite.where(suspendu: nil).update_all(suspendu: false)

    remove_column :dossier_maternites, :cloture
    add_column :dossier_maternites, :cloture_par_id, :integer
    add_column :dossier_maternites, :date_cloture, :date
    add_column :dossier_maternites, :cloture, :boolean, default: false, null: false
    DossierMaternite.where(cloture: nil).update_all(cloture: false)

    remove_column :dossier_maternites, :date_echeance
  end
end
