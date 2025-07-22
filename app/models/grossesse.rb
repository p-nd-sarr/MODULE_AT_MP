class Grossesse < ApplicationRecord
  ETAT = {
      valide: 1,
      avortement: 2,
      fausse_couche: 3
  }.freeze

  enum etat: ETAT

  belongs_to :dossier_prestation
  has_many :allocation_prenatales, dependent: :destroy

  validates :etat, :date_grossesse, presence: true
  validates :date_grossesse, uniqueness: { scope: :dossier_prestation, message: 'Cette date est déjà ajoutée sur ce dossier' }

  validate :validate_date_grossesse!
  validate :date_debut_after_current_date
  validate :valider_grossesse, on: :create
  validate :valider_date_interruption_grossesse, on: :update
  validate :date_debut_grossesse_after_chomage

  def date_debut_grossesse_after_chomage
    dossier_prestation = DossierPrestation.where(num_affiliation: self.dossier_prestation.num_affiliation, conjoint_id: nil).first
    maintien = dossier_prestation.maintien_prestations.where(maintien_prestations: { etat: MaintienPrestation.etats[:actif] }).first

    unless maintien.nil?
      if self.date_grossesse > maintien.date_arret_activite
        errors.add(:date_grossesse, "Ne peut pas être postérieure à la date d'effet du chômage involontaire")
      end
    end
  end

  def date_debut_after_current_date
    return if date_grossesse.blank?

    if date_grossesse > Date.today
      errors.add(:date_grossesse, "Ne peut pas être postérieure à la date du jour")
    end
  end

  def a_terme?
    date_grossesse + 9.months <= Date.today
  end

  def nom
    "Debut grossesse : #{I18n.l date_grossesse}"
  end

  def peut_prendre_volets?
    not volets_eligibles.empty?
  end

  def volets_eligibles_update
    return {} unless valide?

    volets = {
      volet1: 1,
      volet2: 2,
      volet3: 3
    }

    unless Date.today <= date_grossesse + 15.months
      volets.except!(:volet1)
    end

    unless date_grossesse + 3.months <= Date.today and Date.today <= date_grossesse + 18.months
      volets.except!(:volet2)
    end

    unless date_grossesse + 6.months <= Date.today and Date.today <= date_grossesse + 20.months
      volets.except!(:volet3)
    end

    volets
  end

  def volets_eligibles
    return {} unless valide?

    volets = {
      volet1: 1,
      volet2: 2,
      volet3: 3
    }

    volets.except!(:volet1) unless allocation_prenatales.volet1.existes.empty?
    volets.except!(:volet2) unless allocation_prenatales.volet2.existes.empty?
    volets.except!(:volet3) unless allocation_prenatales.volet3.existes.empty?

    # unless Date.today <= (date_grossesse + 15.months).end_of_month
    #   volets.except!(:volet1)
    # end
    #
    # unless date_grossesse + 3.months <= Date.today and Date.today <= (date_grossesse + 18.months).end_of_month
    #   volets.except!(:volet2)
    # end
    #
    # unless date_grossesse + 6.months <= Date.today and Date.today <= (date_grossesse + 20.months).end_of_month
    #   volets.except!(:volet3)
    # end

    volets
  end

  def can_not_edit_or_destroyed?
    AllocationPrenatale.where(grossesse_id: self.id).exists?
  end
  def can_be_interrupted?
    self.date_grossesse + 9.months > Date.today
  end

  private

  def validate_date_grossesse!
    return if date_grossesse.nil?
    return if dossier_prestation.conjoint.nil?

    date_mariage = dossier_prestation.conjoint.date_mariage

    if date_grossesse.next_month(9).to_time < date_mariage
      errors.add(:date_grossesse, "Ne peut pas être antérieure à la date du mariage (#{I18n.l(date_mariage)})")
    end

    if date_grossesse >= Date.today
      errors.add(:date_grossesse, "Ne peut pas être postérieure à la date du jour (#{I18n.l(Date.today)})")
    end
  end

  def valider_grossesse
    date_grossesses = Grossesse.valide.where(dossier_prestation_id: dossier_prestation_id).pluck(:date_grossesse)

    date_grossesses.each { |date|
      if ( (date_grossesse.year * 12 + date_grossesse.month) - (date.year * 12 +  date.month) < 11 )
        errors.add(:base, 'Il y\' a une grossesse en cour.')
      end
    }

  end

  def valider_date_interruption_grossesse
    if date_interruption?
      if date_interruption > Date.today
        errors.add(:base, "La date d'interruption ne peut être supérieur à la date du jour.")
        elsif date_interruption > date_grossesse + 1.year
        errors.add(:base, "La date renseignée n’est pas valide : plus d’un an depuis le début de la grossesse")
      end
    end
  end

end
