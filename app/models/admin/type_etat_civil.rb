class Admin::TypeEtatCivil < ApplicationRecord
  validates :code, :description,
            presence: true
  validates :code, uniqueness: true
end
