class DossierPrestationGed < ApplicationRecord
  NATIONALITE = {
    senegalais: 1,
    etranger: 2
  }.freeze
  enum nationalite: NATIONALITE

  SEXE = {
    masculin: 1,
    feminin: 2
  }.freeze  
  
  STATUS_GED = {
    en_creation: "en_creation",
    en_cours: "en_cours",
    valide: "valide"
  }.freeze

  enum sexe_salarie: SEXE
  enum status_ged: STATUS_GED

  belongs_to :user, optional: true
  belongs_to :admin_agence, optional: true, :class_name => 'Admin::Agence', foreign_key: :admin_agence_id

  validates :num_affiliation, :prenom, :nom, :date_naissance, :lieu_naissance, presence: true

  def peut_traiter?(current_user)
    en_creation? && current_user.gestionnaire_compte_allocataire?
  end
end