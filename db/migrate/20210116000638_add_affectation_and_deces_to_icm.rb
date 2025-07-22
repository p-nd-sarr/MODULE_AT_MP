class AddAffectationAndDecesToIcm < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :affectation_controleur_date, :datetime
    add_column :dossier_maternites, :affectation_controleur, :integer
    add_column :dossier_maternites, :date_rapport_joint, :datetime
    add_column :dossier_maternites, :nombre_part_impot, :integer
    add_column :dossier_maternites, :valeur_impot, :integer

    add_column :dossier_maternites, :decedee, :boolean, default: false
    DossierMaternite.where(decedee: nil).update_all(decedee: false)
    add_column :dossier_maternites, :date_deces, :date

    add_column :indemnite_conges_maternites, :decedee, :boolean, default: false
    IndemniteCongesMaternite.where(decedee: nil).update_all(decedee: false)
    add_column :indemnite_conges_maternites, :date_deces, :date
    add_column :indemnite_conges_maternites, :nom_mandataire, :string
    add_column :indemnite_conges_maternites, :prenom_mandataire, :string
    add_column :indemnite_conges_maternites, :nin_mandataire, :string

    add_column :indemnite_conges_maternites, :cas_force_majeur, :boolean, default: false
    IndemniteCongesMaternite.where(cas_force_majeur: nil).update_all(cas_force_majeur: false)
  end
end
