class MissingDeclaration < ApplicationRecord
  ETAT = {
      creation: 1,
      soumis: 2,
      manquante: 3,
      valide: 4
  }.freeze

  enum etat: ETAT

  belongs_to :employeur, class_name: 'Psrm::Employeur',
             foreign_key: :numero_ipres,
             primary_key: :fhnum, optional: true
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true

  has_many :missing_ligne_declarations

  has_one_attached :document

  scope :cadre, -> { where(regime: 2) }
  scope :general, -> { where(regime: 1) }
end
