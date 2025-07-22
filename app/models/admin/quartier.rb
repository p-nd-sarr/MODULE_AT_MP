class Admin::Quartier < ApplicationRecord
  belongs_to :admin_commune, :class_name => 'Admin::Commune'

  validates :designation, :code,
            presence: true
end
