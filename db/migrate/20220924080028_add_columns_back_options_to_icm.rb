class AddColumnsBackOptionsToIcm < ActiveRecord::Migration[5.2]
  def change

    add_column :dossier_maternites, :retourne_par_id, :integer
    add_column :dossier_maternites, :retourne_le, :date
    add_column :dossier_maternites, :motif_retour, :text
  end
end
