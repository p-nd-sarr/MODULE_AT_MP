class AddInfosToCfsConjoint < ActiveRecord::Migration[5.2]
  def change
    # add_column :cfs_conjoints, :user_id, :bigint
    add_reference :cfs_conjoints, :user, foreign_key: true
    add_column :cfs_conjoints, :nin, :string

    change_column_default :cfs_conjoints, :etat, 1

    add_column :cfs_conjoints, :est_salarie, :boolean
    add_column :cfs_conjoints, :numero_salarie, :string
    add_column :cfs_conjoints, :est_enceinte, :boolean, :default => false
    add_column :cfs_conjoints, :numero_affiliation, :string
    add_column :cfs_conjoints, :type_piece, :integer
    add_column :cfs_conjoints, :numero_piece, :string
    add_column :cfs_conjoints, :nom_salarie, :string
    add_column :cfs_conjoints, :prenom_salarie, :string
    add_column :cfs_conjoints, :date_delivrance_piece, :date
    add_column :cfs_conjoints, :date_expiration_piece, :date
    add_column :cfs_conjoints, :matric_conjoint, :string
    add_column :cfs_conjoints, :sex, :integer
    add_column :cfs_conjoints, :etat_conjoint, :integer
    add_column :cfs_conjoints, :regime_matrimoniale, :integer
    add_column :cfs_conjoints, :etat_civil, :integer
    add_column :cfs_conjoints, :rang_conjoint, :integer
    add_column :cfs_conjoints, :code_etat_civil, :string
    add_column :cfs_conjoints, :numero_registre, :string
    add_column :cfs_conjoints, :nin_generer, :string
    add_column :cfs_conjoints, :date_naissance_salarie, :date
    add_column :cfs_conjoints, :date_divorce, :date
    add_column :cfs_conjoints, :date_transcription, :date
    add_column :cfs_conjoints, :nombre_femmes, :integer
    add_column :cfs_conjoints, :date_etablissement_mariage, :date
    add_column :cfs_conjoints, :date_jugement_suppletif, :date
    add_column :cfs_conjoints, :date_expiration_piece_salarie, :date
    add_column :cfs_conjoints, :date_delivrance_piece_salarie, :date
    add_column :cfs_conjoints, :numero_jugement_mariage, :string
    add_column :cfs_conjoints, :est_repris, :boolean, :default => false, :null => false
    add_column :cfs_conjoints, :old_created_par, :string, :limit => 100
    add_column :cfs_conjoints, :old_conjoint_id, :string, :limit => 250
    add_column :cfs_conjoints, :date_declaration_divorce, :date
    add_column :cfs_conjoints, :date_declaration_deces, :date
    add_column :cfs_conjoints, :reprise_site, :integer
    add_column :cfs_conjoints, :deleted, :boolean, :default => false
    add_column :cfs_conjoints, :incomplete, :boolean, :default => false

  end
end
