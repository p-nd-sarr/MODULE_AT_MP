json.array! @cfs_conjoints do |conjoint|
  json.nom conjoint.nom
  json.prenom conjoint.prenom
  json.date_naissance conjoint.date_naissance
end