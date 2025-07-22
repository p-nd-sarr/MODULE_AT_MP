module UserActsAsSalarie
  extend ActiveSupport::Concern

  included do
    has_many :liquidation_retraites, foreign_key: :numero_affiliation, primary_key: :numero_salarie
    has_many :liquidation_retraite_frances, foreign_key: :numero_affiliation, primary_key: :numero_salarie
    has_many :dossier_prestations, foreign_key: :num_affiliation, primary_key: :numero_salarie
    has_many :UpdateGrappeFamiliales, foreign_key: :num_affiliation, primary_key: :numero_salarie
    has_many :dossier_maternites, foreign_key: :num_affiliation, primary_key: :numero_salarie
    has_many :cfs_reversion_veuves, foreign_key: :num_affiliation, primary_key: :numero_salarie
    belongs_to :participant, :class_name => 'Psrm::Participant',
               foreign_key: :numero_salarie,
               primary_key: :matric,
               optional: true

    validate :validate_numero_salarie, if: -> { self.salarie? }
    validates :sexe, presence: true, if: -> { self.salarie? or self.allocataire? }
    validates :date_naissance, :lieu_naissance, :nin,
              presence: true, if: -> { self.salarie? }
  end

  def nombre_enfants_mineurs
    salarie_enfants.where("date_naissance >= ?", 21.years.ago).count
  end

  def total_points_carriere
    Psrm::Carriere.where(matric: numero_salaire).map(&:calcul_points).sum
  end

  def annee_debut_carriere
    Psrm::Carriere.where(matric: numero_salaire).map(&:exercice).min
  end

  def annee_fin_carriere
    Psrm::Carriere.where(matric: numero_salaire).map(&:exercice).max
  end

  def can_add_liquidation_retraite?
    liquidation_retraites.soumis.empty? and liquidation_retraites.traitement_en_cours.empty?
  end

  def can_add_liquidation_retraite_france?
    liquidation_retraite_frances.soumis.empty? and liquidation_retraite_frances.traitement_en_cours.empty?
  end

  def can_add_dossier_prestation?
    # dossier_prestation.nil?
    true
  end

  def can_add_dossier_maternite?
    true
  end

  private

  def validate_numero_salarie
    if numero_salarie.nil?
      errors.add(:numero_salarie, 'est obligatoire')
    end
    if Psrm::Participant.exists?(ipres_ancien_matric: numero_salarie)
      self.numero_salarie = Psrm::Participant.find_by(ipres_ancien_matric: numero_salarie).matric
    elsif Psrm::Participant.exists?(css_ancien_matric: numero_salarie)
      self.numero_salarie = Psrm::Participant.find_by(css_ancien_matric: numero_salarie).matric
    end
    errors.add(:numero_salarie, 'Ce numéro de salarié est introuvable') unless Psrm::Participant.exists?(matric: numero_salarie)
  end
end