class Admin::AssociationAllocataire < ApplicationRecord
  has_many :allocataires, foreign_key: :admin_association_allocataire_id
end
