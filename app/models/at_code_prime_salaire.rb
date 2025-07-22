class AtCodePrimeSalaire < ApplicationRecord
  belongs_to :arret_travail, optional: true
  belongs_to :at_rechute, optional: true
  validates :code, :designation, presence: true
  validates :code, uniqueness: {message: "Vous avez déjà un composant avec ce code."}, allow_nil: false
end
