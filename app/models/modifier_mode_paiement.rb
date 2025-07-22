class ModifierModePaiement < ApplicationRecord
  include WorkflowActiverecord
  include Documentable
  include HasBankAccount

  TYPE_DOCUMENT_OBLIGATOIRE = {

  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      cni: 1,
      rib: 10,
      attestation_non_engagement: 18,
      certificat_medical: 19,
      formulaire_demande: 90,
    }
  ).freeze

  InvalidTransitionError = Class.new(StandardError)

  workflow_column :workflow_state

  workflow do
    state :creation, :meta => { label: 'Création' } do
      event :est_soumis, transition_to: :soumis
    end

    state :soumis, :meta => { label: 'Soumis' } do
      event :est_modif_soumis, transition_to: :modif_soumis
      event :retour_creation, transition_to: :creation
    end

    state :modif_soumis, :meta => { label: 'Modif_soumis' } do
      event :est_dossier_valide, transition_to: :dossier_valide
      event :est_dossier_rejete, transition_to: :dossier_rejete
      event :retour_soumis, transition_to: :soumis
    end

    state :dossier_valide, :meta => { label: 'Dossier_validé' }
    state :dossier_rejete, :meta => { label: 'Dossier_rejeté' }

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

  MOTIF_VIREMENT = {
    mise_en_place_virement: 1, #Mise en place d’un virement
    changement_de_banque: 2, #Changement de banque 
    changement_de_compte: 3, #  Changement de numéro de compte dans la même agence
  }.freeze

  enum etat: ETAT
  enum mode_paiement: MODE_PAIEMENT
  enum motif_virement: MOTIF_VIREMENT
  enum attachment: TYPE_DOCUMENT
  belongs_to :allocataire,
             foreign_key: :numero_allocataire,
             primary_key: :numero_allocataire
  has_many :documents, as: :documentable, dependent: :destroy
  belongs_to :admin_agence, :class_name => 'Admin::Agence', foreign_key: :admin_agence_id, optional: true
  belongs_to :agence_creation, :class_name => 'Admin::Agence', foreign_key: :agence_creation_id, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affectation_allocataire, optional: true
  has_one_attached :attachment
  delegate :filename, to: :attachment, allow_nil: true
  belongs_to :affecte_par, class_name: 'User', foreign_key: :affecte_par_id, optional: true
 scope :en_agence, ->(id) { where("ajoute_par_id = ?", id) }
  scope :en_attente_affectation, -> { where(workflow_state: [:soumis]).where(affectation_allocataire: nil) }

  validates :numero_allocataire, :prenom, :nom, :mode_paiement, presence: true
  scope :en_attente, -> { where(workflow_state: [:soumis, :traitement_en_cours]) }
  scope :en_attente_soumission, -> { where(workflow_state: [:creation]) }
  scope :en_attente_validation_chef_agence, -> { where(workflow_state: [:soumis])}
  scope :en_attente_verification, -> { where(workflow_state: [:soumis]) }
  scope :en_attente_validation, -> { where(workflow_state: [:modif_soumis]) }
  scope :visible_for_admins, -> { where(workflow_state: [:soumis, :traitement_en_cours, :valide, :rejete]) }
  scope :periode, ->(date_debut, date_fin) { where("date_validation > ? AND date_validation < ?", date_debut, date_fin) }
  scope :affectes_par, ->(id) { where("affecte_par_id = ?", id) }

  scope :created_at_infeq, ->(date) { where('created_at <= ?', date.to_date.end_of_day) }

  validate :validate_numero_affiliation, on: :create
  before_create :set_numero_dossier!, :set_agence_creation!
  before_create :save_old_mode_paiement!

  validates :telephone,
            presence: true,
            if: -> { orange_money? or wave? },
            on: :create

  # validates :telephone,
  #           presence: true,
  #           if: -> { wave? },
  #           on: :create

  def can_valide_agence(current_user)
    soumis? && 
    current_user.chef_agence? 
  end

  def self.ransackable_scopes(auth_object = nil)
    %i(created_at_infeq)
  end

  def etat_civil_demandeur_valide!(est_valide = true)
    update!(etat_civil_demandeur_valide: est_valide)
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
    etat_civil_demandeur_valide and documents_valide
  end

  def nom_complet
    "#{prenom} #{nom}"
  end

  def meme_agence?(current_user)
    return true if current_user.admin?
    ajoute_par.agence && ajoute_par.agence == current_user.agence
  end

  private

  def set_numero_dossier!
    annee = Date.today.year
    self.numero_dossier = "MP/#{numero_allocataire}/#{id}/#{annee}"
  end

    def set_agence_creation!
    self.agence_creation = ajoute_par.try(:admin_agence)
  end

  

  def validate_numero_affiliation
    return if numero_allocataire.nil?
    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Allocataire.where(numero_allocataire: numero_allocataire).exists?
  end

  def save_old_mode_paiement!
    self.old_mode_paiement = allocataire.mode_paiement
    if virement?
      self.old_compte_bancaire_nom_banque = allocataire.compte_bancaire_nom_banque
      self.old_compte_bancaire_code_banque = allocataire.compte_bancaire_code_banque
      self.old_compte_bancaire_code_guichet = allocataire.compte_bancaire_code_guichet
      self.old_compte_bancaire_numero_compte = allocataire.compte_bancaire_numero_compte
    end
  end

end
