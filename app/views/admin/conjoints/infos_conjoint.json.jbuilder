unless @conjoint.nil?
  json.extract! @conjoint, :prenom, :nom, :date_naissance, :numero_piece, :numero_affiliation
end