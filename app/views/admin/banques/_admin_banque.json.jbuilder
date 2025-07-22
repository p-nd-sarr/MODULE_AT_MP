json.extract! admin_banque, :id, :code, :description, :actif, :created_at, :updated_at
json.url admin_banque_url(admin_banque, format: :json)
