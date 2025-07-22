class AddColumnsBackOptionsToIcmIndemnite < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnite_conges_maternites, :retourne_par_id, :integer
    add_column :indemnite_conges_maternites, :retourne_le, :date
    add_column :indemnite_conges_maternites, :motif_retour, :text
  end
end
