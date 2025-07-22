class Admin::ActivitePrincipale < ApplicationRecord

  belongs_to :admin_secteur_activite, :class_name => 'Admin::SecteurActivite'
  validates :admin_secteur_activite_id, :description,
            presence: true
end