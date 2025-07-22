json.extract! admin_gesadm, :id, :matricule, :prenom, :nom, :lieu_naissance, :created_at, :updated_at
json.url admin_gesadm_url(admin_gesadm, format: :json)
