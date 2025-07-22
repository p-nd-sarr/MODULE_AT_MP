class AddInfosSupToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :telephone, :string, limit: 30
    add_column :dossier_maternites, :email, :string
    add_column :dossier_maternites, :subrogation, :boolean, default: false
    add_column :dossier_maternites, :nin, :string

    add_column :dossier_maternites, :attributaire, :boolean, default: false
    add_column :dossier_maternites, :nom_attributaire, :string
    add_column :dossier_maternites, :prenom_attributaire, :string
    add_column :dossier_maternites, :nin_attributaire, :string

    add_column :dossier_maternites, :mode_paiement, :integer
    add_column :dossier_maternites, :compte_bancaire_nom_banque, :string
    add_column :dossier_maternites, :compte_bancaire_code_banque, :string
    add_column :dossier_maternites, :compte_bancaire_code_guichet, :string
    add_column :dossier_maternites, :compte_bancaire_numero_compte, :string

    add_column :dossier_maternites, :raison_sociale, :string
    add_column :dossier_maternites, :num_immatriculation, :string
    add_column :dossier_maternites, :tel_employeur, :string
    add_column :dossier_maternites, :email_employeur, :string
    add_column :dossier_maternites, :adresse_employeur, :string
    add_column :dossier_maternites, :date_embauche, :string
    add_column :dossier_maternites, :categorie_travail, :string

    add_column :dossier_maternites, :tag_paiement_dossier, :integer
    add_column :dossier_maternites, :date_accouchement_prev, :date
    add_column :dossier_maternites, :date_fin_cong_prev, :date
    add_column :dossier_maternites, :date_reprise, :date
    add_column :dossier_maternites, :nbre_jr_repos, :integer
    add_column :dossier_maternites, :nbre_jr_payes, :integer

    add_column :indemnite_conges_maternites, :nbre_jr_repos, :integer

  end
end
