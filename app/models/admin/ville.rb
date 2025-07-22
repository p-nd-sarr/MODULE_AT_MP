class Admin::Ville < ApplicationRecord
  belongs_to :admin_departement, :class_name => 'Admin::Departement'
  has_many :admin_communes, :class_name => 'Admin::Commune'

  validates :code, :designation,
            presence: true
end
