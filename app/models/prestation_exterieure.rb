class PrestationExterieure < ApplicationRecord

  include WorkflowActiverecord
  include Documentable


  workflow_column :workflow_state

  workflow do
    state :initialisation do
      event :soumettre_etf, transition_to: :soumission_etat_chef_grp
    end

    state :soumission_etat_chef_grp do
      event :est_dossier_valide, transition_to: :dossier_valide
      event :est_dossier_rejete, transition_to: :dossier_rejete
      event :rejeter_etat_famille, transition_to: :initialisation
    end

    state :dossier_valide do
      event :est_dossier_suspendu, transition_to: :dossier_suspendu
    end

    state :dossier_rejete

    state :dossier_suspendu do
      event :retour_dossier_valide, transition_to: :dossier_valide
    end

  end


  SITUATION_MATRIMONIALE = {
    marie: 1,
    divorce: 2,
    celibataire: 3,
    veuf: 4,
    not_defined1: 5
  }

  NATIONALITE_SALARIE = {
      senegalais: 1,
      etranger: 2
  }

  SEXE_SALARIE = {
    inconnu: 0,
    masculin: 1,
    feminin: 2,
    sans_objet: 9
  }

  TYPE_PIECE = {
    cni: 1,
    carte_consulaire: 2,
    passeport: 3,
    not_defined2: 4
  }

  TYPE_RETRAITE = {
    retraite_normale: 1,
    retraite_anticipee_valide: 2,
    retraite_anticipee_invalide: 3
    }.freeze  

  ETAT = {
    creation: 1,
    valide: 2
  }.freeze

  STATE = {
    init: 'initialisation',
    soumis: 'soumission_etat_chef_grp',
    validation: 'dossier_valide',
    rejet: 'dossier_rejete',
    suspension: 'dossier_suspendu'
  }

  TYPE_DOCUMENT_OBLIGATOIRE = {

  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      cni: 1,
      #attestation_travail: 3
    }
  ).freeze

  before_create :set_numero_dossier!
  after_create :check_if_same_salarie

  scope :pret_pour_soumission_etf, -> { where(workflow_state: [:initialisation]).where(etat: 2) }

  enum etat: ETAT
  enum state: STATE
  enum situation_matrimoniale_salarie: SITUATION_MATRIMONIALE
  enum nationalite_salarie: NATIONALITE_SALARIE
  enum sexe_salarie: SEXE_SALARIE
  enum type_piece: TYPE_PIECE
  enum type_retraite: TYPE_RETRAITE

  scope :visible_for_admins, -> { where(workflow_state: [:initialisation, :soumission_etat_chef_grp, :dossier_valide, :dossier_rejete, :dossier_suspendu]) }
  scope :choosen_childreen, ->(id) { CafEnfant.joins(:indemnites_prestation_exterieures, :caf_conjoint).where(caf_conjoints: { prestation_exterieure_id: id }).where(indemnites_prestation_exterieures: { created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year) }).group('caf_enfants.id') }
  scope :liquidated_indemnites, ->(id) { IndemnitesPrestationExterieure.joins(:prestation_exterieure).where(prestation_exterieures: { id: id }).where(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year), workflow_state_dt: :liquidation) }
  scope :initialized_indemnities, ->(id) { IndemnitesPrestationExterieure.joins(:prestation_exterieure).where(prestation_exterieures: { id: id }).where(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year), workflow_state_dt: :init) }
  scope :validated_chef_grp_indemnites, ->(id) { IndemnitesPrestationExterieure.joins(:prestation_exterieure).where(prestation_exterieures: { id: id }).where(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year), workflow_state_dt: :validation_dt_chef_grp) }
  scope :validated_chef_sub_indemnites, ->(id) { IndemnitesPrestationExterieure.joins(:prestation_exterieure).where(prestation_exterieures: { id: id }).where(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year), workflow_state_dt: :validation_dt_chef_sub) }
  scope :choosen_period_per_conjoint, ->(id_prestation, id_conjoint) { IndemnitesPrestationExterieure.joins([prestation_exterieure: :caf_conjoints]).where(prestation_exterieures: { id: id_prestation }).where(caf_conjoints: { id: id_conjoint }).where(indemnites_prestation_exterieures: { workflow_state_dt: :droit_valide }).select('id', 'date_debut', 'date_fin').distinct }
  #scope :choosen_period_per_conjoint, ->(id_prestation, id_conjoint) { IndemnitesPrestationExterieure.joins([prestation_exterieure: :caf_conjoints]).where(prestation_exterieures: { id: id_prestation }).where(caf_conjoints: { id: id_conjoint }).where(indemnites_prestation_exterieures: { workflow_state_dt: :droit_valide, created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year) }).select('id', 'date_debut', 'date_fin').distinct }
  scope :eligible_for_caf_by_period, ->(id, period) { CafEnfant.joins(:caf_conjoint).where(caf_conjoints: { prestation_exterieure_id: id }).where('caf_enfants.date_naissance BETWEEN ? AND ?', period - 21.years, period).order(:date_naissance).limit(4) }

  has_one_attached :piece_justificative_caf
  has_many :document_prestation_exterieures, dependent: :destroy
  has_many :caf_conjoints, dependent: :destroy
  has_many :caf_enfants, dependent: :destroy
  has_many :indemnites_prestation_exterieures, dependent: :destroy
  has_many :ordre_paiements, as: :dossier, dependent: :destroy

  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :soumis_etf_par, class_name: 'User', foreign_key: :soumis_etf_par_id, optional: true
  belongs_to :valide_etf_par, class_name: 'User', foreign_key: :valide_etf_par_id, optional: true
  belongs_to :soumis_liq_par, class_name: 'User', foreign_key: :soumis_liq_par_id, optional: true
  belongs_to :valide_liq_par_chef_grp, class_name: 'User', foreign_key: :valide_liq_par_chef_grp_id, optional: true
  belongs_to :valide_liq_par_chef_sub, class_name: 'User', foreign_key: :valide_liq_par_chef_sub_id, optional: true
  belongs_to :valide_liq_comptable, class_name: 'User', foreign_key: :valide_liq_comptable_id, optional: true
  belongs_to :suspendu_par, class_name: 'User', foreign_key: :suspendu_par_id, optional: true

  belongs_to :admin_country, :class_name => 'Admin::Country'

  validates :prenom, :nom, :sexe_salarie, :date_naissance, :lieu_naissance, :nationalite_salarie, :type_piece,
            :nin_salarie, :situation_matrimoniale_salarie, :admin_country_id, :numero_secu_social,
            presence: true
  validates :piece_justificative_caf, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, attached: true
  validates! :numero_dossier, uniqueness: true
  validates :nin_salarie, uniqueness: true
  # validates_length_of :telephone, minimum: 12, maximum: 12
  #validates_format_of :telephone, :with => /\d[0-9]\)*\z/, :message => "Seuls les nombres positifs sans espaces sont autorisés"
  validate :age_of_salarie
  validate :length_of_cni
  validate :starting_of_cni

  def length_of_cni
    if cni?
      unless nin_salarie.length.between?(13, 14)
        errors.add(:base, "la taille du cni doit être comprise entre 13 et 14 caractères!")
      end
    end
  end

  def starting_of_cni
    if cni?
      if masculin? and nin_salarie.slice(0, 1) != '1'
        errors.add(:base, "le nin d'un homme commence par le chiffre '1'")
      end

      if feminin? and nin_salarie.slice(0, 1) != '2'
        errors.add(:base, "le nin d'une femme commence par le chiffre '2'")
      end
    end
  end

  def age_of_salarie
    if !self.date_naissance.between?(Date.today - 60.years, Date.today - 18.years)
      errors.add(:base, "l'âge du salarié doit être compris entre 18 ans et 60 ans !")
    end

  end

  def full_name
    "#{prenom} #{nom}"
  end

  def document_valid!(est_valide = true)
    update(document_valid: est_valide)
  end

  def information_valid!(est_valide = true)
    update(information_valid: true)
  end

  def conjoint_valid!(est_valide = true)
    update(conjoint_valid: est_valide)
  end

  def enfant_valid!(est_valide = true)
    update(enfant_valid: est_valide)
  end

  def indemnite_valid!(est_valide = true)
    update(indemnite_valid: est_valide)
  end

  def conjoint_invalid!(est_valide = false)
    update(conjoint_valid: est_valide)
  end

  def enfant_invalid!(est_valide = false)
    update(enfant_valid: est_valide)
  end

  def indemnites_invalid!(est_valide = false)
    update(indemnite_valid: est_valide,
           motif_rejet_etf: nil)
  end

  def reouvrir_dossier!
    update(information_valid: false,
           enfant_valid: false,
           conjoint_valid: false,
           document_valid: false, etat: :creation, workflow_state: :initialisation, etat_famille_valid: false ,
           motif_rejet_etf: nil )
  end



  def pret_pour_validation?
    information_valid and conjoint_valid and enfant_valid and document_valid
  end

  def pret_pour_soumission_etf?
    valide? and current_state <= :initialisation and !etat_famille_valid and !motif_rejet_etf?
  end

  def pret_pour_generation_etat?
    valide? and current_state >= :dossier_valide and etat_famille_valid?
  end

  def est_rejetee_etat_famille?
    valide? and current_state.between? :initialisation, :soumission_etat_chef_grp and !etat_famille_valid? and motif_rejet_etf?
  end

  def can_add_conjoint?
    feminin? and marie? and CafConjoint.exists?(prestation_exterieure_id: id)
  end

  def set_numero_dossier!
    annee = Date.today.year
    nin = self.nin_salarie
    if PrestationExterieure.exists?(nin_salarie: nin, created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year))
      dernier_dossier_ajoute = PrestationExterieure.where(nin_salarie: nin, created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year)).order('created_at DESC').first
      self.numero_dossier = dernier_dossier_ajoute.numero_dossier.next
    else
      self.numero_dossier = "#{nin}/#{annee}/CAF0001"
    end
  end

  def montant_beneficiaire
    montant * 80 / 100
  end

  def getPays(admin_country_id)
    Admin::Country.find(admin_country_id)
  end

  def getCity(admin_city_id)
    Admin::City.find(admin_city_id)
  end

  def check_if_same_salarie
    @new_item = PrestationExterieure.last
    prestation = PrestationExterieure.where(nin_salarie: @new_item.nin_salarie).first
    unless prestation.nil?
      @conjoints = CafConjoint.where(prestation_exterieure_id: prestation[:id])

      @conjoints.each do |conjoint|
        item = CafConjoint.new
        item.nom = conjoint.nom
        item.prenom = conjoint.prenom
        item.nom_jeune_fille = conjoint.nom_jeune_fille
        item.date_naissance = conjoint.date_naissance
        item.lieu_naissance = conjoint.lieu_naissance
        item.adresse_precise = conjoint.adresse_precise
        item.date_mariage = conjoint.date_mariage
        item.date_separation = conjoint.date_separation
        item.date_divorce = conjoint.date_divorce
        item.certificat_mariage.attach(conjoint.certificat_mariage.blob)
        item.piece_identite.attach(conjoint.piece_identite.blob)
        item.etat_couple = conjoint.etat_couple
        item.prestation_exterieure_id = @new_item.id
        puts 'error', item.errors.full_messages unless item.save
      end

    end
  end


  def require_pieces_change?
    enfants = CafEnfant.joins(:caf_conjoint).where(caf_conjoints: {prestation_exterieure_id: id})
    require_change = false
    enfants.each do |enfant|
      if enfant.extrait_naisance?
        unless (DateTime.now.beginning_of_year..DateTime.now.end_of_year).cover?(enfant.piece_identite.created_at)
          require_change = true
        end
      end
    end
    require_change
  end


  def is_date_echeance?
    DateTime.now >= Date.new(Date.today.year, 04, 01)
  end

  def suspendre_dossier!
    update(workflow_state: :dossier_suspendu)
  end

  def is_limit_of_childreen?
    enfants = PrestationExterieure.choosen_childreen(id)
    enfants.length >= 4
  end

  def build_payment_order(id_conjoint)
    period = PrestationExterieure.choosen_period_per_conjoint(id, id_conjoint)
  end

  def get_status?
    (TYPE_DOCUMENT.length == documents.length) or est_repris?
  end

  def has_initialized_indemnities?
    self.indemnites_prestation_exterieures.exists?(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year), workflow_state_dt: :init)
  end

  def has_liquidated_indemnites?
    self.indemnites_prestation_exterieures.exists?(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year), workflow_state_dt: :liquidation)
  end

  def has_validated_chef_grp_indemnites?
    self.indemnites_prestation_exterieures.exists?(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year), workflow_state_dt: :validation_dt_chef_grp)
  end

  def has_validated_chef_sub_indemnites?
    self.indemnites_prestation_exterieures.exists?(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year), workflow_state_dt: :validation_dt_chef_sub)
  end

  def enfants_allocataire(date_debut, date_fin)
    CafEnfant.joins(:caf_conjoint).where(caf_conjoints: { prestation_exterieure_id: id }, caf_enfants: { active: true })
             .where.not(caf_enfants: { id: existing_associated_children_ids(date_debut, date_fin) })
             .to_json.html_safe
  end

  def enfants_documents
    Document.where(documentable_type: 'CafEnfant').where(documentable_id: caf_enfants.pluck(:id)).to_json.html_safe
  end

  def has_beneficiary?
    self.caf_conjoints.exists?(is_beneficiary: true)
  end

  def validate_payment(user)
    return unless has_validated_chef_sub_indemnites?

    ActiveRecord::Base.transaction do
      indemnities = fetch_validated_indemnities
      indemnities_associations = fetch_indemnities_associations(indemnities)

      ordre_paiements = create_ordre_paiements(indemnities_associations)

      update_indemnities(indemnities, user)
      associate_ordre_paiement(indemnities_associations, ordre_paiements)
    end
  rescue => e
    Rails.logger.error "Erreur lors de la validation des paiements: #{e.message}"
    puts "Erreur lors de la validation des paiements: #{e.message}"
  end

  private

  def fetch_validated_indemnities
    PrestationExterieure.validated_chef_sub_indemnites(id)
  end

  def fetch_indemnities_associations(indemnities)
    IndemnitesPrestationExterieureAssoc.where(
      indemnites_prestation_exterieure_id: indemnities.map(&:id)
    )
  end

  def create_ordre_paiements(indemnities_associations)
    ops = Array.new
    indemnities_associations.group_by { |assoc| assoc.caf_enfant.caf_conjoint_id }
                            .each do |beneficiary_id, associations|
      puts "Processing beneficiary_id: #{beneficiary_id}, Associations: #{associations.inspect}"

      ops << OrdrePaiement.create(
        dossier: self,
        numero_allocataire: numero_secu_social,
        beneficiaire_id: beneficiary_id,
        type_beneficiary: :caf_conjoint
      )
    end
    ops
  end

  def update_indemnities(indemnities, user)
    indemnities.each do |indemnite|
      next unless indemnite.validation_dt_chef_sub?

      indemnite.update!(
        workflow_state_dt: :droit_valide,
        valide_cpt_par: user,
        date_validation_cpt: DateTime.now,
        paiement: true
      )
    end
  end

  def associate_ordre_paiement(indemnities_associations, ordre_paiements)
    indemnities_associations.each do |association|
      beneficiary_id = association.caf_enfant.caf_conjoint_id
      type_beneficiary = 'caf_conjoint'
      order_id = ordre_paiements.select { |op| op.beneficiaire_id == beneficiary_id and op.type_beneficiary == type_beneficiary }.first.id
      association.update!(ordre_paiement_id: order_id)
    end
  end

  # Récupère les IDs des enfants associés à cette période
  def existing_associated_children_ids(date_debut, date_fin)
    indemnites_prestation_exterieures
      .where('date_debut <= ? AND date_fin >= ?', date_fin, date_debut)
      .joins(:indemnites_prestation_exterieure_assocs)
      .pluck('indemnites_prestation_exterieure_assocs.caf_enfant_id')
      .uniq
  end

end
