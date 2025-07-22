class PaiementAllocataire < ApplicationRecord
  ETAT = {
      en_attente_paiement: 0,
      paye: 1,
      rejete: 2,
      retourne: 3,
      en_attente_validation_instruction: 10,
  }.freeze

  enum etat: ETAT

  PERIODE = {
      mensuelle: 1,
      bimestrielle: 2,
      trimestrielle: 3,
      immediate: 4
  }.freeze

  enum periode: PERIODE

  enum mode_paiement: MODE_PAIEMENT

  TYPE_CATEGORIE = Allocataire::TYPE_CATEGORIE.freeze

  enum categorie: TYPE_CATEGORIE

  TYPE_PAIEMENT = {

  }.freeze

  enum type_paiement: TYPE_PAIEMENT

  belongs_to :dossier_prestation, class_name: 'DossierPrestation', foreign_key: :numero_allocataire, primary_key: :num_affiliation, optional: true
  belongs_to :dossier_maternite, class_name: 'DossierMaternite', foreign_key: :numero_allocataire, primary_key: :num_affiliation, optional: true
  belongs_to :allocataire, class_name: 'Allocataire', foreign_key: :numero_allocataire, primary_key: :numero_allocataire, optional: true
  belongs_to :echeance_paiement, optional: true
  has_and_belongs_to_many :pret_allocataire_lignes
  has_and_belongs_to_many :avis_tiers
  scope :retournes, -> { where(etat: [:retourne]) }

  before_save :set_numero_paiement!, :set_code!

  def set_numero_paiement!
    #self.numero_paiement = rand.to_s[2..5]
    #set_numero_paiement! if PaiementAllocataire.find_by(numero_paiement: numero_paiement)
  end

  def set_code!
    #self.code = rand.to_s[2..5]
    #set_code! if PaiementAllocataire.find_by(code: code)
  end
end
