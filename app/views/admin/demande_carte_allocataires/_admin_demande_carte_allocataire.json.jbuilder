json.extract! admin_demande_carte_allocataire, :id, :user_id, :numero_document, :agence_enregistrement_id, :nom, :prenom, :date_naissance, :nin, :email, :adresse, :agence_retrait_id, :telephone, :created_at, :updated_at
json.url admin_demande_carte_allocataire_url(admin_demande_carte_allocataire, format: :json)
