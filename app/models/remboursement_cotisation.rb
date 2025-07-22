class RemboursementCotisation < ApplicationRecord
  ETAT = {
    en_attente: 0,
    soumis: 1,
    valide: 2,
    rejete: 3
  }.freeze

  enum etat: ETAT
  belongs_to :user, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id,optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affectation_allocataire, optional: true
  belongs_to :carriere, class_name: 'Carriere', foreign_key: :carriere_id, optional: true
  belongs_to :type_regime, :class_name => 'Admin::TypeRegime', foreign_key: :type_regime_id
  scope :traite, -> { where(etat: [:valide, :rejete]) }
  scope :soumis, -> { where(etat: [:soumis]) }
  scope :regime_general, -> { joins(:type_regime).where(admin_type_regimes: {code: Admin::TypeRegime::GENERAL}) }
  scope :regime_cadre, -> { joins(:type_regime).where(admin_type_regimes: {code: Admin::TypeRegime::CADRE}) }

  def rembouresement_valide!(est_valide = :valide)
    update(etat: est_valide)
  end

  def remboursement_rejete!(est_rejete = :rejete)
    update(etat: est_rejete)
  end

  def remboursement_annulee!(est_annulee = :en_attente)
    update(etat: est_annulee)
  end

  def remboursement_activer!(est_activer = :en_attente)
    update(etat: est_activer)
  end

  def regime_cadre?
    self.type_regime == Admin::TypeRegime::cadre
  end

  def regime_general?
    self.type_regime == Admin::TypeRegime::general
  end

  # @return [Admin::Bareme]
  def bareme1
    unless type_regime.nil?
      type_regime.admin_baremes.find_by("date_debut_validite <= ? AND date_fin_validite >= ?", date_entree, date_entree)
    end
  end


  def taux_contractuel
    if bareme1.nil?
      taux = 0
    else
      taux =  bareme1.taux_contractuel
    end
    
  end
  
  def calcul_cotisation_contractuel
    (taux_contractuel/100)*salaire
  end

end