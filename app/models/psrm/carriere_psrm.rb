class Psrm::CarrierePsrm < Psrm::DbBase
  self.table_name = 'CISADM.CM_CARRIER_VIEW'

=begin
  Nom                           NULL ? Type
  ----------------------------- ------ -------------
  MATRIC                               CHAR(10)
  FHNUM                                CHAR(10)
  PRENOM                               VARCHAR2(50)
  NOM                                  VARCHAR2(50)
  FHRSOC                               VARCHAR2(254)
  REGIME                               VARCHAR2(3)
  DATE_DEBUT_CONTRAT                   DATE
  DATE_FIN_CONTRAT                     DATE
  MOTIF_SORTIE                         VARCHAR2(30)
  DATE_DEBUT_PERIODE_COTISATION        DATE
  DATE_FIN_PERIODE_COTISATION          DATE
  TOTAL_SAL_CSS_ATMP_1                 NUMBER(20)
  TOTAL_SAL_CSS_ATMP_2                 NUMBER(20)
  TOTAL_SAL_CSS_ATMP_3                 NUMBER(20)
  TOTAL_SAL_CSS_PF_1                   NUMBER(20)
  TOTAL_SAL_CSS_PF_2                   NUMBER(20)
  TOTAL_SAL_CSS_PF_3                   NUMBER(20)
  TOTAL_SAL_IPRES_RG_1                 NUMBER(20)
  TOTAL_SAL_IPRES_RG_2                 NUMBER(20)
  TOTAL_SAL_IPRES_RG_3                 NUMBER(20)
  TOTAL_SAL_IPRES_RCC_1                NUMBER(20)
  TOTAL_SAL_IPRES_RCC_2                NUMBER(20)
  TOTAL_SAL_IPRES_RCC_3                NUMBER(20)
=end

  belongs_to :employeur, foreign_key: :fhnum, primary_key: :fhnum
  belongs_to :participant, foreign_key: :matric, primary_key: :matric

  scope :regime_general, -> { where(regime: 'RG') }
  scope :regime_cadre, -> { where(regime: 'RCC') }

  # @return [Psrm::Participant]
  def participant
    Psrm::Participant.find_by(matric: matric)
  end

  def date_debut
    date_debut_periode_cotisation
  end

  def date_fin
    date_fin_periode_cotisation
  end

  def nb_jours_travail
    (date_fin - date_debut).to_i + 1
  end

  def date_du_jours
    Date.today
  end

  def exercice
    date_debut.year
  end

  def self.lineaire?(matricule)
    carrieres = Psrm::Carriere.where(matric: matricule)
    return true if carrieres.empty?
    exercices = carrieres.map(&:exercice).uniq
    annee_min = exercices.min
    annee_max = exercices.max
    ((annee_min..annee_max).to_a - exercices).empty?
  end

  def self.lineaire_employeur?(employeur_id)
    carrieres = Psrm::Carriere.where(fhnum: employeur_id)
    return true if carrieres.empty?
    exercices = carrieres.map(&:exercice).uniq
    annee_min = exercices.min
    annee_max = exercices.max
    ((annee_min..annee_max).to_a - exercices).empty?
  end

  # @return [Admin::TypeRegime]
  def type_regime
    return Admin::TypeRegime::general if self.REGIME == 'RG'
    return Admin::TypeRegime::cadre if self.REGIME == 'RCC'
    nil
  end

  def regime_cadre?
    regime == 'RCC'
  end

  def regime_general?
    regime == 'RG'
  end

  # @return [Admin::Bareme]
  def bareme_rg
    Admin::TypeRegime::general.admin_baremes.find_by("date_debut_validite <= ? AND date_fin_validite >= ?", date_debut, date_debut)
  end

  # @return [Admin::Bareme]
  def bareme_rcc
    Admin::TypeRegime::cadre.admin_baremes.find_by("date_debut_validite <= ? AND date_fin_validite >= ?", date_debut, date_debut)
  end

  def salaire_rg
    (total_sal_ipres_rg_1 || 0) + (total_sal_ipres_rg_2 || 0) + (total_sal_ipres_rg_3 || 0)
  end

  def salaire_rcc
    (total_sal_ipres_rcc_1 || 0) + (total_sal_ipres_rcc_2 || 0) + (total_sal_ipres_rcc_3 || 0)
  end

  def calcul_points_rg
    return 0 if bareme_rg.nil?
    (1.0 * [salaire_rg, bareme_rg.plafond_salaire].min * bareme_rg.coefficient).round
  end

  def calcul_points_rcc
    return 0 if bareme_rcc.nil?
    (1.0 * [salaire_rcc, bareme_rcc.plafond_salaire].min * bareme_rcc.coefficient).round
  end

  def calcul_points
    calcul_points_rg + calcul_points_rcc
  end

  def load_to_prestation
    unless Carriere.exists?(numero_affiliation: matric,
                            type_regime: Admin::TypeRegime::general,
                            date_entree: date_debut,
                            date_sortie: date_fin)
      Carriere.create(
        numero_affiliation: matric,
        ref_employeur: fhnum,
        raison_sociale: fhrsoc,
        salaire1: salaire_rg || 0,
        salaire2: 0,
        salaire: salaire_rg || 0,
        points: calcul_points_rg,
        exercice: exercice,
        date_entree: date_debut,
        date_sortie: date_fin,
        motif_rejet: self.motif_sortie,
        type_regime: Admin::TypeRegime::general,
        etat: :en_attente,
        est_repris: true
      )
    end

    unless Carriere.exists?(numero_affiliation: matric,
                            type_regime: Admin::TypeRegime::cadre,
                            date_entree: date_debut,
                            date_sortie: date_fin)
      Carriere.create(
        numero_affiliation: matric,
        ref_employeur: fhnum,
        raison_sociale: fhrsoc,
        salaire1: salaire_rcc || 0,
        salaire2: 0,
        salaire: salaire_rcc || 0,
        points: calcul_points_rcc,
        exercice: exercice,
        date_entree: date_debut,
        date_sortie: date_fin,
        motif_rejet: self.motif_sortie,
        type_regime: Admin::TypeRegime::cadre,
        etat: :en_attente,
        est_repris: true
      )
    end
  end

=begin
  def calcul_points_base(liquidation_retraite)
    calcul_points + points_gratuits - calcul_points_minoration(liquidation_retraite)
  end

  # @param [LiquidationRetraite] liquidation_retraite
  def calcul_points_minoration(liquidation_retraite)
    return 0 if liquidation_retraite.retraite_normale? or liquidation_retraite.retraite_anticipee_invalide?
    if liquidation_retraite.retraite_anticipee_valide?
      if liquidation_retraite.age_ouverture_demande_en_mois >= 12
        coefficient_minoration = if regime_general?
                                   1.0 * [25, (60 - liquidation_retraite.age_ouverture_demande) * 5].min / 100
                                 elsif regime_cadre?
                                   1.0 * [20, (60 - liquidation_retraite.age_ouverture_demande) * 4].min / 100
                                 end
      else
        nb_mois = liquidation_retraite.age_ouverture_demande_en_mois
        n_semestres = (nb_mois / 3.0).ceil
        coefficient_minoration = if regime_general?
                                   1.0 * [25, n_semestres * 1.5].min / 100
                                 elsif regime_cadre?
                                   1.0 * [20, n_semestres * 1.0].min / 100
                                 end
      end
      (1.0 * (calcul_points + points_gratuits) * coefficient_minoration)
    end
  end

  # @param [LiquidationRetraite] liquidation_retraite
  def calcul_points_majoration(liquidation_retraite)
    nombre_enfants_mineurs = liquidation_retraite.enfants.valide.mineurs.
        where("date_naissance <= ?", liquidation_retraite.date_soumission || DateTime.now).count
    taux_majoration = [15, 5 * nombre_enfants_mineurs].min / 100.0
    (1.0 * calcul_points_base(liquidation_retraite) * taux_majoration)
  end

  private

  def points_gratuits
    return points_gratuits_regime_cadre if regime_cadre?
    points_gratuits_regime_general if regime_general?
  end

  def points_gratuits_regime_cadre
    0.0
  end

  def points_gratuits_regime_general
    0.0
  end
=end
end
