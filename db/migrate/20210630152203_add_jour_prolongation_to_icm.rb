class AddJourProlongationToIcm < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnite_conges_maternites, :jours_prolongation, :integer
    add_column :dossier_maternites, :jours_prolongation, :integer
  end
end
