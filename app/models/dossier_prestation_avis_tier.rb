class DossierPrestationAvisTier < ApplicationRecord

  ETAT = {
    creation: 1,
    soumis: 2,
    valide: 3
  }.freeze

  TYPE_AVIS = {
    trop_percu: 1,
    moins_percu: 2
  }.freeze

  NATURE_AVIS = {
    af: 1,
    post: 2,
    pre: 3
  }.freeze

  STATUS = {
    paye: 1,
    non_paye: 2
  }.freeze

  VOLET_POST = {
    volet4: 4,
    volet5: 5,
    volet6: 6,
    volet7: 7,
    volet8: 8
  }.freeze

  VOLET_PRE = {
    volet1: 1,
    volet2: 2,
    volet3: 3
  }.freeze

  TRIMESTRE = {
    trimestre1: 1,
    trimestre2: 2,
    trimestre3: 3,
    trimestre4: 4
  }.freeze

  enum type_avis: TYPE_AVIS
  enum nature_avis: NATURE_AVIS
  enum etat: ETAT
  enum status: STATUS
  enum volet_post: VOLET_POST
  enum volet_pre: VOLET_PRE
  enum trimestre: TRIMESTRE

  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajouter_par_id, optional: true
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true
  belongs_to :valide_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
  belongs_to :retourne_par, class_name: 'User', foreign_key: :retourner_par_id, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :dossier_prestation, foreign_key: :dossier_prestation_id
  belongs_to :enfant, foreign_key: :enfant_id, optional: true
  belongs_to :conjoint, foreign_key: :conjoint_id, optional: true

  has_many :ligne_pf_avis_tier_transactions, foreign_key: :dossier_prestation_avis_tiers_id
  has_many :compta_transactions, through: :ordre_paiements

  validates :montant_echeance, :montant_avis, presence: true
  validate :check_deadline_amount

  def check_deadline_amount
    if montant_echeance > montant_avis
      errors.add(:base, "Montant avis doit être supérieur à montant échéance!")
    end
    if montant_avis % montant_echeance != 0
      errors.add(:base, "Montant avis doit être un multiple de montant échéance!")
    end
  end

  def get_amount_paid
    ligne_pf_avis_tier_transactions.sum(:montant)
  end

  def remaining_amount
    montant_avis - get_amount_paid
  end

  def attente_paiement?
    valide? and non_paye? and moins_percu?
  end

  def valider_paiement(user)
    return if montant_avis.nil?

    self.traite_par = User.current
    self.traite_le = Date.today
    op = OrdrePaiement.create(dossier: dossier_prestation, numero_allocataire: dossier_prestation.num_affiliation)
    amount = remaining_amount

    if valide? and traite_par.comptable? and not ComptaTransaction.exists?(dossier: self) and not LignePfAvisTierTransaction.exists?(ordre_paiement: op)
      li = LignePfAvisTierTransaction.new
      li.dossier_prestation_avis_tier = self
      li.ordre_paiement = op
      li.montant = montant_avis
      li.montant_paye = montant_avis
      li.ajoute_par = User.current
      puts 'error', li.errors.full_messages unless li.save

      ComptaTransaction.create(
        en_tete: true,
        dossier: self,
        ordre_paiement: op,
        code_operation: 'PF_AVIS',
        code_classe_evenement: 'LIQUIDATION',
        code_agence_liquidation: traite_par.agence.try(:code_psrm) || 'C_SG', # à définir
        numero_allocataire: dossier_prestation.num_affiliation,
        nom: dossier_prestation.nom,
        prenom: dossier_prestation.prenom,
        adresse: (dossier_prestation.adresse_domicile),
        mode_paiement: :caisse_css,
        code_banque_allocataire: nil,
        numero_compte_allocataire: nil,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: amount,
        code_devise: 'XOF',
        statut: :en_cours,
        description: "Avis à tiers numéro liquidation #{numero_liquidation}",
      )

      self.status = DossierPrestationAvisTier.statuses['paye']
      self.save
    end

    true
  end

end
