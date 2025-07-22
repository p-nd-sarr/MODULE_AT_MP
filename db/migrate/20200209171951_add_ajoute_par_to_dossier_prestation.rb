class AddAjouteParToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :ajoute_par_id, :integer
    add_column :allocation_prenatales, :ajoute_par_id, :integer

    DossierPrestation.all.each { |d| d.update(ajoute_par_id: d.user_id) }
    AllocationPrenatale.all.each { |a| a.update(ajoute_par_id: a.user_id) }
  end
end
