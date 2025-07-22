json.extract! dossier_prestation, :id, :sexe_salarie, :num_affiliation, :prenom, :nom, :date_naissance, :lieu_naissance, :adresse_domicile, :etat, :date_soumission, :date_validation, :valide_par_id, :etat_civil_demandeur_valid, :carriere_valid, :conjoint_valid, :enfants_valid, :document_valid, :user_id, :created_at, :updated_at
json.url dossier_prestation_url(dossier_prestation, format: :json)
