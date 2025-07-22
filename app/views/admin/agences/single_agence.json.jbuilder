unless @admin_agence.nil?
  json.extract! @admin_agence, :id, :description_prest
end