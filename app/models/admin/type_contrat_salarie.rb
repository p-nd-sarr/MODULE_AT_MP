class Admin::TypeContratSalarie < ApplicationRecord
  validates :code, :description,
            presence: true
  validates :code, uniqueness: true
end
