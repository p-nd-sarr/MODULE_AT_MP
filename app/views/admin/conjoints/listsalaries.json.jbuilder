#json.array! @salaries

unless @salarie.nil?
  json.extract! @salarie, :matric, :prenom, :nom, :regime_matrimoniale, :date_naissance, :nombre_femme, :nin
end