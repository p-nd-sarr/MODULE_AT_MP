class Admin::SecteurActivite < ApplicationRecord

  validates :description, presence: true

  has_many :admin_activite_principales, :class_name => 'Admin::ActivitePrincipale', foreign_key: :admin_secteur_activite_id

end
