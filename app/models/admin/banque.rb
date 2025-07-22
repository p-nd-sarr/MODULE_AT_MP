class Admin::Banque < ApplicationRecord
  validates :code, :nom, :bank_id, :code_swift,
            presence: true, uniqueness: true

  has_many :admin_banque_agences, :class_name => 'Admin::BanqueAgence', foreign_key: :admin_banque_id
end
