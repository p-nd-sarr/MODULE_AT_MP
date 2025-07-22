class Admin::TypeDossierJuridique < ApplicationRecord

  has_many :dossier_juridiques
  validates :title,
            presence: true
end
