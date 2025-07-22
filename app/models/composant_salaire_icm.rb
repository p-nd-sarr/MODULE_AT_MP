class ComposantSalaireIcm < ApplicationRecord
  #belongs_to :at_code_prime_salaire
  #belongs_to :composant_salaire
  belongs_to :composant_salaire, class_name: 'Admin::ComposantSalaire', foreign_key: :composant_salaire_id
  belongs_to :dossier_maternite

  #validates :montant, :at_code_prime_salaire_id, presence: true
  validates :montant, :composant_salaire_id, presence: true
  validates :composant_salaire_id, uniqueness: {message: "Vous avez déjà ajouté ce composant.", scope: :dossier_maternite}

  #validate :validate_montant

  after_save :update_montant_icm


  def update_montant_icm
    dossier_maternite.montant_indemnite = dossier_maternite.revenu_brut
    dossier_maternite.save
  end


  private

  def validate_montant
    unless montant.nil?
      errors.add(:montant, "Le montant du composant doit etre inférieur ou égal à 5 000 000 .") if montant > 5_000_000
    end
  end
end
