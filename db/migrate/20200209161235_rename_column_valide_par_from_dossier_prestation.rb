class RenameColumnValideParFromDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    rename_column :dossier_prestations, :valide_par_id, :traite_par_id
    rename_column :allocation_prenatales, :valide_par_id, :traite_par_id

    add_column :dossier_prestations, :traite_le, :datetime
    add_column :allocation_prenatales, :traite_le, :datetime

  end
end
