class Salarie < ApplicationRecord
  ETAT = {
    deces: 1
  }.freeze

  enum etat: ETAT

  SEXE = {
    homme: 0,
    femme: 1
  }.freeze

  enum sexe: SEXE
end
