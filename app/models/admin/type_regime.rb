class Admin::TypeRegime < ApplicationRecord
  GENERAL = 'GENERAL'
  CADRE = 'CADRE'
  EMPLOYE_DE_MAISON = 'EMPLOYE_DE_MAISON'

  validates :code, :description,
            presence: true
  validates :code, uniqueness: true

  has_many :admin_baremes, :class_name => 'Admin::Bareme', foreign_key: :admin_type_regime_id
  has_many :admin_bareme_pensions, :class_name => 'Admin::BaremePension', foreign_key: :admin_type_regime_id

  def self.general
    find_by(code: Admin::TypeRegime::GENERAL)
  end

  def self.cadre
    find_by(code: Admin::TypeRegime::CADRE)
  end
end