unless @cfs_conjoint.nil?
  json.extract! @cfs_conjoint, :numero_affiliation, :prenom, :nom, :libelle_regime, :genre, :date_naissance, :type_piece, :numero_piece, :date_debut_contrat, :id_employeur
  # json.date_embauche @salarie.carrieres.order('date_debut_periode_cotisation DESC').last.try(:date_debut_contrat)

end