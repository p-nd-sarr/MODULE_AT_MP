class Admin::MontantMensualiteVolet < ApplicationRecord
  NUM_VOLET = {
      volet1: 1,
      volet2: 2,
      volet3: 3,
      volet4: 4,
      volet5: 5,
      volet6: 6,
      volet7: 7,
      volet8: 8
  }.freeze

  enum num_volet: NUM_VOLET
  validates :num_volet, :montant, presence: true
end
