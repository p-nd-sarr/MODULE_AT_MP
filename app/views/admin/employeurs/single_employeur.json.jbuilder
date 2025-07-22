unless @employeur.nil?
  json.extract! @employeur, :fhrsoc, :fhadr, :fhtel
end