class DossierPrestationHistoric < ApplicationRecord

  belongs_to :dossier_prestation
  belongs_to :admin_agence, :class_name => 'Admin::Agence'
  belongs_to :psrm_employeur, :class_name => 'Psrm::Employeur', primary_key: :fhnum, :foreign_key => :employeur_matric, optional: true
end
