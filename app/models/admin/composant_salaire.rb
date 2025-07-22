class Admin::ComposantSalaire < ApplicationRecord
  validates :code, :designation, presence: true
  validates :code, uniqueness: {message: "Vous avez déjà un composant avec ce code."}, allow_nil: false
end
