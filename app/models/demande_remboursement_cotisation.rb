class DemandeRemboursementCotisation < ApplicationRecord

  include Documentable

  TYPE_DOCUMENT_OBLIGATOIRE = {
    cni: 1,
  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      passeport: 8,
      carte_consulaire: 9,
      rib: 10,
      certificat_travail: 12,
      autorisation_sortir_pays: 26,
    }
  ).freeze

  include MyTools

  include WorkflowActiverecord

  InvalidTransitionError = Class.new(StandardError)

  workflow_column :workflow_state

  workflow do
    state :creation, meta: { label: 'Création' } do
      event :est_soumis, transition_to: :soumis
    end

    state :soumis, meta: { label: 'Soumis' } do
      event :est_instruit, transition_to: :instruit
      event :retour_creation, transition_to: :creation
    end

    state :instruit, meta: { label: 'Instruit' } do
      event :est_carriere_soumis, transition_to: :carriere_soumis
      event :retour_soumis, transition_to: :soumis
    end

    state :carriere_soumis, meta: { label: 'Carrière soumis' } do
      event :est_carriere_valide, transition_to: :cotisation_valide
      event :retour_instruit, transition_to: :instruit
    end

    state :cotisation_valide, meta: { label: 'Cotisation valide' } do
      event :est_recap_soumis, transition_to: :recap_soumis
      event :retour_carriere, transition_to: :carriere_soumis
    end

    state :recap_soumis, meta: { label: 'Récap soumis' } do
      event :est_recap_valide, transition_to: :liquidation_valide
      event :retour_cotisation, transition_to: :cotisation_valide
    end

    state :liquidation_valide, meta: { label: 'Liquidation valide' } do
      event :est_dossier_valide, transition_to: :dossier_valide
      event :est_dossier_rejete, transition_to: :dossier_rejete
      event :retour_recap, transition_to: :recap_soumis
    end
    state :dossier_valide, meta: { label: 'Dossier valide' } do
      event :est_remboursement_regularise, transition_to: :remboursement_regularise
    end

    state :remboursement_regularise, meta: { label: 'Remboursement régularisé' } do
      event :est_valide_par_inspection, transition_to: :validation_inspection
    end

    state :validation_inspection, meta: { label: 'Validation inspection' }
    state :dossier_rejete, meta: { label: 'Dossier rejeté' }

    on_transition do |from, to, triggering_event, *event_args|
      puts "#{from} -> #{to}"
    end

    #  use after transition for historisation
    after_transition do
      puts " => traite par : #{self.traite_par} "
    end

    on_error do |error, from, to, event, *args|
      puts "Exception(#error.class) on #{from} -> #{to}"
    end
  end

  MOTIF_REMBOURSEMENT = {
    surplus_cotisations_encaissees: 1,
    quitter_definitivement_pays: 2,
    cotisation_au_dela_60_ans: 3,
    cotisation_au_dela_55_ans: 4
  }.freeze

  enum mode_paiement: MODE_PAIEMENT
  enum motif_remboursement: MOTIF_REMBOURSEMENT

  scope :traitement_en_cours, -> { where(workflow_state: [:instruit]) }
  scope :en_attente, -> { where(workflow_state: [:soumis]) }
  scope :en_attente_instruction, -> { where(workflow_state: [:soumis]) }
  scope :en_attente_salaire, -> { where(workflow_state: [:instruit]).where(affectation_salarie: nil) }
  scope :can_affecte, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide]) }
  scope :visible_for_admins, -> { where(workflow_state: [:creation, :soumis, :instruit, :carriere_soumis, :cotisation_valide, :liquidation_valide, :recap_soumis, :dossier_valide, :remboursement_regularise, :validation_inspection]) }
  scope :en_attente_allocation, -> { where(workflow_state: [:instruit, :carriere_soumis, :cotisation_valide]).where(affectation_allocataire: nil) }
  scope :en_attente_cotisation, -> { where(workflow_state: [:instruit]).where(affectation_salarie: nil) }

  scope :non_affecter, -> { where(affectation_allocataire: nil) }
  scope :en_agence, ->(id) { where("ajoute_par_id = ?", id) }
  scope :mes_affectations_allocataire, ->(id) { where("affectation_allocataire = ?", id) }
  scope :mes_affectations_salarie, ->(id) { where("affectation_salarie = ?", id) }
  scope :valider_carriere, -> { where(carriere_valide: :false) }

  scope :remboursement_regularise, -> { where(workflow_state: [:remboursement_regularise]) }

  belongs_to :user, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajouter_par_id
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :instruit_par, class_name: 'User', foreign_key: :instruit_par_id, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affectation_allocataire, optional: true
  belongs_to :affecter_salarie, class_name: 'User', foreign_key: :affectation_salarie, optional: true
  belongs_to :allocataire, optional: true
  has_many :document_liquidation_retraites, dependent: :destroy
  has_many :carrieres_prestation, class_name: 'Carriere', foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :remboursement_cotisations, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :carrieres, class_name: 'Psrm::Carriere', foreign_key: :matric, primary_key: :numero_affiliation
  belongs_to :participant, :class_name => 'Psrm::Participant',
             foreign_key: :numero_affiliation,
             primary_key: :matric,
             optional: true

  has_one_attached :document
  validates :numero_affiliation, :prenom, :nom, :date_naissance, :lieu_naissance,
            presence: true

  validates :compte_bancaire_code_banque, :compte_bancaire_nom_banque, :compte_bancaire_code_guichet, :compte_bancaire_numero_compte,
            presence: true,
            if: :virement?

  after_create :create_carriere!, :delete_remboursement_cotisation!
  validate :validate_numero_affiliation, on: :create
  before_validation :set_numero_affiliation!
  before_create :set_user!, :set_numero_dossier!
  after_save :generate_compta_transaction

  def traite?
    dossier_valide? or dossier_rejete?
  end

  def traitement_en_cours?
    self.current_state.between? :instruit, :carriere_soumis
  end

  def can_affecte_gestionnaire?
    self.current_state >= :instruit
  end

  def pret_pour_validation?
    remboursement_valide and recap_remboursement_valide
  end

  def affecter_allocatation?
    !affecter_allocataire.nil?
  end

  def affecter_cotisation?
    !affecter_salarie.nil?
  end

  def etat_civil_demandeur_valide!(est_valide = true)
    update(etat_civil_demandeur_valide: est_valide)
  end

  def remboursement_valide!(est_valide = true)
    update(remboursement_valide: est_valide)
  end

  def recap_remboursement_valide!(est_valide = true)
    update(recap_remboursement_valide: est_valide)
  end

  def documents_valide!(est_valide = true)
    if est_valide
      return false if documents.where(type_document: [:cni, :passeport, :carte_consulaire]).empty?
      return false if virement? and documents.rib.empty?
      return false if quitter_definitivement_pays? and documents.autorisation_sortir_pays.empty?
      update(documents_valide: est_valide)
    else
      update(documents_valide: est_valide)
    end
    true
  end

  def pret_pour_soumission?
    etat_civil_demandeur_valide and documents_valide
  end

  # calcul remboursement de cotisation

  def calcul_remboursement_regime_general
    get_or_calculate "demande_remboursement_cotisation:#{id}:calcul_remboursements_regime_general" do
      remboursement_cotisations.valide.regime_general.map { |carriere| carriere.salaire * carriere.taux_contractuel/100 }.sum
    end.to_f.floor
  end

  def calcul_remboursement_regime_cadre
    get_or_calculate "demande_remboursement_cotisation:#{id}:calcul_points_regime_cadre" do
      remboursement_cotisations.valide.regime_cadre.map { |carriere| carriere.salaire * carriere.taux_contractuel/100 }.sum
    end.to_f.floor
  end

  def calcul_total_remboursement
    (calcul_remboursement_regime_general + calcul_remboursement_regime_cadre).floor
  end

  def calcul_remboursement_salarial
    (calcul_total_remboursement * 40 / 100).floor
  end

  def calcul_remboursement_patronal
    (calcul_total_remboursement * 60 / 100).floor
  end

  private

  def set_numero_dossier!
    annee = Date.today.year
    self.num_dossier = "RC/#{numero_affiliation}/#{annee}"
  end

  def set_user!
    self.user = User.find_by(numero_salarie: numero_affiliation)
  end

  def set_numero_affiliation!
    self.numero_affiliation = user.numero_salarie unless user.nil?
  end

  def validate_numero_affiliation
    return if numero_affiliation.nil? or numero_affiliation.empty?
    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Psrm::Participant.where(matric: numero_affiliation).exists?
    if DemandeRemboursementCotisation.where(numero_affiliation: numero_affiliation).
      where.not(workflow_state: :dossier_rejete).exists?
      errors.add(:numero_affiliation, "Un dossier avec ce numéro d'affiliation existe déjà")
    end
  end

  def create_carriere!
    # carrieres_prestation.destroy_all
    carrieres.each do |psrm_carriere|
      psrm_carriere.load_to_prestation
    end
  end

  def delete_remboursement_cotisation!
    remboursement_cotisations.destroy_all
  end

  def generate_compta_transaction
    if validation_inspection? and not ComptaTransaction.exists?(dossier: self)
      op = OrdrePaiement.create(dossier: self, numero_allocataire: numero_affiliation)

      ComptaTransaction.create(
        dossier: self,
        code_operation: 'I_BRAC',
        code_classe_evenement: 'LIQUIDATION',
        code_agence_liquidation: 'I_SG',
        numero_allocataire: numero_affiliation,
        nom: nom,
        prenom: prenom,
        adresse: adresse_domicile,
        mode_paiement: mode_paiement,
        code_banque_allocataire: compte_bancaire_code_banque,
        numero_compte_allocataire: compte_bancaire_numero_compte,
        bank_id: nil,
        bank_branch_id: nil,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: calcul_remboursement_salarial,
        code_devise: 'XOF',
        statut: :en_cours,
        ordre_paiement: op,
        description: "Remboursement de cotisations allocataire : #{numero_affiliation}",
      )
    end
  end

end

