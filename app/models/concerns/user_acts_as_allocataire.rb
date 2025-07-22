module UserActsAsAllocataire
  extend ActiveSupport::Concern

  included do
    validate :validate_numero_allocataire, if: -> { allocataire? }

    #validates :sexe, presence: true, if: -> { salarie? or allocataire? }

    belongs_to :allocataire, optional: true, foreign_key: :numero_salarie, primary_key: :numero_allocataire
    belongs_to :participant, :class_name => 'Psrm::Participant',
    foreign_key: :numero_salarie,
    primary_key: :matric,
    optional: true
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

  private

  def validate_numero_allocataire
    if numero_salarie.nil?
      errors.add(:numero_salarie, 'est obligatoire')
      return
    end
    errors.add(:numero_salarie, 'Ce numéro allocataire est introuvable') unless Allocataire.where(numero_allocataire: numero_salarie).exists?
  end
end