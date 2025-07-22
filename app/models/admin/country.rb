class Admin::Country < ApplicationRecord
  has_many :prestation_exterieures
  has_many :admin_regions, :class_name => 'Admin::Region', foreign_key: :admin_country_id

  validates :code, :description,
            presence: true
  validates :code, uniqueness: true
end
