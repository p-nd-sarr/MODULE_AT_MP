class AddInformationsToCfsEnfants < ActiveRecord::Migration[5.2]
  def change
    remove_column :cfs_enfants, :filiation
    remove_column :cfs_enfants, :situation

    add_reference :cfs_enfants, :user, foreign_key: true
    add_reference :cfs_enfants, :cfs_conjoint, foreign_key: true

    add_column :cfs_enfants, :prenom_mere, :string
    add_column :cfs_enfants, :nom_mere, :string
    add_column :cfs_enfants, :prenom_pere, :string
    add_column :cfs_enfants, :nom_pere, :string
    add_column :cfs_enfants, :numero_affiliation, :string
    add_column :cfs_enfants, :origine_enfant, :integer
    add_column :cfs_enfants, :type_piece, :integer
    add_column :cfs_enfants, :numero_piece, :string
    add_column :cfs_enfants, :sexe, :integer
    add_column :cfs_enfants, :numero_registre, :string
    add_column :cfs_enfants, :code_etat_civil, :string
    add_column :cfs_enfants, :nom_mere_naturel, :string
    add_column :cfs_enfants, :prenom_mere_naturel, :string
    add_column :cfs_enfants, :nin_generer, :string
    add_column :cfs_enfants, :date_delivrance_piece, :date
    add_column :cfs_enfants, :date_transcription, :date
    add_column :cfs_enfants, :date_expiration_piece, :date
    add_column :cfs_enfants, :est_repris, :boolean
    add_column :cfs_enfants, :date_declaration_deces, :date
    add_column :cfs_enfants, :deleted, :boolean
    add_column :cfs_enfants, :incomplete, :boolean

    add_column :cfs_enfants, :numero_securite_sociale, :string

  end
end
