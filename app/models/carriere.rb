class Carriere < ApplicationRecord
  ETAT = {
      en_attente: 0,
      valide: 1,
      rejete: 2,
      a_rembourse: 3
  }.freeze

  enum etat: ETAT

  belongs_to :type_regime, :class_name => 'Admin::TypeRegime', foreign_key: :type_regime_id
  belongs_to :employeur, class_name: 'Psrm::Employeur', foreign_key: :ref_employeur, primary_key: :fhnum, optional: true
  belongs_to :revision_pension, :class_name => 'RevisionPension', foreign_key: :revision_pension_id, optional: true
  belongs_to :liquidation_retraite, :class_name => 'LiquidationRetraite', foreign_key: :liquidation_retraite_id, optional: true
  belongs_to :liquidation_retraite_france, :class_name => 'LiquidationRetraiteFrance', foreign_key: :liquidation_retraite_france_id, optional: true
  belongs_to :reversion_veuve_salarie, :class_name => 'ReversionVeuveSalarie', foreign_key: :reversion_veuve_salarie_id, optional: true
  belongs_to :base_reversion_salary, :class_name => 'BaseReversionSalary', foreign_key: :base_reversion_salary_id, optional: true
  has_one :remboursement_cotisation,:class_name => 'RemboursementCotisation'
  belongs_to :allocataire, :class_name => 'Allocataire', foreign_key: :numero_allocataire, optional: true
  scope :regime_general, -> { joins(:type_regime).where(admin_type_regimes: {code: Admin::TypeRegime::GENERAL}) }
  scope :regime_cadre, -> { joins(:type_regime).where(admin_type_regimes: {code: Admin::TypeRegime::CADRE}) }
  scope :traite, -> { where(etat: [:valide, :rejete]) }
  scope :carrieres_en_attente, -> { where(etat: [:en_attente]) }
  scope :carrieres_soumis, -> { where(etat: [:a_rembourse]) }
  scope :en_revision, ->(id) { where(revision_pension_id: id) }

  validates :salaire1, :salaire2, presence: true

  validate :validate_salaire!

  before_create do
    self.points = calcul_points if self.points.nil? or self.points.zero?
  end

  def regime_cadre?
    type_regime == Admin::TypeRegime::cadre
  end

  def regime_general?
    type_regime == Admin::TypeRegime::general
  end

  # @return [Admin::Bareme]
  def bareme1
    return nil if type_regime.nil?
    type_regime.admin_baremes.find_by("date_debut_validite <= ? AND date_fin_validite >= ?", date_entree, date_entree)
  end

  # @return [Admin::Bareme]
  def bareme2
    return nil if type_regime.nil?
    type_regime.admin_baremes.find_by("date_debut_validite <= ? AND date_fin_validite >= ?", date_sortie, date_sortie)
  end

  def calcul_points
    points1 = if bareme1.nil?
                0
              else
                1.0 * [self.salaire1.to_f, bareme1.plafond_salaire].min * bareme1.coefficient
              end

    points2 = if bareme2.nil?
                0
              else
                1.0 * [self.salaire2.to_f, bareme2.plafond_salaire].min * bareme2.coefficient
              end

    (points1 + points2).round
  end

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

  def validate_salaire!
    return if salaire1.nil? and salaire2.nil?

    if salaire1 == 0 and salaire2 == 0
      errors.add(:salaire1, "Le salaire 1 et salaire 2 ne peuvent pas être égale à zero")
    end
  end

  def est_eligible?
    return false if allocataire.nil?
    return false if allocataire.date_naissance.nil?
    60 < years_between_dates(allocataire.date_naissance, carriere.date_sortie)
  end

  def years_between_dates(date_from, date_to)
    ((date_to - date_from) / 365).floor
  end

  def nb_jours_travail
    (date_sortie - date_entree).to_i + 1
  end



  def calculate_trimesters_and_days_for_year
    # Calculer le nombre total de jours entre la date d'entrée et la date de sortie
    total_days = (date_sortie - date_entree).to_i

    # Initialisation des variables
    months_count = 0
    current_date = date_entree

    while current_date < date_sortie
      start_of_month = current_date.beginning_of_month
      end_of_month = current_date.end_of_month

      # Calculer le nombre de jours dans le mois courant
      days_in_month = [(end_of_month - current_date).to_i + 1, (date_sortie - current_date).to_i + 1].min

      # Si le mois a 15 jours ou plus, il compte comme un mois
      if days_in_month >= 15
        months_count += 1
      end

      # Passer au mois suivant
      current_date = end_of_month + 1.day
    end

    # Calculer le nombre de trimestres (3 mois par trimestre)
    trimesters_count = months_count / 3
    remaining_months = months_count % 3

    # Calculer les jours restants non comptabilisés dans un trimestre
    remaining_days = 0
    if remaining_months > 0
      remaining_days = total_days % (remaining_months * 30)
    end

    # Retourner le nombre de trimestres et les jours restants
    { trimesters: trimesters_count, remaining_days: remaining_days }
  end
end