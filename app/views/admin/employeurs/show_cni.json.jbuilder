unless @salarie.nil?
  json.extract! @salarie, :matric, :prenom, :nom, :libelle_regime, :genre
end