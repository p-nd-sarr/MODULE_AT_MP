class BordereauCollectif < ApplicationRecord


  include WorkflowActiverecord


  workflow_column :workflow_state

  workflow do
    state :creation do
      event :est_liquide, transition_to: :liquidation
    end

    state :liquidation do
      event :est_valide_chef_agence, transition_to: :validation_chef_agence
      event :retour_creation, transition_to: :creation
    end

    state :validation_chef_agence do
      event :est_valide_comptable, transition_to: :validation_comptable
      event :retour_liquidation, transition_to: :liquidation

    end

    state :validation_comptable do
      event :retour_validation_chef_agence, transition_to: :validation_chef_agence
    end

  end

  BORDEREAU_TYPE = {
    normal: 1,
    complementaire: 0
  }
  enum bordereau_type: BORDEREAU_TYPE

  before_create :set_numero_dossier!
  after_create :add_associated_salaries

  has_many :bordereau_salaries_assocs
  has_many :carriere_dossier_prestations
  has_many :allocation_familiales
  belongs_to :psrm_employeur, :class_name => 'Psrm::Employeur', :foreign_key => 'employeur_id'
  belongs_to :liquide_par, class_name: 'User', foreign_key: :liquide_par_id, optional: true
  belongs_to :valide_chef_agence_par, class_name: 'User', foreign_key: :valide_chef_agence_par_id, optional: true
  belongs_to :valide_comptable_par, class_name: 'User', foreign_key: :valide_comptable_par_id, optional: true
  has_one_attached :document

  validates :document, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validate :bordereau_exist, on: :create

  scope :workflow_state, ->(etat) { where(workflow_state: etat) }

  def bordereau_exist
    if BordereauCollectif.exists?(employeur_id: self.employeur_id, trimestre: self.trimestre, annee: self.annee, bordereau_type: self.bordereau_type)
      errors.add(:base, "Ce bordereau existe déjà!")
    end

  end

  def is_all_completed?
    complete = true
    salaries = Psrm::Participant.by_bodereau(self)
    salaries.each do |salary|
      if !salary.has_carriere_dossier_prestation?(self)
        complete = false
      end
    end
    unless self.document.attached?
      complete = false
    end
    complete
  end

  def is_bordereau_complete?(salaries, bordereau)
    complete = true
    salaries.each do |salary|
      if !salary.has_carriere_dossier_prestation?(bordereau)
        complete = false
      end
    end
    complete
  end

  def is_bordereau_liquided?(trimestre, annee)
    liquided = true
    @salaries = Psrm::Participant.joins(:bordereau_salaries_assocs).where(bordereau_salaries_assocs: {bordereau_collectif_id: id})
    @salaries.each do |salary|
      salary.enfants.eligible_for_allocation_f.eligible_plus.each do |enfant|
        allocation = enfant.allocation_familiales.where(trimestre: trimestre, annee: annee).first
        unless allocation.nil?
          if !allocation.soumis?
            liquided = false
          end
        end
      end
    end
    liquided
  end

  def is_bordereau_validated?(trimestre, annee)
    validated = true
    @salaries = Psrm::Participant.joins(:bordereau_salaries_assocs).where(bordereau_salaries_assocs: {bordereau_collectif_id: id})
    @salaries.each do |salary|
      salary.enfants.eligible_for_allocation_f.eligible_plus.each do |enfant|
        allocation = enfant.allocation_familiales.where(trimestre: trimestre, annee: annee).first
        unless allocation.nil?
          if !allocation.valide?
            validated = false
          end
        end
      end
    end
    validated
  end

  def get_montant_total(salaries, bordereau)
    montant = 0
    salaries.each do |salary|
      montant += salary.get_montant_allocations_f(bordereau)
    end
    montant
  end

  def assign_params_from_controller(emp_params, salaries_params)
    @employeur = emp_params
    @salaries = salaries_params
  end

  def set_numero_dossier!
    annee = Date.today.year
    fnum = @employeur.fhnum
    employeur = Psrm::Employeur.find_by_fhnum(fnum)
    if BordereauCollectif.exists?(employeur_id: employeur.id)
      dernier_bordereau_ajoute = BordereauCollectif.where(employeur_id: employeur.id).order('created_at DESC').first
      self.numero_bordereau = dernier_bordereau_ajoute.numero_bordereau.next
    else
      numero = "#{fnum}/#{annee}/TRCOL0001"
      self.numero_bordereau = numero
    end
  end

  def add_associated_salaries
    @salaries.each do |salary|
      bordereau_salaries_assoc = BordereauSalariesAssoc.new
      bordereau_salaries_assoc.bordereau_collectif_id = self.id
      bordereau_salaries_assoc.participant_id = salary.matric
      bordereau_salaries_assoc.save
    end
  end

  def has_complementary_bordereau
    BordereauCollectif.exists?(employeur_id: self.employeur_id, trimestre: self.trimestre, annee: self.annee, bordereau_type: :complementaire)
  end

  def has_last_complementary_bordereau_liquided
    elt = BordereauCollectif.where(employeur_id: self.employeur_id, trimestre: self.trimestre, annee: self.annee, bordereau_type: :complementaire).last
    unless elt.nil?
      elt.liquidation? ? true : false
    else
      true
    end
  end

  def liquider
    if self.normal?
      item = self
    else
      item = BordereauCollectif.where(employeur_id: self.employeur_id, trimestre: self.trimestre, annee: self.annee, bordereau_type: :normal).first
    end

    item.allocation_familiales.creation.when_document_valid.each do |allocation|
      allocation.soumis!
      allocation.date_soumission = Date.today
      allocation.date_liquidation = Date.today
      allocation.montant_paiement = allocation.montant_a_payer
      allocation.liquide_par_bordereau = self
      allocation.save
    end

    if self.creation?
      self.est_liquide!
      self.liquide_par = User.current
      self.date_liquidation = Date.today
      self.motif_rejet = nil
      self.save!
    end
  end

end
