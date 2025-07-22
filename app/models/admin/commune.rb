class Admin::Commune < ApplicationRecord
  belongs_to :admin_ville, :class_name => 'Admin::Ville'
  has_many :admin_quartiers, :class_name => 'Admin::Quartier'

  validates :code, :designation,
            presence: true
end
