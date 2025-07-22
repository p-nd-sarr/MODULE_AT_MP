class TraitementCollectif < ApplicationRecord
  enum allocation_etat: AllocationFamiliale.etats
end