class MaintienPrestation < ApplicationRecord

  TYPE_MAINTIEN = {
      chomage: 1,
      deces: 2
  }.freeze

  ETAT = {
      actif: 1,
      inactif: 0
  }.freeze

  enum etat: ETAT
  enum type_maintien: TYPE_MAINTIEN

  after_create :set_allocations_familiales
  after_update :set_allocations_f_inactive
  after_create :set_maintien_active
  after_create :set_date_arret_activite
  after_destroy :delete_associated_allocations

  belongs_to :dossier_prestation, :foreign_key => 'dossier_prestations_id', :primary_key => 'id'
  has_many :allocation_familiales
  has_one_attached :document_justificatif
  has_one_attached :autre_document

  validates :dossier_prestations_id, :date_demande_maintien, :commentaire, :date_effective,
            presence: true
  validates :document_justificatif, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, presence: true #, attached: true
  validates :autre_document, content_type: { in: 'application/pdf', message: "n'est pas un PDF" } #, presence: true #, attached: true
  #validate :date_deces_exist, on: :create
  validate :death_of_salary
  validate :can_not_chomage

  def has_dead_salary?
    !self.get_dead_salary.nil?
  end

  def get_dead_salary
    salary = self.dossier_prestation.participant
    dead_salary = DecesSalarie.where(numero_affiliation: salary.matric).first
  end

  def death_of_salary
    if !self.has_dead_salary? and deces?
      errors.add(:base, "Veuillez déclarer le décès de l'allocataire dans le système")
    end
  end

  def date_deces_exist
    if chomage? and !date_deces.nil?
      errors.add(:base, "Date décès ne doit pas exister.")
    end
  end

  def can_not_chomage
    if self.chomage? and self.has_dead_salary?
      errors.add(:base, "Un salarié décédé ne peut pas aller au chômage.")
    end
  end

  def set_date_arret_activite
    period = self.get_first_period
    self.date_arret_activite = set_current_date(period[0], period[1]) - 3.month
    self.save
  end

  def get_time_of_presence_continu
    (self.date_arret_maintien.year * 12 + self.date_arret_maintien.month) - (self.date_arret_activite.year * 12 + self.date_arret_activite.month)
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

  def get_first_period
    date_eff = self.date_effective
    annee = date_eff.year
    trimestre = find_quarter(date_eff.month)

=begin
    last_alloc = self.dossier_prestation.carriere_dossier_prestations.order(:annee).order(:trimestre).last
    annee = last_alloc.annee
    trimestre = last_alloc.read_attribute_before_type_cast(:trimestre)
=end

    if (trimestre === 1)
      [2, annee]
    elsif (trimestre === 2)
      [3, annee]
    elsif (trimestre === 3)
      [4, annee]
    elsif (trimestre === 4)
      [1, annee +1]
    end

  end

  def get_next_period(period)
    period[0] = period[0] + 1

    if period[0] > 4
      period[0] = 1
      period[1] = period[1] + 1
    end

    period
  end

  def get_last_month_of_trimestre(trimestre)
    3 * trimestre.to_i
  end

  def get_first_month_of_trimestre(trimestre)
    (3 * trimestre.to_i) - 2
  end

  def set_current_date(trimestre, annee)
    month = get_last_month_of_trimestre(trimestre)
    date = Date.new(annee, month, 1)
    date = date.change(day: date.end_of_month.day)
    date
  end

  def number_of_month_presence
    nombre_mois_presence = 3 * (self.dossier_prestation.carriere_dossier_prestations.size)
  end

  def set_allocations_familiales
    return if deces?
    dossier_prestation = self.dossier_prestation
    participant = dossier_prestation.participant
    date_demande = self.date_demande_maintien
    date_arret = self.date_arret_maintien
    period = self.get_first_period
    date_eff = self.date_effective
    annee = date_eff.year
    trimestre = find_quarter(date_eff.month)

    return if date_arret.nil?

    nb_month = (date_arret.year * 12 + date_arret.month) - (set_current_date(trimestre, annee).year * 12 + set_current_date(trimestre, annee).month)

    nb_month.step(0, -3) do |i|
      current_date = set_current_date(period[0], period[1])
      date = Date.new(current_date.year, current_date.month, 1)

      if i == 0
        break
      end


      participant.enfants.eligible_for_alloc_familiale(current_date, participant.matric).eligible_plus.each do |enfant|
        allocation = AllocationFamiliale.new
        allocation.enfant_id = enfant.id
        allocation.dossier_prestation_id = dossier_prestation.id
        allocation.trimestre = period[0]
        allocation.annee = period[1]
        allocation.date_ouverture_droit = Date.today
        allocation.ajoute_par = User.current
        allocation.etat = :creation
        allocation.date_debut_validite = date.at_beginning_of_month.next_month
        allocation.date_fin_validite = date.end_of_month + 1.year
        allocation.maintien_prestation_id = self.id
        allocation.admin_agence = User.current.try(:agence) or dossier_prestation.try(:admin_agence)
        normal_amount = allocation.reinitialize_amount
        maintien_amount = i < 3 ? 2600 * i : 2600 * 3

        if normal_amount < maintien_amount
          allocation.montant_paiement = normal_amount
        else
          allocation.montant_paiement = maintien_amount
        end

        allocation.save(validate: false)
        puts 'error', allocation.errors.full_messages unless allocation.save
      end

      period = get_next_period(period)
    end
  end

  def set_allocations_f_inactive
    if self.inactif?
      start_period = self.get_first_period
      given_allocs = self.allocation_familiales.where('(trimestre >= ? and annee >= ?) or annee > ?', start_period[0], start_period[1], start_period[1]).where(etat: :creation)
      given_allocs.update_all(etat: :suspendu)
    end
  end

  def delete_associated_allocations
    self.allocation_familiales.destroy_all
  end

  def set_maintien_active
    self.actif!
  end

end