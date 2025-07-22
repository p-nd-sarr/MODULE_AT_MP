class AllocationPrenatale < ApplicationRecord
  VOLET = {
    volet1: 1,
    volet2: 2,
    volet3: 3
  }.freeze

  ETAT = {
    creation: 1,
    soumis: 2,
    traitement_en_cours: 3,
    valide: 4,
    rejete: 5
  }.freeze

  enum etat: ETAT
  enum volet: VOLET

  scope :non_paye, -> { where(paiement: false) }
  scope :paye, -> { where(paiement: true) }

  has_one_attached :document

  belongs_to :dossier_prestation
  belongs_to :user, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :grossesse
  belongs_to :paiement_allocataire, class_name: 'PaiementAllocataire', foreign_key: :paiement_id, optional: true
  belongs_to :ordre_paiement, optional: true

  validates :document, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :volet, :grossesse_id, presence: true

  # validates :condition_1, :condition_2, acceptance: {message: 'doit être acceptée'}
  # validates :condition_1, :condition_2, presence: true, if: :soumis?, on: :create

  validate :verif_volet_and_debut_grossesse, if: :creation?
  validate :verif_date_depot
  validate :verif_date_etablissement
  validate :compared_date_to_date_grossess
  validate :verif_volet, on: :create
  validate :validate_date_reception
  validate :date_ouverture_droit_valid


  scope :en_attente, -> { where(etat: [:soumis, :traitement_en_cours]) }
  scope :visible_for_admins, -> { where(etat: [:soumis, :traitement_en_cours, :valide, :rejete]) }
  scope :existes, -> { where(etat: [:creation, :soumis, :traitement_en_cours, :valide]) }
  scope :est_liquide, -> { where(etat: :soumis) }

  after_save :set_montant_paiement!
  after_save :generate_compta_transaction
  before_create :verif_date_ouverture_droit

  def traite?
    valide? or rejete?
  end

  def generate_compta_transaction
    return if est_repris?
    return if montant_paiement.nil?
    new_transaction_amount = montant_paiement
    if valide? && traite_par and traite_par.comptable? and not ComptaTransaction.exists?(dossier: self, statut: [:paye, :en_cours])
      if ordre_paiement.nil?
        self.ordre_paiement = OrdrePaiement.create(dossier: grossesse.dossier_prestation,
                                                   numero_allocataire: grossesse.dossier_prestation.num_affiliation)
        self.save
      end
      if dossier_prestation.check_if_avis_tiers_exist?
        ech_amount = ordre_paiement.ligne_pf_avis_tier_transaction.montant
        paid_amount = ordre_paiement.ligne_pf_avis_tier_transaction.montant_paye
        remaining_amount = ech_amount - paid_amount
        new_transaction_amount = montant_paiement - remaining_amount
        unless remaining_amount == 0
          next_paid_amount = montant_paiement > remaining_amount ? remaining_amount : montant_paiement
          ordre_paiement.ligne_pf_avis_tier_transaction.update(montant_paye: next_paid_amount)
        end
      end
      return if new_transaction_amount <= 0
      ComptaTransaction.create(
        en_tete: en_tete_comptabilite,
        dossier: self,
        ordre_paiement: ordre_paiement,
        code_operation: 'PF_APR',
        code_classe_evenement: 'LIQUIDATION',
        code_agence_liquidation: traite_par.agence.try(:code_psrm) || 'C_SG', # à définir
        est_attributaire: true,
        numero_allocataire: dossier_prestation.conjoint.try(:numero_piece) || dossier_prestation.num_affiliation,
        nom: dossier_prestation.conjoint.try(:nom) || dossier_prestation.nom,
        prenom: dossier_prestation.conjoint.try(:prenom) || dossier_prestation.prenom,
        adresse: (dossier_prestation.conjoint.nil? ? nil : dossier_prestation.adresse_domicile),
        mode_paiement: :caisse_css,
        code_banque_allocataire: nil,
        numero_compte_allocataire: nil,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: new_transaction_amount,
        code_devise: 'XOF',
        description: "Allocation prénatale #{volet}, grossesse : #{grossesse.date_grossesse.strftime('%d-%m-%Y')}",
        id_reel_allocataire: dossier_prestation.num_affiliation,
        nom_reel_allocataire: dossier_prestation.nom,
        prenom_reel_allocataire: dossier_prestation.prenom,
        statut: :en_cours,
      )
    end
  end

  def set_montant_paiement!
    unless creation?
      self.montant_paiement = 2_250 * if volet1? and date_visite < self.grossesse.date_grossesse.end_of_month + 10.months
                                        2
                                      elsif volet2? and date_visite < self.grossesse.date_grossesse.end_of_month + 10.months
                                        4
                                      elsif volet3? and date_visite < self.grossesse.date_grossesse.end_of_month + 10.months
                                        3
                                      else
                                        0
                                      end
    end
  end

  def date_ouverture_droit_valid
    if dossier_prestation.date_ouverture.nil?
      errors.add(:base, "La date d'ouverture des droits du dossier pf doit être renseignée ! ")
      return
    end
    errors.add(:base, "La date de présentation chez le médecin ne peut être antérieur à la date d'ouverture des droits") if dossier_prestation.date_ouverture > date_visite
  end

  private

  def verif_date_ouverture_droit
    if created_at < self.dossier_prestation.date_ouverture
      errors.add(:base, "La date d'ouverture ne peut pas être antérieur à la date de creation")
    end
  end

  def validate_date_reception
    return if date_reception.nil?

    errors.add(:base, ' La date de réception ne doit pas être postérieur à la date du jour.') if date_reception > Date.today.to_date
  end

  def verif_volet_and_debut_grossesse
    if volet1? and
      (grossesse.date_grossesse + 15.months).end_of_month <= date_reception
      errors.add(:volet, 'Vous ne pouvez plus déposer pour le volet 1 : date dépassée')
      return
    end

    if volet2? and
      grossesse.date_grossesse + 3.months >= date_reception and (grossesse.date_grossesse + 18.months).end_of_month <= date_reception
      errors.add(:volet, "Vous ne pouvez déposer une demande pour le volet 2 qu'à partir du 3e mois de grossesse et avant la
                            date de prescription.")
      return
    end

    if volet3? and
      grossesse.date_grossesse + 6.months >= date_reception and (grossesse.date_grossesse + 20.months).end_of_month <= date_reception
      errors.add(:volet, "Vous ne pouvez déposer une demande pour le volet 3 qu'à partir du 6e mois de grossesse et avant la
                            date de prescription.")
    end

    errors.add(:base, "La date de visite du troisième volet ne doit pas dépasser 8 mois de grossesse") if volet3? and (((date_visite - grossesse.date_grossesse).to_f / 365 * 12).round > 8)
  end

  def verif_date_depot
    dossier_prestation = DossierPrestation.find_by(id: dossier_prestation_id)

    if date_depot > Date.today
      errors.add(:date_depot, ": La date de dépot ne doit pas être postérieur à la date du jour.")
    elsif date_depot < dossier_prestation.created_at.to_date
      errors.add(:base, "La date de dépôt du volet ne doit pas être antérieure à la date création du dossier.")
    elsif date_depot < date_visite
      errors.add(:date_depot, ": La date de dépot ne doit pas être antérieur à la date de l'examen chez le médecin.")
    end

    allocation_prenatales = AllocationPrenatale.where(dossier_prestation_id: dossier_prestation_id)

    allocation_prenatales.each { |allocation_prenatale|
      if allocation_prenatale.volet < self.volet and allocation_prenatale.date_visite > self.date_visite
        errors.add(:base, "La date de présentation chez le médecin du volet précédant ne peut être antérieur à cette date de présentation.")
      end
    }

  end

  def verif_date_etablissement
    # if date_etablissement < date_visite
    #   errors.add(:date_etablissement, ": La date d'établissement ne doit pas être antérieur à la date de visite ou présentaion chez le médecin.")
    # end
  end

  def compared_date_to_date_grossess
    grossesse = Grossesse.find_by(id: grossesse_id)
    return if grossesse.nil?
    if date_depot < grossesse.date_grossesse
      errors.add(:base, " La date de dépot ne doit pas être antérieur à la date de grossesse.")
    end
  end

  def verif_volet
    allocation_prenatales = AllocationPrenatale.joins(:grossesse).where(grossesse_id: self.grossesse_id)

    if allocation_prenatales.pluck(:volet).include? self.volet
      errors.add(:base, " Ce volet existe déja pour cette grossesse.")
    end
  end
end
