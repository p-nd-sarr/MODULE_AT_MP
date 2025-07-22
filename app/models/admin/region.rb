class Admin::Region < ApplicationRecord
  validates :designation, :code, :admin_country_id,
            presence: true

  belongs_to :admin_country, :class_name => 'Admin::Country'
  has_many :admin_departements, :class_name => 'Admin::Departement'
end
