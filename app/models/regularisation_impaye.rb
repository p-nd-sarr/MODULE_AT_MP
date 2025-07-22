class RegularisationImpaye < ApplicationRecord
  ETAT = {
    en_attente: 0,
    rejete: 1,
    valide: 2,
    regularise: 4
  }.freeze

  PERIODE = {
    mensuelle: 1,
    bimestrielle: 2,
    trimestrielle: 3,
    immediate: 4
  }.freeze

  enum periode: PERIODE

  enum etat: ETAT
  belongs_to :allocataire,
             foreign_key: :numero_allocataire,
             primary_key: :numero_allocataire,
             optional: true
  belongs_to :ordre_paiement, optional: true
  belongs_to :regularisation_pension, optional: true, touch: true
  scope :impayes_annules, -> { where(etat: [:annule]) }
  scope :impayes_en_attente, -> { where(etat: [:en_attente]) }
  scope :traites, -> { where(etat: [:valide, :rejete]) }
  scope :non_traites, -> { where(etat: [:en_attente]) }
  
  validates :numero_ordre, uniqueness: true

  def annuler
    return false unless self.en_attente?
    self.etat = :rejete
    #ordre_paiement.rendre_payer
    self.save!
    true
  end

  def valider
    return false unless self.en_attente?
    self.etat = :valide
    self.save!
    true
  end

  def mettre_en_attente
    return false unless self.valide? or self.rejete?
    self.etat = :en_attente
    self.save!
    true
  end
end
