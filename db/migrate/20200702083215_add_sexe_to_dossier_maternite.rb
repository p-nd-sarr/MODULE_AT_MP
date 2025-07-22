class AddSexeToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :sexe_salarie, :integer
    add_column :dossier_maternites, :montant_salaire, :integer
    add_column :dossier_maternites, :montant_indemnite, :integer

  end
end
