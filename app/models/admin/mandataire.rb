class Admin::Mandataire < ApplicationRecord

  SEXE = {
      homme: 1,
      femme: 2
  }

  enum sexe: SEXE

  belongs_to :psrm_employeur, :class_name => 'Psrm::Employeur', foreign_key: :numero_employeur, primary_key: :fhnum

  validates :prenom, :nom, :nin, :numero_employeur, :telephone, :sexe, :email,
            presence: true

  validates_length_of :telephone, minimum: 9, maximum: 9
  validates :nin, uniqueness: true, length: {in: 13..14}
  validate :nin_start_number


  def nin_start_number
    if homme? and self.nin[0] != '1'
      errors.add(:nin, "le nin doit commencer par 1")
    end

    if femme? and self.nin[0] != '2'
      errors.add(:nin, "le nin doit commencer par 2")
    end
  end



end
