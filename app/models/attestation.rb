class Attestation < ApplicationRecord
  belongs_to :user

  ETAT = {
      creation: 1,
      soumis: 2,
      valide: 3
  }.freeze

  enum etat: ETAT
end
