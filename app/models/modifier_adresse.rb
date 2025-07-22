class ModifierAdresse < ApplicationRecord

  include Documentable
    include WorkflowActiverecord

    TYPE_DOCUMENT_OBLIGATOIRE = {
  
    }.freeze
  
    TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
        {
          certificat_de_domile: 69,
          certificat_de_residence: 70
        }
    ).freeze

    InvalidTransitionError = Class.new(StandardError)

  workflow_column :workflow_state

  workflow do
    state :creation do
      event :est_soumis, transition_to: :soumis
    end

    state :soumis do
      event :est_modif_soumis, transition_to: :modif_soumis
      event :retour_creation, transition_to: :creation
    end
    

    state :modif_soumis do
      event :est_dossier_valide, transition_to: :dossier_valide
      event :est_dossier_rejete, transition_to: :dossier_rejete
      event :retour_soumis, transition_to: :soumis
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
      rejete: 5
     
  }.freeze

  enum etat: ETAT
  belongs_to :allocataire,
  foreign_key: :numero_allocataire,
  primary_key: :numero_allocataire
  has_many :documents, as: :documentable, dependent: :destroy
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affectation_allocataire, optional: true
  has_one_attached  :attachment
  delegate :filename, to: :attachment, allow_nil: true
  scope :en_attente_affectation, -> { where(workflow_state: [:soumis]).where(affectation_allocataire: nil) }
  belongs_to :participant, :class_name => 'Psrm::Participant',
  foreign_key: :numero_affiliation,
  primary_key: :matric,
  optional: true
  validates :numero_allocataire, :prenom, :nom, presence: true
  scope :en_attente, -> { where(workflow_state: [:soumis, :traitement_en_cours]) }
  scope :en_attente_soumission, -> { where(workflow_state: [:creation]) }
  scope :en_attente_affectation, -> { where(workflow_state: [:soumis]).where(affecter_allocataire: nil) }
  scope :en_attente_verification, -> { where(workflow_state: [:soumis]) }
  scope :en_attente_validation, -> { where(workflow_state: [:modif_soumis]) }
  scope :visible_for_admins, -> { where(workflow_state: [:soumis, :traitement_en_cours, :valide, :rejete]) }
  scope :periode, ->(date_debut, date_fin) { where("date_validation > ? AND date_validation < ?", date_debut, date_fin) }
  validate :validate_numero_affiliation, on: :create
  before_create :set_numero_dossier!
  before_create :saveOldAdresse!

  def etat_civil_demandeur_valide!(est_valide = true)
    update(etat_civil_demandeur_valide: est_valide)
  end

  def modification_valide!(est_valide = true)
    update(modification_valide: est_valide)
  end

  def modification_soumis!(est_valide = true)
    update(modification_soumis: est_valide)
  end

  def documents_valide!(est_valide = true)
      update(documents_valide: est_valide)
  end



  def pret_pour_soumission?
    etat_civil_demandeur_valide  and documents_valide 
  end

  private
  def set_numero_dossier!
    annee = Date.today.year
    self.numero_dossier = "ADR/#{numero_allocataire}/#{id}/#{annee}"
  end

  def validate_numero_affiliation
    return if numero_allocataire.nil?
    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Allocataire.where(numero_allocataire: numero_allocataire).exists?
  end

  def saveOldAdresse!
    self.old_adresse_rue= allocataire.adresse_rue
    self.old_adresse_ville = allocataire.adresse_ville
  end

end
