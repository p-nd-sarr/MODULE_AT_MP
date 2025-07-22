class Admin::Agence < ApplicationRecord

  TYPE_AGENCE = {
      ipres: 81,
      css: 82
  }.freeze

  enum type_agence: TYPE_AGENCE

  validates :code, :type_agence, :description_ebs, :code_prest, :description_prest, presence: true
end
