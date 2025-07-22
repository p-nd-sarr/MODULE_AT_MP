class Admin::Departement < ApplicationRecord
  belongs_to :admin_region, :class_name => 'Admin::Region'
  has_many :admin_villes, :class_name => 'Admin::Ville'

  validates :designation, :code,
            presence: true
end
