module UserActsAsEmployer
  extend ActiveSupport::Concern

  included do
    # validate :validate_numero_immatriculation, if: -> { employeur? }
    validate :validate_ninea, if: -> { employeur? }
  end

  def full_name_employer
    "Raison sociale : #{nom} - NINEA : #{ninea}"
  end

  private

  def validate_numero_immatriculation

    if employeur?
      errors.add(:num_immatriculation, 'Ce numéro d immatriculation est introuvable') unless Psrm::Employeur.where(fhnum: num_immatriculation).exists?
    end
  end

  def validate_ninea
    if ninea.nil? or ninea.length < 9
      logger.info "validation ninea"
      errors.add(:ninea, ' Ce numéro est invalide')
    end
  end
end