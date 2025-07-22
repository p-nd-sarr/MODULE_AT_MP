class AvisTier < ApplicationRecord
  ETAT = {
    creation: 1,
    validation: 2,
    validation_directeur: 3,
    rejeter: 4,
    suspendu: 5,
  }.freeze

  enum etat: ETAT

  TYPE = {
    revision_base_veuve: 1,
    revision_pension_impaye: 2,
    avance_tabaski: 3,
    avance_korite: 4,
    pret_bancaire: 5,
    autre: 6,
  }.freeze

  enum type_operation: TYPE

  belongs_to :allocataire,
             foreign_key: :numero_allocataire,
             primary_key: :numero_allocataire
  belongs_to :ajouter_par, class_name: 'User', foreign_key: :ajouter_par_id, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :gest_allocataire_id, optional: true

  has_and_belongs_to_many :paiement_allocataires, -> { readonly }

  has_one_attached :document

  #validate :validate_montant!, on: :create

  before_create :create_numero_dossier

  after_create :create_revalorisation

  before_create :set_montant_mensuel, :set_montant_restant

  scope :rembourses, -> { where('montant_restant <= ?', 0) }
  scope :non_rembourses, -> { where('montant_restant > ?', 0) }
  scope :a_rembourser, -> { non_rembourses }

  def montant_retenue
    return montant_restant if montant_restant < montant_mensuel
    m = [montant_mensuel, montant_restant].min
    ((m - montant_restant).abs < 500) ? montant_restant : m
  end

  def set_montant_mensuel
    self.montant_mensuel = montant / nombre_echeance
  end

  private

  def create_numero_dossier
    annee = Date.today.year
    prefixe = 'T'
    dernier_dossier_ajoute = AvisTier.where(
      numero_allocataire: numero_allocataire,
    ).order('created_at DESC').first

    if dernier_dossier_ajoute.nil?
      self.numero_dossier = "#{prefixe}/#{numero_allocataire}/#{annee}/01"
    else
      a = dernier_dossier_ajoute.numero_dossier.split('/')
      a[2] = annee
      self.numero_dossier = a.join('/').next
    end
  end

  def set_montant_restant
    self.montant_restant = self.montant
  end

  def create_revalorisation
    (1..nombre_echeance).each do |echeance|
      revaloriser_pension = RevaloriserPension.new
      revaloriser_pension.montant = -montant_mensuel
      revaloriser_pension.type_operation = :a_enlever
      revaloriser_pension.type_revalorisation = :avis_tiers
      revaloriser_pension.date_debut = date_debut + echeance.month
      revaloriser_pension.allocataire = self.allocataire

      revaloriser_pension.save
    end
  end

  def validate_montant!
    if (montant / nombre_echeance) > (allocataire.montant_net / 3)
      errors.add(:nombre_echeance, "Merci d'augmenter le nombre d'échéances.")
    end
  end
end
