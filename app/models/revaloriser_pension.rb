class RevaloriserPension < ApplicationRecord
  TYPE_OPERATION = {
      a_ajouter: 1,
      a_enlever: 2,
  }.freeze

  enum type: TYPE_OPERATION

  TYPE_REVALORISATION = {
      pret: 1,
      retenu: 2,
      remboursement: 3,
      avis_tiers: 4,
      pension_alimentaire: 5,
  }.freeze

  enum type_revalorisation: TYPE_REVALORISATION

  belongs_to :allocataire,
             foreign_key: :numero_allocataire,
             primary_key: :numero_allocataire
end
