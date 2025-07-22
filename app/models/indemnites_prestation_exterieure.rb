class IndemnitesPrestationExterieure < ApplicationRecord

  include WorkflowActiverecord

  workflow_column :workflow_state_dt

  workflow do
    state :init do
      event :liquider_dt, transition_to: :liquidation
    end

    state :liquidation do
      event :est_dt_valide_par_chef_grp, transition_to: :validation_dt_chef_grp
      event :est_dt_rejrete_par_chef_grp, transition_to: :init
    end

    state :validation_dt_chef_grp do
      event :est_dt_valide_par_chef_sub, transition_to: :validation_dt_chef_sub
      event :est_dt_rejrete_par_chef_sub, transition_to: :init
    end


    state :validation_dt_chef_sub do
      event :est_dt_valide, transition_to: :droit_valide
      event :est_dt_rejrete, transition_to: :droit_rejete
    end

    state :droit_valide
    state :droit_rejete

  end

  before_save :set_date_fin
  after_create :set_associated_children
  after_update :set_associated_children

  scope :en_cours, -> { where(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year)) }
  scope :execute_by_comptable, -> { where(workflow_state_dt: [:validation_dt_chef_sub, :droit_valide, :droit_rejete]) }
  scope :execute_by_chef_groupe_caf, -> { where(workflow_state_dt: [:liquidation, :validation_dt_chef_grp, :validation_dt_chef_sub, :droit_valide, :droit_rejete]) }
  scope :execute_by_chef_subdivision_caf, -> { where(workflow_state_dt: [:validation_dt_chef_grp, :validation_dt_chef_sub, :droit_valide, :droit_rejete]) }

  belongs_to :prestation_exterieure
  belongs_to :liquide_par, class_name: 'User', foreign_key: :liquide_par_id, optional: true
  belongs_to :valide_chef_grp_par, class_name: 'User', foreign_key: :valide_chef_grp_par_id, optional: true
  belongs_to :valide_chef_sub_par, class_name: 'User', foreign_key: :valide_chef_sub_par_id, optional: true
  belongs_to :valide_cpt_par, class_name: 'User', foreign_key: :valide_cpt_par_id, optional: true
  belongs_to :retourne_par, class_name: 'User', foreign_key: :retourne_par_id, optional: true

  has_many :indemnites_prestation_exterieure_assocs, dependent: :destroy

  validates :date_debut, :date_fin,
            presence: true

  validate :date_debut_indemnites
  #validate :date_range_validation
  validate :date_start_validation
  #validate :date_range_exist, on: :create or :update
  #validate :age_enfant_validate
  #validate :date_range_according_to_child_birth_validate
  validate :date_range_according_to_today_validate
  validate :defference_between_year
  validate :does_barem_exist
  validate :check_eligible_childreen

  def can_display(user)
    (liquidation? && user.chef_groupe_caf?) ||
      (validation_dt_chef_grp? && user.chef_subdivision_caf?) ||
      (validation_dt_chef_sub? && user.comptable?)
  end

  def recursive_prev_year(year)
    caf_barems = Admin::CafBareme.where('date_debut_validite <= ?', Date.new(year, 1, 1))
    if caf_barems.length == 0
      return
    end

    caf_bareme = Admin::CafBareme.where(date_debut_validite: Date.new(year, 1, 1)).last
    if caf_bareme.nil?
      return recursive_prev_year(year - 1)
    end

    caf_bareme
  end

  def get_solde
    bareme = recursive_prev_year(self.date_debut.year).nil? ? 0 : recursive_prev_year(self.date_debut.year).montant_indemnites
    montant = (((((self.date_fin.month - self.date_debut.month + 1) * bareme)).to_f) * self.indemnites_prestation_exterieure_assocs.length).ceil
  end

  def check_eligible_childreen
    if eligible_childreen == 0
      errors.add(:base, "Aucun enfant éligible pour cette période !")
    end
  end

  def does_barem_exist
    caf_barems = Admin::CafBareme.where('date_debut_validite <= ?', self.date_debut)
    if caf_barems.length == 0
      errors.add(:base, "Aucun bareme disponible pour cette période !")
    end
  end

  def date_debut_indemnites
    if self.date_debut < ((Date.today - 5.year).beginning_of_year)
      errors.add(:base, "la date de début ne peut être antérieur à la date d'aujourd'hui moins cinq année")
    end
  end


  def date_range_validation
    if self.date_debut == self.date_fin
      errors.add(:base, "Vous devez choisir une intervalle")
    end
  end


  def date_start_validation
    if self.date_debut > self.date_fin
      errors.add(:base, "La date de fin ne peut pas etre antérieure à la date de début")
    end
  end

  def date_range_exist
    set_date_fin
    indemnities = IndemnitesPrestationExterieure.where(prestation_exterieure_id: self.prestation_exterieure_id)
    indemnities.each do |indemnity|
      if (indemnity.date_debut..indemnity.date_fin).cover?(self.date_fin) or (indemnity.date_debut..indemnity.date_fin).cover?(self.date_debut)
        errors.add(:base, "Cette période a déjà été enregistrée pour cette prestation")
        break
      end
    end

  end

  def age_enfant_validate
    if date_debut > caf_enfant.date_naissance + 21.years
      errors.add(:base, "Cette période ne peut etre prise en compte pour cet enfant")
    end
  end

  def date_range_according_to_child_birth_validate
    if date_debut < caf_enfant.date_naissance
      errors.add(:base, "Cette période ne peut etre prise en compte pour cet enfant")
    end
  end

  def date_range_according_to_today_validate
    if date_debut > DateTime.now or date_fin > DateTime.now
      errors.add(:base, "Vous ne pouvez pas saisir une date posterieure à la date d'aujourd'hui")
    end
  end

  def defference_between_year
    if date_debut.year != date_fin.year
      errors.add(:base, "Vous ne pouvez pas choisir une intervalle entre deux années")
    end
  end

  def set_date_fin
    self.date_fin = self.date_fin.change(day: self.date_fin.end_of_month.day)
  end

  def set_associated_children
    return unless init?

    ActiveRecord::Base.transaction do
      # Supprime les anciennes associations
      self.indemnites_prestation_exterieure_assocs.destroy_all

      # Sélectionne les enfants éligibles non présents dans les associations existantes
      eligible_children = current_eligible_children

      # Crée les nouvelles associations en une seule opération
      new_assocs = eligible_children.map do |enfant|
        self.indemnites_prestation_exterieure_assocs.build(caf_enfant_id: enfant.id)
      end

      self.indemnites_prestation_exterieure_assocs.import(new_assocs)
    end
  rescue => e
    Rails.logger.error("Erreur lors de la mise à jour des associations : #{e.message}")
    raise ActiveRecord::Rollback
  end

  def eligible_childreen
    current_eligible_children.size
  end

  def paid_children
    indemnites_prestation_exterieure_assocs.size
  end

  def has_bareme?
    !(recursive_prev_year(self.date_debut.year).nil?)
  end

  private

  # Récupère les IDs des enfants associés à cette période
  def existing_associated_children_ids
    IndemnitesPrestationExterieure
      .where(prestation_exterieure_id: self.prestation_exterieure_id)
      .where.not(id: self.id)
      .where('date_debut <= ? AND date_fin >= ?', self.date_fin, self.date_debut)
      .joins(:indemnites_prestation_exterieure_assocs)
      .pluck('indemnites_prestation_exterieure_assocs.caf_enfant_id')
      .uniq
  end

  def current_eligible_children
    # Récupère les enfants déjà associés à des indemnités chevauchantes
    existing_children_ids = existing_associated_children_ids

    # Sélectionne les enfants éligibles non présents dans les associations existantes
    eligible_children = CafEnfant.active
                                 .eligible_for_caf_by_period(prestation_exterieure, date_debut, date_fin)
                                 .where.not(id: existing_children_ids)
                                 .select { |enfant| enfant.has_document_valid?(date_debut) }
                                 .first(4)
  end

end
