unless @employeur.nil?
  json.extract! @employeur, :fhnum, :fhrsoc, :code_agence_css, :ancien_num_ipres, :ancien_num_css, :fheffa
end