class Paiement < ApplicationRecord
  TYPE_ENCAISSEMENT = {
      om: 1,
      wari: 2,
      espece: 3,
      cheque: 4,
      virement: 5,
      prelevement: 6
  }.freeze

  enum mode_paiement: TYPE_ENCAISSEMENT

  belongs_to :user
end