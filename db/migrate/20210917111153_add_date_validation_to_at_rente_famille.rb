class AddDateValidationToAtRenteFamille < ActiveRecord::Migration[5.2]
  def change
    add_column :at_rente_familles, :rejete_par_id, :integer
    add_column :at_rente_familles, :valide_chef_agence_par_id, :integer
    add_column :at_rente_familles, :valide_chef_service_par_id, :integer
    add_column :at_rente_familles, :valide_dir_at_par_id, :integer
    add_column :at_rente_familles, :date_validation_chef_service, :datetime
    add_column :at_rente_familles, :date_validation_chef_agence, :datetime
    add_column :at_rente_familles, :date_validation_directeur_at, :datetime
    add_column :at_rente_familles, :date_validation_directeur_general, :datetime
    add_column :at_rente_familles, :valide_dg_par_id, :datetime
    add_column :at_rente_familles, :date_rejete, :integer

  end
end
