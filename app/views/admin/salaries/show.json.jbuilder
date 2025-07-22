unless @salarie.nil?
  json.extract! @salarie, :matric, :css_ancien_matric, :prenom, :nom, :libelle_regime, :genre, :date_naissance, :type_piece, :numero_piece, :date_debut_contrat, :id_employeur
  json.date_embauche @salarie.carrieres.order('date_debut_periode_cotisation DESC').last.try(:date_debut_contrat)

end