class ChangeMontPaieToDossMat < ActiveRecord::Migration[5.2]
  def change
    change_column_default :dossier_maternites, :montant_salaire, 0
    DossierMaternite.where(montant_salaire: nil).update_all(montant_salaire: 0)
    change_column_null  :dossier_maternites, :montant_salaire, false

    change_column_default :dossier_maternites, :montant_indemnite, 0
    DossierMaternite.where(montant_indemnite: nil).update_all(montant_indemnite: 0)
    change_column_null  :dossier_maternites, :montant_indemnite, false

  end
end
