class MontantRevision < ApplicationRecord
  belongs_to :revision_pension, class_name: 'RevisionPension', foreign_key: :revision_pension_id

  has_many :carrieres, through: :revision_pension

  before_create :set_values

  def nb_mois
    (periode_fin.year * 12 + periode_fin.month) - (periode_debut.year * 12 + periode_debut.month) + 1
    # (periode_fin - periode_debut).to_i / 28
  end

  def montant
    return montant_revision if montant_revision % 5 == 0
    rounded = montant_revision.round(-1)
    rounded > montant_revision ? rounded : rounded + 5
  end

  def calcul_points_regime_general
    carrieres.valide.regime_general.sum(:points)
  end

  def calcul_points_regime_cadre
    carrieres.valide.regime_cadre.sum(:points)
  end

  def calcul_points
    carrieres.valide.sum(:points)
  end

  def calcul_points_gratuits_regime_general
    (carrieres.valide.regime_general.sum(&:points_gratuits)).ceil
  end

  def calcul_points_gratuits_regime_cadre
    (carrieres.valide.regime_cadre.sum(&:points_gratuits)).ceil
  end

  def calcul_points_gratuits
    carrieres.valide.sum(&:points_gratuits)
  end

  def calcul_points_minoration_regime_general
    carrieres.valide.regime_general.map do |carriere|
      (1.0 * (carriere.points + carriere.points_gratuits) * taux_minoration_rg / 100)
    end.sum.round
  end

  def calcul_points_minoration_regime_cadre
    carrieres.valide.regime_cadre.map do |carriere|
      (1.0 * (carriere.points + carriere.points_gratuits) * taux_minoration_rc / 100)
    end.sum.round
  end

  def calcul_points_minoration
    calcul_points_minoration_regime_general + calcul_points_minoration_regime_cadre
  end

  def taux_minoration_rc
    revision_pension.allocataire.pourcentage_minoration_rc
  end

  def taux_minoration_rg
    revision_pension.allocataire.pourcentage_minoration_rg
  end

  def calcul_points_base_regime_general
    (calcul_points_regime_general + calcul_points_gratuits_regime_general - calcul_points_minoration_regime_general).ceil
  end

  def calcul_points_base_regime_cadre
    (calcul_points_regime_cadre + calcul_points_gratuits_regime_cadre - calcul_points_minoration_regime_cadre).ceil
  end

  def calcul_points_base
    calcul_points_base_regime_general + calcul_points_base_regime_cadre
  end

  def taux_majoration
    taux = [15, 5 * revision_pension.allocataire.nombre_enfants_mineurs(periode_debut)].min
    (1.0 * taux)
  end

  def calcul_points_majoration_regime_general
    (1.0 * calcul_points_base_regime_general * taux_majoration / 100).round
  end

  def calcul_points_majoration_regime_cadre
    (1.0 * calcul_points_base_regime_cadre * taux_majoration / 100).round
  end

  def calcul_points_majoration
    (calcul_points_majoration_regime_general + calcul_points_majoration_regime_cadre).ceil
  end

  def calcul_points_servis_regime_general
    (calcul_points_base_regime_general + calcul_points_majoration_regime_general).ceil
  end

  def calcul_points_servis_regime_cadre
    (calcul_points_base_regime_cadre + calcul_points_majoration_regime_cadre).ceil
  end

  def calcul_points_servis
    calcul_points_base + calcul_points_majoration
  end

  def calcul_allocation_regime_general
    if revision_pension.allocataire.versement_unique?
      salaire_reference = Admin::Bareme.salaire_reference_general_du(periode_debut.last_year)
      (calcul_points_servis_regime_general * salaire_reference).ceil
    else
      valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_general_du(periode_debut)
      (calcul_points_servis_regime_general * valeur_point_mensuelle).ceil
    end
  end

  def calcul_barem_reg
    Admin::BaremePension.valeur_mensuelle_general_du(periode_debut)
  end

  def calcul_allocation_regime_cadre
    if revision_pension.allocataire.versement_unique?
      salaire_reference = Admin::Bareme.salaire_reference_cadre_du(periode_debut.last_year)
      (calcul_points_servis_regime_cadre * salaire_reference).ceil
    else
      valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_cadre_du(periode_debut)
      (calcul_points_servis_regime_cadre * valeur_point_mensuelle).ceil
    end
  end

  def calcul_barem_rcc
    Admin::BaremePension.valeur_mensuelle_cadre_du(periode_debut)
  end

  def calcul_allocation
    (calcul_allocation_regime_general + calcul_allocation_regime_cadre).ceil
  end

  private

  def set_values
    self.montant_revision = self.calcul_allocation
    self.points_cotisation = self.calcul_points
    self.points_minoration = self.calcul_points_minoration
    self.points_base = self.calcul_points_base
    self.point_majoration = self.calcul_points_minoration
    self.points_servis = self.calcul_points_servis
    self.points_gratuits = self.calcul_points_gratuits

    self.montant_revision_rc = self.calcul_allocation_regime_cadre
    self.points_cotisation_rc = self.calcul_points_regime_cadre
    self.points_minoration_rc = self.calcul_points_minoration_regime_cadre
    self.points_base_rc = self.calcul_points_base_regime_cadre
    self.points_majoration_rc = self.calcul_points_majoration_regime_cadre
    self.points_servis_rc = self.calcul_points_servis_regime_cadre
    self.points_gratuits_rc = self.calcul_points_gratuits_regime_cadre

    self.montant_revision_rg = self.calcul_allocation_regime_general
    self.points_cotisation_rg = self.calcul_points_regime_general
    self.points_minoration_rg = self.calcul_points_minoration_regime_general
    self.points_base_rg = self.calcul_points_base_regime_general
    self.points_majoration_rg = self.calcul_points_majoration_regime_general
    self.points_servis_rg = self.calcul_points_servis_regime_general
    self.points_gratuits_rg = self.calcul_points_gratuits_regime_general

    self.montant_revision_total = self.montant_revision * nb_mois
  end
end
