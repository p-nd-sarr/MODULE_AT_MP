class Psrm::Carriere < ApplicationRecord
  self.table_name = 'psrm_carrieres'

  belongs_to :employeur, foreign_key: :fhnum, primary_key: :fhnum, optional: true
  belongs_to :participant, foreign_key: :matric, primary_key: :matric, optional: true

  scope :regime_general, -> { where(regime: '1') }
  scope :regime_cadre, -> { where(regime: '2') }

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
  # def type_regime
  #   return Admin::TypeRegime::general if self.REGIME == 'RG'
  #   return Admin::TypeRegime::cadre if self.REGIME == 'RCC'
  #   nil
  # end

  # def regime_cadre?
  #   regime == 'RCC'
  # end
  #
  # def regime_general?
  #   regime == 'RG'
  # end

  # @return [Admin::Bareme]
  # def bareme_rg
  #   Admin::TypeRegime::general.admin_baremes.find_by("date_debut_validite <= ? AND date_fin_validite >= ?", date_debut, date_debut)
  # end

  # @return [Admin::Bareme]
  # def bareme_rcc
  #   Admin::TypeRegime::cadre.admin_baremes.find_by("date_debut_validite <= ? AND date_fin_validite >= ?", date_debut, date_debut)
  # end

  def salaire_rg
    (total_sal_ipres_rg_1 || 0) + (total_sal_ipres_rg_2 || 0) + (total_sal_ipres_rg_3 || 0)
  end

  def salaire_rcc
    (total_sal_ipres_rcc_1 || 0) + (total_sal_ipres_rcc_2 || 0) + (total_sal_ipres_rcc_3 || 0)
  end

  def calcul_points_rg
    points_rg
    # return 0 if salaire_rg.zero? or bareme_rg.nil?
    # (1.0 * [salaire_rg, bareme_rg.plafond_salaire].min * bareme_rg.coefficient).round
  end

  def calcul_points_rcc
    points_rc
    # return 0 if salaire_rcc.zero? or bareme_rcc.nil?
    # (1.0 * [salaire_rcc, bareme_rcc.plafond_salaire].min * bareme_rcc.coefficient).round
  end

  def calcul_points
    calcul_points_rg + calcul_points_rcc
  end

  def load_to_prestation
    unless salaire_rg.zero?
      unless ::Carriere.exists?(numero_affiliation: matric,
                                type_regime: Admin::TypeRegime::general,
                                date_entree: date_debut,
                                date_sortie: date_fin)
        ::Carriere.create(
          numero_affiliation: matric,
          ref_employeur: fhnum,
          raison_sociale: fhrsoc,
          salaire1: salaire_rg,
          salaire2: 0,
          salaire: salaire_rg,
          points: calcul_points_rg,
          exercice: exercice,
          date_entree: date_debut,
          date_sortie: date_fin,
          motif_rejet: self.motif_sortie,
          type_regime: Admin::TypeRegime::general,
          etat: :en_attente,
          est_repris: true,
          edi_id: self.edi_id
        )
      end
    end

    unless salaire_rcc.zero?
      unless ::Carriere.exists?(numero_affiliation: matric,
                                type_regime: Admin::TypeRegime::cadre,
                                date_entree: date_debut,
                                date_sortie: date_fin)
        ::Carriere.create(
          numero_affiliation: matric,
          ref_employeur: fhnum,
          raison_sociale: fhrsoc,
          salaire1: salaire_rcc,
          salaire2: 0,
          salaire: salaire_rcc,
          points: calcul_points_rcc,
          exercice: exercice,
          date_entree: date_debut,
          date_sortie: date_fin,
          motif_rejet: self.motif_sortie,
          type_regime: Admin::TypeRegime::cadre,
          etat: :en_attente,
          est_repris: true,
          edi_id: self.edi_id
        )
      end
    end
  end
end
