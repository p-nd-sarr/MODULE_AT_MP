class AddDatesSoumissionToArretTravail < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :date_soumission_dir_at, :datetime
    add_column :arret_travails, :date_acceptation, :datetime
    add_column :arret_travails, :date_soumission_comite, :datetime
    add_column :arret_travails, :date_rejet_dossier, :datetime
    add_column :arret_travails, :date_soumission_chef_service, :datetime
    add_column :arret_travails, :date_soumission_chef_agence, :datetime
    add_column :arret_travails, :date_affectation_redacteur, :datetime
    add_column :arret_travails, :date_affectation_tech, :datetime
    add_column :arret_travails, :accepte_par, :integer
    add_column :arret_travails, :rejete_par, :integer
    add_column :arret_travails, :soumis_chef_div_at_par, :integer
    add_column :arret_travails, :soumis_chef_agence_par, :integer
    add_column :arret_travails, :affecter_redacteur_par, :integer
    add_column :arret_travails, :affecter_tech_par, :integer

  end
end
