json.extract! dossier_cnav, :id, :numero_dossier, :date_ouverture, :etat, :mois, :annee, :motif_rejet, :date_soumission, :soumis_par_id, :date_validation, :valide_par_id, :ajoute_par_id, :traite_le, :traite_par_id, :admin_region_id, :admin_agence_id, :agence_creation_id, :user_id, :created_at, :updated_at
json.url dossier_cnav_url(dossier_cnav, format: :json)
