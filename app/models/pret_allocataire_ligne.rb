class PretAllocataireLigne < ApplicationRecord
  belongs_to :pret_allocataire, optional: true

  belongs_to :allocataire,
             foreign_key: :numero_allocataire,
             primary_key: :numero_allocataire

  has_and_belongs_to_many :paiement_allocataires, -> { readonly }

  REGIME = Allocataire::REGIME.freeze

  enum regime: REGIME

  before_create :set_values!
  after_create :create_allocataire_suivi!

  scope :rembourses, -> { where(montant_restant: 0) }
  scope :non_rembourses, -> { where("montant_restant > ?", 0) }
  scope :non_verses, -> { where(est_verse: false) }
  scope :a_rembourser, -> { non_rembourses.where("date_debut <= ?", Date.today) }

  def montant_retenue
    return montant_restant if montant_restant < montant_mensuel
    m = [montant_mensuel, montant_restant].min
    ((m - montant_restant).abs < 1_000) ? montant_restant : m
  end

  def echeances_restants
    montant_restant > 0 ? (1.0 * montant_restant / montant_mensuel).round : 0
  end

  def date_fin_previsionnelle
    echeances_restants.zero? ? date_dernier_prelevement : (Date.today + echeances_restants.months).end_of_month
  end

  # def updates_values
  #   montant_brut_rg = allocataire.montant_brut_rg || 0.0
  #
  #   if allocataire.general?
  #     # regime general montant = 60.000
  #     self.montant = [montant_brut_rg, 60_000].min
  #     self.regime = :general
  #   elsif allocataire.cadre?
  #     # regime cadre montant = 100.000
  #     self.montant = [montant_brut_rg, 100_000].min
  #     self.regime = :cadre
  #   elsif allocataire.employe_de_maison?
  #     # regime REM montant = 60.000
  #     self.montant = [montant_brut_rg, 60_000].min
  #     self.regime = :employe_de_maison
  #   end
  #
  #   self.montant_mensuel = self.montant / 9
  #   self.montant_restant = self.montant - self.montant_mensuel
  #   self.save
  # end

  private

  def set_values!
    montant_brut_rg = allocataire.montant_brut_rg || 0.0

    if allocataire.general?
      # regime general montant = 60.000
      self.montant = [montant_brut_rg, 60_000].min
      self.regime = :general
    elsif allocataire.cadre?
      # regime cadre montant = 100.000
      self.montant = [montant_brut_rg, 100_000].min
      self.regime = :cadre
    elsif allocataire.employe_de_maison?
      # regime REM montant = 60.000
      self.montant = [montant_brut_rg, 60_000].min
      self.regime = :employe_de_maison
    end

    self.montant_mensuel = self.montant / 9
    self.montant_restant = self.montant
  end

  def create_allocataire_suivi!
    AllocataireSuiviModification.create(allocataire: self.allocataire,
                                        commentaire: "Pret allocataire numero allocataire #{self.numero_allocataire} ##{self.id}",
                                        date_validation: pret_allocataire.validation_date,
                                        dossier_revision: self,
                                        impacte_montant_paiement: true)
  end
end
