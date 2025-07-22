class DossierPrestation < ApplicationRecord
  include WorkflowActiverecord
  include Documentable

  workflow_column :etat

  workflow do
    state :creation, :meta => { label: 'Création' } do
      event :est_suspendu, transition_to: :suspendu
      event :est_soumis, transition_to: :soumis
      event :est_cloturer, transition_to: :cloturer
    end

    state :soumis, :meta => { label: 'Soumis' } do
      event :est_suspendu, transition_to: :suspendu
      event :en_cours_de_traitement, transition_to: :valide
      event :retour_creation, transition_to: :creation
      event :est_cloturer, transition_to: :cloturer
    end

    state :valide, :meta => { label: 'Validé' } do
      event :est_suspendu, transition_to: :suspendu
      event :retour_soumis, transition_to: :soumis
      event :est_cloturer, transition_to: :cloturer
    end

    state :suspendu, :meta => { label: 'Suspendu' } do
      event :retour_valides, transition_to: :valide
      event :est_cloturer, transition_to: :cloturer
    end

    state :rejete, :meta => { label: 'Rejeté' }
    state :cloturer, :meta => { label: 'Cloturé' }

  end

  NATIONALITE = {
    senegalais: 1,
    etranger: 2
  }.freeze
  enum nationalite: NATIONALITE

  SEXE = {
    masculin: 1,
    feminin: 2
  }.freeze

  TYPE_DOCUMENT_OBLIGATOIRE = {

  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      cni: 1,
      extrait_naissance: 2,
      carte_consulaire: 3,
      passeport: 4,
      declaration_sur_honneur: 20,
      attestation_travail: 3,
      formulaire_demande: 90,
      certificat_vie_collectif: 81,
      dmt: 99,
      formulaire_demande_pf: 99,
      autres: 100,

    }
  ).freeze

  enum sexe_salarie: SEXE

  belongs_to :user, optional: true
  belongs_to :conjoint, optional: true
  belongs_to :salarie, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  belongs_to :suspandu_par, class_name: 'User', foreign_key: :suspendu_par_id, optional: true
  belongs_to :cloture_par, class_name: 'User', foreign_key: :cloture_par_id, optional: true
  belongs_to :affecte_a, class_name: 'User', foreign_key: :affecte_a_id, optional: true
  belongs_to :admin_agence, optional: true, :class_name => 'Admin::Agence', foreign_key: :agence_id
  has_many :document_dossier_prestations, dependent: :destroy
  has_many :carriere_dossier_prestations, foreign_key: :dossier_prestation_id, primary_key: :id, dependent: :destroy
  has_many :allocation_prenatales, dependent: :destroy
  has_many :allocation_postnatales, dependent: :destroy
  has_many :allocation_familiales, dependent: :destroy
  has_many :grossesses, dependent: :destroy
  has_many :enfants, foreign_key: :numero_affiliation, primary_key: :num_affiliation
  has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :num_affiliation
  has_many :enfants_avec_volets, -> { distinct }, class_name: 'Enfant', through: :allocation_postnatales, source: :enfant
  has_many :maintien_prestations, foreign_key: 'dossier_prestations_id', primary_key: 'id'
  has_many :allocations_familiales_migrees, dependent: :destroy, primary_key: 'num_dossier'
  has_many :allocations_prenatales_migrees, dependent: :destroy, primary_key: 'num_dossier'
  has_many :allocations_postnatales_migrees, dependent: :destroy, primary_key: 'num_dossier'
  belongs_to :participant, :class_name => 'Psrm::Participant',
             foreign_key: :num_affiliation,
             primary_key: :matric,
             optional: true
  belongs_to :psrm_employeur, :class_name => 'Psrm::Employeur', foreign_key: :employeur_actuel, primary_key: :fhnum, optional: true

  has_many :ordre_paiements, as: :dossier, dependent: :destroy
  has_many :compta_transactions, through: :ordre_paiements
  has_many :beneficiary_associations_to_dps
  has_many :echeance_caisse_dossiers
  has_many :dossier_prestation_historics
  has_many :demande_pf_clotures
  has_many :attributaire_tierces
  has_many :dossier_prestation_avis_tiers, foreign_key: :dossier_prestation_id
  has_many :historic_ech_exclusions
  has_many :css_fiabilisation_historics
  belongs_to :admin_agence, optional: true, :class_name => 'Admin::Agence', foreign_key: :agence_id

  validates :num_affiliation, :prenom, :nom, :date_naissance, :lieu_naissance, presence: true, unless: -> { incomplete? }
  validates :date_reception, presence: true, if: -> { conjoint_id.nil? && creation? }, unless: -> { est_repris? }
  validates :condition_1, :condition_2, :condition_3, acceptance: { message: 'doit être acceptée' }
  #validates :condition_1, :condition_2, :condition_3, presence: true, if: :soumis?
  validate :validate_num_affiliation
  validates :conjoint_id, uniqueness: { message: "Vous avez déjà un dossier avec ce conjoint" }, allow_nil: true
  validate :valider_nbr_dossier_sans_conjoint, on: :create
  validates :employeur_actuel, presence: true, on: :create, if: -> { conjoint_id.nil? }
  validate :valider_date_reception
  validate :valider_age_salarie
  validates :nin, presence: true, on: :create, if: -> { conjoint_id.nil? }
  validates :nin, uniqueness: true, on: :create, if: -> { nin and conjoint_id.nil? }
  validate :length_of_nin, unless: -> { incomplete? }
  validate :starting_of_nin, unless: -> { incomplete? }
  validates :telephone, presence: true, phone: { possible: true, allow_blank: true, types: [:mobile] }, numericality: true, length: { :minimum => 12, :maximum => 15 }, if: -> { conjoint_id.nil? && creation? }, unless: -> { est_repris? } #,  country_specifier: -> phone { phone.country.try(:upcase) } }

  #validates :conjoint_id, presence: true, if: -> { masculin? }
  #validate :validate_delai_stage, on: :create

  #validates :date_embauche, presence: true
  #
  scope :not_deleted, -> { where(deleted: false) }

  scope :not_incomplete, -> { where(incomplete: false) }

  scope :en_agence, ->(id) { where(agence_id: id) }

  scope :enfant_avec_conjoint, -> { where(etat: [:soumis, :traitement_en_cours]) }

  scope :workflow_etat, ->(etat) { where(etat: etat) }

  scope :en_attente, -> { where(etat: [:soumis, :traitement_en_cours]) }

  scope :est_valide, -> { where(etat: [:valide]) }

  scope :pret_pour_allocations_f, -> { where(etat: [:valide, :suspendu]) }

  scope :visible_for_admins, -> { where(etat: [:creation, :soumis, :traitement_en_cours, :valide, :rejete, :suspendu, :cloturer]) }

  scope :list_dossier_allocataire, -> { where(conjoint_id: nil) }

  scope :with_allocation_postanatale_soumis, -> { joins(:allocation_postnatales).where(allocation_postnatales: { etat: :soumis }).distinct }

  scope :with_allocation_prenatale_soumis, -> { joins(:allocation_prenatales).where(allocation_prenatales: { etat: :soumis }).distinct }

  scope :with_allocation_familiale_soumis, -> { (where(allocation_familiales: { etat: :soumis }).where(allocation_familiales: { echeance_caisse_id: nil }).or(where.not(allocation_familiales: { echeance_caisse_id: nil }).where(allocation_familiales: { is_from_ech_paid: true }))).joins(:allocation_familiales).distinct }

  scope :with_allocation_postanatale_valide, -> { joins(:allocation_postnatales).where(allocation_postnatales: { etat: :valide, paiement: false }) }

  scope :with_allocation_prenatale_valide, -> { joins(:allocation_prenatales).where(allocation_prenatales: { etat: :valide, paiement: false }) }

  scope :with_allocation_familiale_valide, -> { (where(allocation_familiales: { etat: :valide, paiement: false }).where(allocation_familiales: { echeance_caisse_id: nil }).or(where.not(allocation_familiales: { echeance_caisse_id: nil }).where(allocation_familiales: { is_from_ech_paid: true }))).joins(:allocation_familiales) }

  before_validation :set_num_affiliation!
  before_create :set_user!
  before_create :set_numero_dossier!
  before_create :verif_date_ouverture_droit
  after_create :set_dossier_historic
  #before_create :delai_de_stage
  after_update :update_sub_dossier
  after_destroy :delete_sub_folder
  before_save :save_css_fiabilisation_historic

  #def delai
  #
  #  a = TimeDifference.between(Date.today, participant.date_premiere_embauche).in_general unless participant.date_premiere_embauche.nil?
  #  an = ' ans, '
  #  jr = ' jours'
  #  if (a[:years] <= 1)
  #    an = ' an, '
  #  end
  #  if (a[:days] <= 1)
  #    jr = ' jour'
  #  end
  #  a[:years].to_s + an + a[:months].to_s + ' mois, ' + a[:days].to_s + jr
  #end

  def est_suspendu?
    etat.eql?('suspendu')
  end

  def can_initiate_widow_regularization?
    not has_maintien_prestation_active? and suspendu?
  end

  def dossier_exist?
    not num_affiliation.nil? and DossierPrestation.exists?(num_affiliation: num_affiliation, incomplete: false, conjoint_id: nil)
  end

  def can_be_completed?
    incomplete? and not num_affiliation.nil? and not num_affiliation.empty? and not num_affiliation.eql?('?')
  end

  def save_css_fiabilisation_historic
    return unless est_repris?
    dossier = DossierPrestation.find(self.id)
    return unless dossier.incomplete?
    css_f_historic = CssFiabilisationHistoric.new
    css_f_historic.dossier = self
    css_f_historic.numero_affiliation = dossier.num_affiliation
    css_f_historic.ajoute_par = User.current
    puts 'erroorrrrrr', css_f_historic.errors.full_messages unless css_f_historic.save
  end

  def turn_to_complete!(ipt = false)
    self.incomplete = ipt
    self.save(validate: false)
  end

  def delete_sub_folder
    DossierPrestation.where(num_affiliation: self.num_affiliation).where.not(conjoint_id: nil).destroy_all
  end

  def update_sub_dossier
    if conjoint_id.nil? and valide?
      sub_dossiers = DossierPrestation.where(num_affiliation: num_affiliation).where.not(conjoint_id: nil)
      sub_dossiers.update_all(sexe_salarie: sexe_salarie, nin: nin, date_naissance: date_naissance, date_ouverture: date_ouverture, employeur_actuel: employeur_actuel)
    end
  end

  def length_of_nin
    if nin
      unless nin.length.between?(13, 14)
        errors.add(:base, "la taille du nin doit être comprise entre 13 et 14 caractères!")
      end
    end
  end

  def starting_of_nin
    if nin
      if masculin? and nin.slice(0, 1) != '1'
        errors.add(:base, "le nin d'un homme commence par le chiffre '1'")
      end

      if feminin? and nin.slice(0, 1) != '2'
        errors.add(:base, "le nin d'une femme commence par le chiffre '2'")
      end
    end
  end

  def can_all_liquidate?
    check = false
    allocations = allocation_familiales.where(document_valid: true, etat: :creation)
    allocations.each do |a|
      if a.can_be_liquidate? and (a.echeance_caisse.nil? or (not a.echeance_caisse.nil? and a.is_from_ech_paid?))
        check = true
        break
      end
    end
    User.current.gestionnaire_compte_allocataire? and check and current_state < :cloturer
  end

  def can_do_regularization?
    User.current.gestionnaire_compte_allocataire? and conjoint_id.nil?
  end

  def can_maintien_prestation?
    has_carriere_dossier_prestation? and current_state >= :valide and User.current.gestionnaire_compte_allocataire? and current_state < :cloturer
  end

  def get_last_carriere
    carriere = Psrm::Carriere.where(matric: self.num_affiliation).last
  end

  def has_carriere_dossier_prestation?
    (self.carriere_dossier_prestations.exists? and not est_repris?) or est_repris?
  end

  def est_legitime_allocation_pre_postnatale?
    if self.conjoint.divorcer?
      nbr_jour_apres_divorce = Date.today - self.conjoint.date_divorce
    end
    salary = Salarie.where(matric: self.num_affiliation).deces.first
    unless salary.nil?
      nbr_jour_apres_deces = Date.today - salary.date_deces
    end

    self.conjoint.union? || (self.conjoint.divorcer? and nbr_jour_apres_divorce < 300) || (self.conjoint.deced? and nbr_jour_apres_deces < 300)

  end

  def est_legitime_allocation_pre_postnatale_bis?
    is_eligible = true
    if self.masculin?
      if self.conjoint.divorcer?
        nbr_jour_apres_divorce = Date.today - self.conjoint.date_divorce
      end
      salary = Salarie.where(matric: self.num_affiliation).deces.first
      if self.conjoint.deceder?
        nbr_jour_apres_deces = Date.today - self.conjoint.date_deces
      end

      is_eligible = self.conjoint.union? || (self.conjoint.divorcer? and nbr_jour_apres_divorce < 300) || (self.conjoint.deceder? and nbr_jour_apres_deces < 300)
    end
    is_eligible
  end

  def has_maintien_prestation?
    self.maintien_prestations.exists?
  end

  def has_maintien_prestation_active?
    self.maintien_prestations.exists?(etat: 1)
  end

  def has_maintien_prestation_inactive?
    self.maintien_prestations.exists?(etat: 0)
  end

  def get_maintien_prestations_inactive
    self.maintien_prestations.where(etat: 0)
  end

  def get_maintien_prestations_active
    self.maintien_prestations.where(etat: 1).first
  end

  def find_quarter(month)
    case month
    when 1, 2, 3 then
      1
    when 4, 5, 6 then
      2
    when 7, 8, 9 then
      3
    when 10, 11, 12 then
      4
    end
  end

  def get_date_arret_maintien(maintien)
    nombre_mois_presence = 3 * (self.carriere_dossier_prestations.size)
    date_eff = maintien.date_effective
    if maintien.chomage?
      date_arret = set_current_date(find_quarter(date_eff.month), date_eff.year) + get_nombre_mois_accorde(nombre_mois_presence).months
    else
      date_arret = self.enfants.est_cadet.first.date_naissance + 21.years unless self.enfants.est_cadet.first.nil?
    end
  end

  def get_nombre_mois_accorde(mois_presence)
    if mois_presence >= 6 and mois_presence < 12
      1
    elsif mois_presence >= 12 and mois_presence < 18
      2
    elsif mois_presence >= 18
      6
    else
      0
    end
  end

  def get_last_month_of_trimestre(trimestre)
    3 * trimestre.to_i
  end

  def set_current_date(trimestre, annee)
    month = get_last_month_of_trimestre(trimestre)
    date = Date.new(annee, month, 1)
    date.change(day: date.end_of_month.day)
  end

  def attente_paiement?
    valide? and allocation_prenatales.valide.non_paye.empty? and allocation_postnatales.valide.non_paye.empty? and allocation_familiales.not_from_echeance.valide.non_paye.empty?
  end

  def full_name
    "#{prenom} #{nom}"
  end

  def etat_civil_demandeur_valid!(est_valide = true)
    update(etat_civil_demandeur_valid: est_valide)
  end

  def enfants_valide!(est_valide = true)
    update(enfants_valid: est_valide)
  end

  def carriere_valid!(est_valide = true)
    update(carriere_valid: est_valide)
  end

  def document_valid!(est_valide = true)
    update(document_valid: est_valide)
  end

  def pret_pour_soumission?
    etat_civil_demandeur_valid and enfants_valid and carriere_valid and document_valid
  end

  def pret_pour_soumission_pre_post_natal?
    etat_civil_demandeur_valid and enfants_valid and document_valid
  end

  def pret_pour_validation?
    etat_civil_demandeur_valid and enfants_valid and carriere_valid and document_valid
  end

  def pret_pour_validation_pre_post_natal?
    etat_civil_demandeur_valid and enfants_valid and document_valid
  end

  def delai_de_stage
    return if participant.nil?
    return if participant.date_premiere_embauche.nil?
    (Date.today.year * 12 + Date.today.month) - (participant.date_premiere_embauche.to_date.year * 12 + participant.date_premiere_embauche.to_date.month)
  end

  #Calul de temps de presence
  def temps_de_presence
    sommes = 0
    temps = 0
    unless carriere_dossier_prestations.nil?
      carriere_dossier_prestations.each do |tdp|
        temps = tdp.premier_mois + tdp.deuxiem_mois + tdp.troisiem_mois
        sommes += temps
      end
    end
    sommes
  end

  #Fin calcul de temps de presence

  def valider_nbr_dossier_sans_conjoint
    nbr_dossier_sans_conjoint = DossierPrestation.where(num_affiliation: num_affiliation, conjoint_id: nil).count

    if nbr_dossier_sans_conjoint >= 1 and self.conjoint_id.nil?
      errors.add(:base, " Le salarié a déjà un dossier existant.")
    end

  end

  def valider_date_reception
    if date_reception? and date_reception > Date.today
      errors.add(:base, "La date de réception ne peut être postérieur à la date du jour.")
    end
  end

  def age
    return if date_naissance.nil?
    age = Date.today.year - date_naissance.year
    age -= 1 if Date.today < date_naissance + age.years
    age
  end

  def has_acceptable_age
    return if date_naissance.nil?
    self.age < 61 and self.age >= 15
  end

  def valider_age_salarie
    unless age.nil?
      if self.age >= 61
        errors.add(:base, "Salarié a plus de 61 ans.")
      end
      if self.age < 15
        errors.add(:base, "Le salarié doit avoir au moins 15 ans.")
      end
    end
  end

  def verif_date_ouverture_droit
    return if date_ouverture.nil?
    if created_at < date_ouverture
      errors.add(:base, "La date d'ouverture ne peut pas être antérieur à la date de creation")
    end
  end

  def set_dossier_historic(date_transfer = nil)
    return if DossierPrestationHistoric.where(dossier_prestation: self, employeur_matric: self.employeur_actuel, date_embauche: date_embauche).exists?

    # Mark existing historic records as not current
    DossierPrestationHistoric.where(dossier_prestation: self).update_all(is_current: false)

    # Create a new historical record
    historic = DossierPrestationHistoric.new(
      dossier_prestation: self,
      employeur_matric: self.employeur_actuel,
      admin_agence: self.admin_agence,
      date_embauche: self.date_embauche,
      transfer_date: date_transfer,
      is_current: true
    )

    unless historic.save
      # Log error with more context
      Rails.logger.error("Failed to save DossierPrestationHistoric: #{historic.errors.full_messages}")
      raise ActiveRecord::RecordInvalid.new(historic) # Raise an exception or handle failure appropriately
    end
  end

  def get_all_carrier(employeur_matric)
    carriers = carriere_dossier_prestations.where("num_employeur = ? or num_employeur_mois_2 = ? or num_employeur_mois_3 = ?", employeur_matric, employeur_matric, employeur_matric)
  end

  def get_all_allocations(employeur_matric)
    cpt = 0
    carriers = get_all_carrier(employeur_matric)
    carriers.each do |cr|
      cpt += 1 unless allocation_familiales.find_by(trimestre: cr.trimestre, annee: cr.annee).nil?
    end
    cpt
  end

  def get_all_allocations_amount(employeur_matric)
    amount = 0
    carriers = get_all_carrier(employeur_matric)
    carriers.each do |cr|
      amount = allocation_familiales.valide.find_by(trimestre: cr.trimestre, annee: cr.annee).montant_paiement unless allocation_familiales.valide.find_by(trimestre: cr.trimestre, annee: cr.annee).nil?
    end
    amount
  end

=begin
  def valider_paiements(utilisateur)
    prestation_prenatales = allocation_prenatales.valide.non_paye
    prestation_postnatales = allocation_postnatales.valide.non_paye
    prestation_familiales = allocation_familiales.valide.non_paye

    montant_total = prestation_prenatales.sum(:montant_paiement)
    montant_total += prestation_postnatales.sum(:montant_paiement)
    montant_total += prestation_familiales.sum(:montant_paiement)

    return false unless montant_total > 0

    op = OrdrePaiement.create(dossier: self, numero_allocataire: num_affiliation)

    (prestation_prenatales + prestation_postnatales + prestation_familiales).each_with_index do |prestation, i|
      unless i.zero?
        prestation.en_tete_comptabilite = false
      end
      prestation.traite_par = utilisateur
      prestation.paiement = true
      prestation.ordre_paiement = op
      prestation.save
    end
    true
  end
=end

  def has_beneficiaries?
    not beneficiary_associations_to_dps.count.zero?
  end

  def create_required_op(allocations) end

  def check_if_avis_tiers_exist?
    dossier_prestation_avis_tiers.exists?(type_avis: :trop_percu, etat: :valide, status: :non_paye)
  end

  def get_avis_tiers
    dossier_prestation_avis_tiers.where(type_avis: :trop_percu, etat: :valide, status: :non_paye).first
  end

  def manage_avis_tiers(allocations, op)
    if check_if_avis_tiers_exist?
      avis_tiers = get_avis_tiers
      allocations_amount = allocations.to_a.sum(&:montant_paiement)
      ref_amount = avis_tiers.remaining_amount > avis_tiers.montant_echeance ? avis_tiers.montant_echeance : avis_tiers.remaining_amount
      paid_amount = ref_amount <= allocations_amount ? ref_amount : allocations_amount
      li = LignePfAvisTierTransaction.new
      li.dossier_prestation_avis_tier = avis_tiers
      li.ordre_paiement = op
      li.montant = paid_amount
      li.montant_paye = 0
      li.ajoute_par = User.current
      puts 'error', li.errors.full_messages unless li.save

      if avis_tiers.montant_avis == avis_tiers.get_amount_paid
        avis_tiers.status = DossierPrestationAvisTier.statuses['paye']
        avis_tiers.save
      end
    end
  end

  def valider_paiements(utilisateur)
    prestation_prenatales = allocation_prenatales.valide.non_paye
    prestation_postnatales = allocation_postnatales.valide.non_paye
    prestation_familiales = allocation_familiales.not_from_echeance.valide.non_paye
    ppn_allocations = prestation_postnatales + prestation_prenatales
    allocations = prestation_familiales + ppn_allocations
    op_array = Array.new

    montant_total = prestation_prenatales.sum(:montant_paiement)
    montant_total += prestation_postnatales.sum(:montant_paiement)
    montant_total += prestation_familiales.sum(:montant_paiement)

    return false unless montant_total > 0

    if check_if_avis_tiers_exist?
      op_array << OrdrePaiement.create(dossier: self, numero_allocataire: num_affiliation)
      manage_avis_tiers(allocations, op_array.first)
    end

    unless prestation_familiales.count.zero?
      if check_if_avis_tiers_exist?
        (prestation_familiales).each do |allocation|
          allocation.ordre_paiement = op_array.first
        end
      else
        conjoint_beneficiary_array = beneficiary_associations_to_dps.map { |beneficiary| beneficiary }.group_by { |x| [x.type_beneficiary, x.conjoint_id, x.attributaire_tierce_id] }
        enfants = prestation_familiales.pluck(:enfant_id)
        all_beneficiaries = self.beneficiary_associations_to_dps.map { |beneficiary| beneficiary[:enfant_id] }

        conjoint_beneficiary_array.each do |cb|
          if (enfants & cb.last.pluck(:enfant_id)).any?
            if OrdrePaiement.type_beneficiaries[cb.first[0]] == 1
              op_array << OrdrePaiement.create(dossier: self, numero_allocataire: num_affiliation, beneficiaire_id: cb.first[1], type_beneficiary: OrdrePaiement.type_beneficiaries[cb.first[0]])
            elsif OrdrePaiement.type_beneficiaries[cb.first[0]] == 2
              op_array << OrdrePaiement.create(dossier: self, numero_allocataire: num_affiliation, beneficiaire_id: cb.first[2], type_beneficiary: OrdrePaiement.type_beneficiaries[cb.first[0]])
            end
          end
        end

        if enfants.difference(all_beneficiaries).any?
          op_array << OrdrePaiement.create(dossier: self, numero_allocataire: num_affiliation)
        end

        (prestation_familiales).each_with_index do |allocation, i|
          if all_beneficiaries.include?(allocation.enfant_id)
            if allocation.enfant.beneficiary_associations_to_dps.first.conjoint?
              beneficiary_id = allocation.enfant.beneficiary_associations_to_dps.first.conjoint_id
              type_beneficiary = 'conjoint'
            elsif allocation.enfant.beneficiary_associations_to_dps.first.attributaire?
              beneficiary_id = allocation.enfant.beneficiary_associations_to_dps.first.attributaire_tierce_id
              type_beneficiary = 'attributaire'
            end
            allocation.ordre_paiement = op_array.select { |op| op.beneficiaire_id == beneficiary_id and op.type_beneficiary == type_beneficiary }.first
          else
            allocation.ordre_paiement = op_array.select { |op| op.beneficiaire_id == nil }.first
          end
        end
      end
    end

    unless ppn_allocations.count.zero?
      op = op_array.select { |op| op.beneficiaire_id == nil }.first.nil? ? OrdrePaiement.create(dossier: self, numero_allocataire: num_affiliation) : op_array.select { |op| op.beneficiaire_id == nil }.first
      (ppn_allocations).each do |allocation|
        allocation.ordre_paiement = op
      end
    end

    (allocations).each_with_index do |allocation, i|
      allocation.en_tete_comptabilite = i.zero?
      allocation.traite_par = utilisateur
      allocation.paiement = true
      puts 'error', allocation.errors.full_messages unless allocation.save
    end

    true
  end

  def valider_paiements_veuves(user)
    allocations = self.allocation_familiales.from_maintein_by_death.where.not(maintien_prestation_id: nil).en_agence(User.current.agence.id).valide.non_paye
    conjoint_op_array = allocations.map { |allocation| allocation }.group_by { |x| x.enfant.conjoint_id }
    conjoint_op_array.each do |cj|

      op = OrdrePaiement.create(dossier: self, numero_allocataire: num_affiliation, beneficiaire_id: cj.first, type_beneficiary: 1)

      cj.last.each_with_index do |prestation, i|
        prestation.en_tete_comptabilite = i.zero?
        prestation.traite_par = user
        prestation.paiement = true
        prestation.ordre_paiement = op
        prestation.save
      end
    end
  end

  # def generate_allocation(enfant, nbr_month_left, quarter, year, echeance_dossier_id = nil )
  #   echeance_dossier = EcheanceCaisseDossier.find(echeance_dossier_id) unless echeance_dossier_id.nil?
  #   nbr_exclude = echeance_dossier.get_excluded_months_by_child unless echeance_dossier.nil?
  #   nbr_month = 3
  #   nbr_month = 3 - nbr_exclude unless nbr_exclude.nil?
  #   nbr_month = nbr_month <= nbr_month_left ? nbr_month : nbr_month_left
  #   available_amount = 2600 * nbr_month
  #   date = Date.new(year.to_i, quarter.to_i * 3, 19)
  #   allocation = AllocationFamiliale.new
  #   allocation.enfant_id = enfant.id
  #   allocation.dossier_prestation_id = self.id
  #   allocation.trimestre = quarter.to_i
  #   allocation.annee = year.to_i
  #   allocation.date_ouverture_droit = Date.today
  #   #allocation.date_reception = self.bordereau_collectif_id.nil? ? self.date_document : self.bordereau_collectif.date_document
  #   allocation.ajoute_par = User.current
  #   allocation.etat = :creation
  #   allocation.montant_paiement = available_amount > allocation.montant_a_payer ? allocation.montant_a_payer : available_amount
  #   allocation.date_debut_validite = date
  #   allocation.date_fin_validite = date.end_of_month + 1.year
  #   allocation.admin_agence = User.current.agence
  #   allocation.maintien_prestation = self.get_maintien_prestations_active if suspendu?
  #   puts 'error', allocation.errors.full_messages unless allocation.save
  # end

  def generate_allocation(enfant, nbr_month_left, quarter, year, echeance_dossier_id = nil)
    echeance_dossier = EcheanceCaisseDossier.find_by(id: echeance_dossier_id)
    nbr_exclude = echeance_dossier&.get_excluded_months_by_child
    nbr_month = [3 - (nbr_exclude || 0), nbr_month_left].min

    available_amount = 2600 * nbr_month
    date = Date.new(year.to_i, quarter.to_i * 3, 19)

    allocation = AllocationFamiliale.new(
      enfant_id: enfant.id,
      dossier_prestation_id: self.id,
      trimestre: quarter.to_i,
      annee: year.to_i,
      date_ouverture_droit: Date.today,
      ajoute_par: User.current,
      etat: :creation,
      date_debut_validite: date,
      date_fin_validite: date.end_of_month + 1.year,
      admin_agence: User.current.agence
    )
    begin
      allocation.montant_paiement = [available_amount, allocation.montant_a_payer].min
    rescue => e
      Rails.logger.error "Erreur lors du calcul du montant à payer : #{e.message}"
      raise "Merci de renseigner le temps de présence dans l'échéance #{allocation.errors.full_messages.join(', ')}"
      return
    end

    allocation.maintien_prestation = self.get_maintien_prestations_active if suspendu?

    unless allocation.save
      Rails.logger.error "AllocationFamiliale save failed: #{allocation.errors.full_messages}"
    end
  end

  def generate_reference
    letters = (0..9).to_a + ('A'..'Z').to_a
    id.to_s + letters.sample(10).join
  end

  def find_base_folder
    unless self.conjoint.nil?
      DossierPrestation.where(num_affiliation: self.num_affiliation).where(conjoint_id: nil).first
    end
  end

  def has_sub_folder?
    DossierPrestation.where(num_affiliation: self.num_affiliation).where.not(conjoint_id: nil).length > 0
  end

  def all_sub_folder
    DossierPrestation.where(num_affiliation: self.num_affiliation).where.not(conjoint_id: nil)
  end

  def is_base_folder?
    self.conjoint_id == nil
  end

  def has_beneficiary?
    self.conjoints.exists?(est_af_beneficiaire: true)
  end

  def get_beneficiary
    if has_beneficiary?
      self.conjoints.where(est_af_beneficiaire: true).first.full_name
    else
      full_name
    end
  end

  def get_beneficiary_nin
    if has_beneficiary?
      self.conjoints.where(est_af_beneficiaire: true).first.numero_piece
    else
      self.participant.numero_piece
    end
  end

  def dertemine_date_embauche
    premier_contrat = Participant.carrieres.order('date_debut_periode_cotisation DESC').last.try(:date_debut_contrat) if not participant.carrieres.nil?
    dernier_contrat = Participant.carrieres.order('date_debut_periode_cotisation DESC').first.try(:date_debut_contrat) if not participant.carrieres.nil?
    fin_dernier_contrat = Participant.carrieres.order('date_debut_periode_cotisation DESC').first.try(:date_fin_contrat) if not participant.carrieres.nil?

    unless fin_dernier_contrat || dernier_contrat
      return premier_contrat unless premier_contrat.nil?
    end

    if not fin_dernier_contrat.nil? and not dernier_contrat.nil? and dernier_contrat - fin_dernier_contrat < 1.month
      return premier_contrat
    elsif not fin_dernier_contrat.nil? and not dernier_contrat.nil? and dernier_contrat - fin_dernier_contrat > 1.month
      return dernier_contrat
    end
  end

  def set_date_ouverture_droit
    premiere_mariage = Conjoint.premiere_date_mariage.where(numero_affiliation: self.num_affiliation).pluck(:date_mariage).first

    #date d'ouverture date de reception -1 ans
    return if self.date_reception.nil?

    if !premiere_mariage.nil? and !self.date_embauche.nil?

      self.date_ouverture = [self.date_reception.last_year.to_date, premiere_mariage.to_date, self.date_embauche.to_date].max
    elsif premiere_mariage.nil? and !self.date_embauche.nil?
      self.date_ouverture = [self.date_reception.last_year.to_date, self.date_embauche.to_date].max
    elsif self.date_embauche.nil? and !premiere_mariage.nil?
      self.date_ouverture = [self.date_reception.last_year.to_date, premiere_mariage.to_date].max
    else
      self.date_ouverture = self.date_reception.last_year.to_date
    end

    if self.date_ouverture == self.date_reception.last_year.to_date
      self.date_ouverture = self.date_reception.last_year.beginning_of_month.to_date
    end
  end

  def valider_document?
    self.documents.length > 0
  end

  def searched_allocations_can_be_liquided?(allocations)
    complete = true
    allocations.each do |allocation|
      if !allocation.document_valid
        complete = false
      end
    end
    complete
  end

  def has_valid_allocations?(allocations)
    check = false
    allocations.creation.each do |allocation|
      if allocation.document_valid
        check = true
      end
    end
    check
  end

  def number_allocations_valid(allocations)
    allocations.creation.where(document_valid: true).count
  end

  def get_amount_af_paid(year, trimester)
    amount = 0
    allocation_familiales.where(annee: year, trimestre: trimester, etat: [:creation, :soumis, :valide, :echu]).each do |af|
      amount += af.montant_a_payer
    end
    amount
  end

  def get_amount_af_to_pay(year, trimester)
    (get_number_month_af_to_regularize(year, trimester) * 2600)
  end

  def get_amount_af_to_regularize(year, trimester)
    get_amount_af_to_pay(year, trimester) - get_amount_af_paid(year, trimester)
  end

  def get_number_month_af_to_regularize(year, trimester)
    nb_month = 18
    carrier = carriere_dossier_prestations.find_by(annee: year, trimestre: trimester)
    if carrier.infos_jour?
      if carrier.premier_mois < 18 && carrier.est_justifier == false
        nb_month -= 6
      end
      if carrier.deuxiem_mois < 18 && carrier.est_justifier_mois2 == false
        nb_month -= 6
      end
      if carrier.troisiem_mois < 18 && carrier.est_justifier_mois3 == false
        nb_month -= 6
      end
    else
      if carrier.premier_mois < 120 && carrier.est_justifier == false
        nb_month -= 6
      end
      if carrier.deuxiem_mois < 120 && carrier.est_justifier_mois2 == false
        nb_month -= 6
      end
      if carrier.troisiem_mois < 120 && carrier.est_justifier_mois3 == false
        nb_month -= 6
      end
    end
    nb_month
  end

  def individual_regularisation_generate_allocation(enfant, quarter, year)
    carrier = carriere_dossier_prestations.find_by(annee: year, trimestre: quarter)
    date = Date.new(year, quarter * 3, 19)
    allocation = AllocationFamiliale.new
    allocation.enfant_id = enfant.id
    allocation.dossier_prestation_id = self.id
    allocation.trimestre = quarter
    allocation.annee = year
    allocation.date_ouverture_droit = Date.today
    allocation.date_reception = carrier.date_document
    allocation.ajoute_par = User.current
    allocation.etat = :creation
    allocation.date_debut_validite = date
    allocation.date_fin_validite = date.end_of_month + 1.year
    allocation.admin_agence = User.current.agence
    allocation.echeance_caisse_id = carrier.echeance_caisse_id unless carrier.echeance_caisse_id.nil?
    allocation.echeance_caisse_lot_liquidation_id = carrier.echeance_caisse_lot_liquidation_id unless carrier.echeance_caisse_lot_liquidation_id.nil?
    allocation.is_from_ech_paid = true unless carrier.echeance_caisse_id.nil?
    puts 'error', allocation.errors.full_messages unless allocation.save
  end

  def has_paid_allocations_f?(year, quarter)
    check = false
    paid_allocations = allocation_familiales.where(annee: year, trimestre: quarter, paiement: true)
    unless paid_allocations.count == 0
      check = true
    end
    check
  end

  def can_cloture?
    valide? and User.current.gestionnaire_compte_allocataire?
  end

  def create_cloture_request
    request = DemandePfCloture.new
    request.admin_agence = User.current.agence
    request.workflow_state = :soumis
    request.dossier_prestation = self
    request.soumis_par = User.current
    request.save
  end

  def has_cloture_request?
    demande_pf_clotures.where(workflow_state: [:soumis]).length > 0
  end

  def has_rejected_cloture_request?
    demande_pf_clotures.length > 0 and demande_pf_clotures.order('created_at DESC').first.rejete?
  end

  def get_cloture_request
    demande_pf_clotures.where(workflow_state: [:soumis]).order('created_at DESC').first
  end

  def get_rejected_cloture_request
    demande_pf_clotures.where(workflow_state: [:rejete]).order('created_at DESC').first
  end

  def set_as_agent_chosen(id)
    self.affecte_a_id = id
    self.save
  end

  def is_not_agent_chosen_anymore(id)
    self.affecte_a_id = nil
    self.save
  end

  def is_set_manager(id)
    User.find(id) == self.affecte_a
  end

  def is_dead_salary?
    suspendu? and DecesSalarie.where(numero_affiliation: num_affiliation).exists?
  end

  def get_date_deces
    if is_dead_salary?
      DecesSalarie.find_by(numero_affiliation: num_affiliation).date_deces
    end
  end

  private

  def set_num_affiliation!
    self.num_affiliation = user.numero_salarie unless user.nil?
  end

  def validate_num_affiliation
    return if num_affiliation.nil? or num_affiliation.empty?
    errors.add(:num_affiliation, "Ce numéro d'affiliation est introuvable") unless Psrm::Participant.where(matric: num_affiliation).exists?
  end

  def set_user!
    self.user = User.find_by(numero_salarie: num_affiliation)
  end

  def set_numero_dossier!
    annee = Date.today.year
    if conjoint_id.nil?
      self.num_dossier = "#{num_affiliation}/#{annee}/DOSSPR0001"
    else
      base_dossier = DossierPrestation.where(num_affiliation: num_affiliation, conjoint_id: nil).order('created_at DESC').first
      if base_dossier.est_repris?
        self.num_dossier = base_dossier.num_dossier
      else
        self.num_dossier = base_dossier.num_dossier.next
      end
    end
  end
end
