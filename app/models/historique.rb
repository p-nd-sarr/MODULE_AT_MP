class Historique < ApplicationRecord
  ETAT = Allocataire::ETAT

  enum etat: ETAT

  belongs_to :user, class_name: 'User', foreign_key: :user_id, optional: true
  belongs_to :allocataire, class_name: 'Allocataire', foreign_key: :allocataire_id, optional: true
end
