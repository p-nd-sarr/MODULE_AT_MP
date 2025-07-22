class Admin::ComptaNaturePrestation < ApplicationRecord
  ENTITE = {
      ipres: 1,
      css: 2
  }.freeze

  BRANCHE = {
      ve: 1,
      pf: 2,
      at: 3
  }.freeze

  enum entite: ENTITE

  enum branche: BRANCHE

  validates :code, uniqueness: true
  validates :code, :libelle, :entite, :branche,
            presence: true
end
