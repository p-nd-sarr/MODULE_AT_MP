class AddMandataireToIcm < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :nom_mandataire, :string
    add_column :dossier_maternites, :prenom_mandataire, :string
    add_column :dossier_maternites, :nin_mandataire, :string
  end
end
