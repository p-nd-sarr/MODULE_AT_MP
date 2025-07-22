class ExtinctionAllocataire < ApplicationRecord
  include WorkflowActiverecord
  include Documentable

  TYPE_DOCUMENT_OBLIGATOIRE = {
  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      certificat_deces: 11,
    }
  ).freeze

  InvalidTransitionError = Class.new(StandardError)

  workflow_column :workflow_state

  workflow do
    state :creation do
      event :est_soumis, transition_to: :soumis
    end

    state :soumis do
      event :est_verifie, transition_to: :verifie
      event :retour_creation, transition_to: :creation
    end

    state :verifie do
      event :est_dossier_valide, transition_to: :dossier_valide
      event :est_dossier_rejete, transition_to: :dossier_rejete
    end

    state :dossier_valide
    state :dossier_rejete

    on_transition do |from, to, triggering_event, *event_args|
      puts "#{from} -> #{to}"
    end

    #  use after transition for historisation
    after_transition do
      puts "=> traite par : #{self.traite_par}"
    end

    on_error do |error, from, to, event, *args|
      puts "Exception(#error.class) on #{from} -> #{to}"
    end
  end

  ETAT = {
    creation: 1,
    soumis: 2,
    affecte: 3,
    valide: 4,
    rejete: 5,
  }.freeze

  enum etat: ETAT

  belongs_to :allocataire,
             foreign_key: :numero_allocataire,
             primary_key: :numero_allocataire
  belongs_to :user, optional: true
  has_many :documents, as: :documentable, dependent: :destroy
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :valide_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  belongs_to :verifie_par, class_name: 'User', foreign_key: :verifie_par_id, optional: true
  #belongs_to :affectation_allocataire, class_name: 'User', foreign_key: :affectation_allocataire, optional: true
  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affectation_allocataire, optional: true
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  has_one_attached :attachment
  delegate :filename, to: :attachment, allow_nil: true
  validates :attachment, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, attached: true

  scope :en_attente_soumission, -> { where(workflow_state: :creation) }
  scope :en_attente_affectation, -> { where(workflow_state: :soumis).where(affectation_allocataire_date: nil) }
  scope :en_attente_verification, -> { where(workflow_state: :soumis) }
  scope :en_attente_validation, -> { where(workflow_state: :verifie) }
  scope :dossiers_valides, -> { where(workflow_state: :valide) }
  scope :dossiers_rejetes, -> { where(workflow_state: :rejete) }

  def affecter?
    !affectation_allocataire.nil? and soumis?
  end

  def get_allocataire
    Allocataire.find_by('numero_allocataire = ? or ipres_ancien_matric = ?', numero_allocataire, numero_allocataire)
  end
end
