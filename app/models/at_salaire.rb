class AtSalaire < ApplicationRecord
  belongs_to :arret_travail, optional: true
  has_many :at_code_prime_salaires
  
  MOIS = {
    JANVIER: 1,
    FEVRIER: 2,
    MARS: 3,
    AVRIL: 4,
    MAI: 5,
    JUIN: 6,
    JUILLET:7,
    AOUT:8,
    SEPTEMBRE: 9,
    OCTOBRE: 10,
    NOVEMBRE: 11,
    DECEMBRE: 12,
  }.freeze


  enum mois: MOIS


end
