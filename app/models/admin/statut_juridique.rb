class Admin::StatutJuridique < ApplicationRecord
  validates :code, :description,
            presence: true
  validates :code, uniqueness: true
end