class AtVenteCarnet < ApplicationRecord

  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  belongs_to :admin_agence, :class_name => 'Admin::Agence', foreign_key: :admin_agence_id
  belongs_to :psrm_employeur, :class_name => 'Psrm::Employeur', primary_key: :fhnum, foreign_key: :num_employeur, optional: true

  validates :date_delivrance, :num_recu, :num_employeur, :numero_carnet, :num_carnets, presence: true
  validate :check_numero_carnet
  validate :check_receipt

  scope :en_agence, ->(id) { where(admin_agence_id: id) }

  def check_numero_carnet
    all_numero_carbet = self.psrm_employeur.at_vente_carnets.pluck(:numero_carnet)
    all_numero_carbet.each do |nu|
      if (numero_carnet & nu).any?
        errors.add(:base, "Numéro de carnet déjà ajouté pour ce salarié!")
      end
    end
  end

  def check_receipt
    all_receipt = self.psrm_employeur.at_vente_carnets.pluck(:num_recu)
    if all_receipt.include?(self.num_recu)
      errors.add(:base, "Reçu déjà ajouté pour ce salarié!")
    end
  end
end
