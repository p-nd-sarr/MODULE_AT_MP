class Caisse::Paiement < ApplicationRecord
  ETAT = {
    attente_paiement: 1,
    paye: 2,
    decede: 3,
    suspendu: 4,
  }.freeze

  enum etat: ETAT

  SOURCE = {
    prestation: 1,
    cnav: 2,
    retour_impaye_poste: 3,
    autre: 100
  }.freeze

  enum source: SOURCE

  PERIODE = {
    mensuelle: 1,
    bimestrielle: 2,
    trimestrielle: 3,
    immediate: 4,
    annuelle: 5
  }.freeze

  enum periode: PERIODE

  enum mode_paiement: MODE_PAIEMENT

  belongs_to :echeance_paiement, optional: true
  belongs_to :compta_transaction, optional: true
  belongs_to :user, optional: true
  belongs_to :allocataire, foreign_key: :numero_allocataire, primary_key: :numero_allocataire, optional: true

  validates :numero_ordre, uniqueness: true

  def periode_debut
    return nil if annee.nil? or numero_periode.nil? or periode.nil?
    return Date.new(annee, numero_periode, 1).beginning_of_month if mensuelle?
    return Date.new(annee, numero_periode * 2, 1).beginning_of_bimester if bimestrielle?
    return Date.new(annee, numero_periode * 3, 1).beginning_of_quarter if trimestrielle?
    Date.new(annee).beginning_of_year if annuelle?
  end

  def periode_fin
    return nil if annee.nil? or numero_periode.nil? or periode.nil?
    return Date.new(annee, numero_periode, 1).end_of_month if mensuelle?
    return Date.new(annee, numero_periode * 2, 1).end_of_bimester if bimestrielle?
    return Date.new(annee, numero_periode * 3, 1).end_of_quarter if trimestrielle?
    Date.new(annee).end_of_year if annuelle?
  end

  def rendre_impaye!(user)
    return false if attente_paiement?
    return false unless user.admin?

    self.etat = :attente_paiement
    self.marquee_impayee_par_id = user.id
    self.marquee_impayee_le = DateTime.now
    self.save
  end

  def payer!(user, nin)
    return false unless attente_paiement?

    self.etat = :paye
    self.user = user
    self.nin = nin
    self.date_paiement = DateTime.now
    self.save
  end

  def est_decede!(user)
    return false unless attente_paiement?

    self.etat = :decede
    self.user = user
    self.date_paiement = DateTime.now
    self.save
  end
end
