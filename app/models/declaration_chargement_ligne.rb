class DeclarationChargementLigne < ApplicationRecord
  belongs_to :declaration_chargement

  def date_entree
    t = []
    if annee_entree
      t << annee_entree
      if mois_entree
        t << mois_entree
        if jour_entree
          t << jour_entree
        end
      end
    end
    t.empty? ? nil : Date.new(*t)
  end

  def date_sortie
    t = []
    if annee_sortie
      t << annee_sortie
      if mois_sortie
        t << mois_sortie
        if jour_sortie
          t << jour_sortie
        end
      end
    end
    t.empty? ? nil : Date.new(*t)
  end

  def date_debut_periode_cotisation
    [Date.new(exercice, 1, 1), date_entree].compact.max
  end

  def date_fin_periode_cotisation
    [Date.new(exercice, 12, 31), date_sortie].compact.min
  end
end
