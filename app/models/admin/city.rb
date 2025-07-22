class Admin::City < ApplicationRecord
  validates :description, :admin_country_id,
            presence: true
end
