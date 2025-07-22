unless @employeur.nil?
  json.extract! @employeur, :fhnum, :fhrsoc
end