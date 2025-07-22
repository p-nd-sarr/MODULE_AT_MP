# frozen_string_literal: true

class AllocationPostnatale < ApplicationRecord
  VOLET = {
    volet4: 4,
    volet5: 5,
    volet6: 6,
    volet7: 7,
    volet8: 8
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

  scope :est_liquide, -> { where(etat: :soumis) }
  scope :non_paye, -> { where(paiement: false) }
  scope :paye, -> { where(paiement: true) }

  has_one_attached :document
  belongs_to :dossier_prestation
  belongs_to :enfant
  belongs_to :user, optional: true
  belongs_to :valide_par, class_name: 'User', optional: true
  belongs_to :traite_par, class_name: 'User', optional: true
  belongs_to :ajoute_par, class_name: 'User'
  belongs_to :ordre_paiement, optional: true
  belongs_to :retourne_par, class_name: 'User', foreign_key: :retourne_par_id, optional: true

  validates :document, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :volet, :enfant_id, :date_accouchement, :date_reception, presence: true
  validate :verif_volet_and_date_accouchement
  validate :verifier_existence_volet4, on: :create, unless: :volet4?
  validate :verifier_doublons_volet, on: :create
  validate :valider_date_visite
  validate :validate_date_reception
  validate :date_ouverture_droit_valid
  #validate :validate_volet_5
  #validate :validate_volet_6
  #validate :validate_volet_7
  #validate :validate_volet_8

  # validates :condition_1, acceptance: {message: 'doit être acceptée'}# :condition_2, :condition_3,
  # validates :condition_1, presence: true, if: :soumis?, on: :create#:condition_2, :condition_3,

  scope :en_attente, -> { where(etat: %i[soumis traitement_en_cours]) }
  scope :visible_for_admins, -> { where(etat: %i[soumis traitement_en_cours valide rejete]) }
  scope :existes, -> { where.not(etat: [:rejete]) }

  before_save :set_montant_paiement_volet4, on: :create or :update
  before_create :set_montant_paiement!
  # before_create :get_amount!
  after_save :generate_compta_transaction
  before_save :set_date_visite_volet4, on: :create or :update
  before_create :verif_date_ouverture_droit

  def traite?
    valide? or rejete?
  end

  def generate_compta_transaction
    return if est_repris?
    return if montant_paiement.nil?
    new_transaction_amount = montant_paiement
    if valide? && traite_par && traite_par.comptable? && !ComptaTransaction.exists?(dossier: self, statut: [:paye, :en_cours])
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
        code_operation: 'PF_APO',
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
        description: "Allocation postnatale #{volet}, enfant : #{enfant.try(:full_name)}",
        id_reel_allocataire: dossier_prestation.num_affiliation,
        nom_reel_allocataire: dossier_prestation.nom,
        prenom_reel_allocataire: dossier_prestation.prenom,
        statut: :en_cours
      )
    end
  end

  def set_montant_paiement!
    self.montant_paiement = 2_250 * if volet4?
                                      6
                                    elsif volet5? #and validate_volet5?
                                      get_month(2, 4, 6)
                                    elsif volet6? #and validate_volet6?
                                      get_month(8, 10, 12)
                                    elsif volet7? #and validate_volet7?
                                      get_month(14, 16, 18)
                                    elsif volet8? #and validate_volet8?
                                      get_month(20, 22, 24)
                                    end
  end

  private

  # @param x, y, z etant les mois requis pour effectuer les visites
  def validate_volet5?
    (date_visite_1 > date_accouchement || date_visite_1 < date_accouchement.end_of_month + 2.months) and
      (date_visite_2 > date_accouchement || date_visite_2 < date_accouchement.end_of_month + 4.months) and
      (date_visite_3 > date_accouchement || date_visite_3 < date_accouchement.end_of_month + 6.months)
  end

  def validate_volet6?
    (date_visite_1 > date_accouchement || date_visite_1 < date_accouchement.end_of_month + 8.months) and

      (date_visite_2 > date_accouchement || date_visite_2 < date_accouchement.end_of_month + 10.months) and

      (date_visite_3 > date_accouchement || date_visite_3 < date_accouchement.end_of_month + 12.months)
  end

  def validate_volet7?
    (date_visite_1 > date_accouchement || date_visite_1 < date_accouchement.end_of_month + 14.months) and

      (date_visite_2 > date_accouchement || date_visite_2 < date_accouchement.end_of_month + 16.months) and

      (date_visite_3 > date_accouchement || date_visite_3 < date_accouchement.end_of_month + 18.months)
  end

  def validate_volet8?
    (date_visite_1 > date_accouchement || date_visite_1 < date_accouchement.end_of_month + 20.months) and

      (date_visite_2 > date_accouchement || date_visite_2 < date_accouchement.end_of_month + 22.months) and

      (date_visite_3 > date_accouchement || date_visite_3 < date_accouchement.end_of_month + 24.months)
  end

  def get_month(x, y, z)
    compteur = 0

    compteur += 2 if date_visite_1? && (date_visite_1 < (enfant.date_naissance + 1.month).end_of_month + x.months)

    compteur += 2 if date_visite_2? && (date_visite_2 < (enfant.date_naissance + 1.month).end_of_month + y.months)

    compteur += 2 if date_visite_2? && (date_visite_3 < (enfant.date_naissance + 1.month).end_of_month + z.months)

    if volet == 'volet5' || volet == 'volet6'
      compteur.to_i
    else
      compteur.to_i / 2
    end
  end

  def verifier_existence_volet4
    migrated_allocation = enfant.allocations_postnatales_migrees.where.not(enfant_id: nil).find_by(volet: 4)
    if not dossier_prestation.allocation_postnatales.volet4.exists?(enfant_id: enfant_id) and migrated_allocation.nil?
      errors.add(:volet, 'Veuillez renseigner le volet 4 pour cet enfant avant de passer au volet saisi')
    end
  end

  def validate_date_reception
    if self.date_reception.nil?
      errors.add(:base, "La date de reception doit être renseignée ! ")
      return
    end
    errors.add(:base, ' La date de réception ne doit pas être postérieur à la date du jour.') if date_reception > Date.today.to_date
  end

  def verifier_doublons_volet
    if volet4? && dossier_prestation.allocation_postnatales.volet4.exists?(enfant_id: enfant_id)
      # unless dossier_prestation.allocation_postnatales.rejete.exists?(enfant_id: enfant_id)
      errors.add(:volet, 'Vous avez déja enregistré le volet 4 pour cet enfant.')
      return
      # end
    end

    if volet5? && dossier_prestation.allocation_postnatales.volet5.exists?(enfant_id: enfant_id)
      errors.add(:volet, 'Vous avez déja enregistré le volet 5 pour cet enfant.')
      return
    end

    if volet6? && dossier_prestation.allocation_postnatales.volet6.exists?(enfant_id: enfant_id)
      errors.add(:volet, 'Vous avez déja enregistré le volet 6 pour cet enfant.')
      return
    end

    if volet7? && dossier_prestation.allocation_postnatales.volet7.exists?(enfant_id: enfant_id)
      errors.add(:volet, 'Vous avez déja enregistré le volet 7 pour cet enfant.')
      return
    end

    if volet8? && dossier_prestation.allocation_postnatales.volet8.exists?(enfant_id: enfant_id)
      errors.add(:volet, 'Vous avez déja enregistré le volet 8 pour cet enfant.')
      nil
    end
  end

  def set_montant_paiement_volet4
    self.montant_paiement = 0 if volet4? && !(self.date_reception.between?(date_accouchement, (date_accouchement + 12.months).end_of_month))
  end

  def verif_date_ouverture_droit
    if created_at < dossier_prestation.date_ouverture
      errors.add(:base, "La date d'ouverture ne peut pas être antérieur à la date de creation")
    end
  end

  def verif_volet_and_date_accouchement

    if volet5? && (((date_accouchement + 6.months).beginning_of_month >= date_reception) && ((date_accouchement + 18.months).end_of_month <= date_reception))
      errors.add(:volet, "Vous ne pouvez déposer une demande pour le volet 5 qu'à partir du 6e mois après accouchement et avant la
                            date de prescription.")
      return
    end

    if volet6? && (((date_accouchement + 12.months).beginning_of_month >= date_reception) && ((date_accouchement + 24.months).end_of_month <= date_reception))
      errors.add(:volet, "Vous ne pouvez déposer une demande pour le volet 6 qu'à partir du 12e mois après accouchement et avant la
                            date de prescription.")
      return
    end

    if volet7? && (((date_accouchement + 18.months).beginning_of_month >= date_reception) && ((date_accouchement + 30.months).end_of_month <= date_reception))
      errors.add(:volet, "Vous ne pouvez déposer une demande pour le volet 7 qu'à partir du 18e mois après accouchement et avant la
                            date de prescription.")
      return
    end

    if volet8? && (((date_accouchement + 24.months).beginning_of_month >= date_reception) && ((date_accouchement + 36.months).end_of_month <= date_reception))
      errors.add(:volet, "Vous ne pouvez déposer une demande pour le volet 8 qu'à partir du 24e mois après accouchement et avant la
                            date de prescription.")
      nil
    end
  end

  def valider_date_visite
    unless volet4?
      if date_visite_1.nil?
        errors.add(:base, ' La date visite 1 doit être renseignée')
        return
      end
      if date_visite_2.nil?
        errors.add(:base, ' La date visite 2 doit être renseignée')
        return
      end
      if date_visite_3.nil?
        errors.add(:base, ' La date visite 3 doit être renseignée')
        return
      end
      if date_visite_1 < date_accouchement || date_visite_2 < date_accouchement || date_visite_3 < date_accouchement
        errors.add(:base, ' Les dates visites doivent être postérieure à la date de naissance')
      end
      if date_visite_1 > Date.today.to_date || date_visite_2 > Date.today.to_date || date_visite_3 > Date.today.to_date
        errors.add(:base, 'Les dates de visites ne doivent pas être postérieure à la date du jour. ')
      end
      if date_visite_1 > date_visite_2 || date_visite_2 > date_visite_3
        errors.add(:base,
                   'La date de la deuxième visite doit être postérieure à la date de la première visite et antérieure à la date de la troisième visite.')
      end
    end
  end

  def validate_volet_5
    errors.add(:base, "La date de la première visite saisie n'est pas valide.") if volet5? and (date_visite_1 < date_accouchement || date_visite_1 > date_accouchement.end_of_month + 2.months)

    errors.add(:base, "La date de la deuxième visite saisie n'est pas valide.") if volet5? and (date_visite_2 < date_accouchement || date_visite_2 > date_accouchement.end_of_month + 4.months)

    errors.add(:base, "La date de la troisième visite saisie n'est pas valide.") if volet5? and (date_visite_3 < date_accouchement || date_visite_3 > date_accouchement.end_of_month + 6.months)
  end

  def validate_volet_6
    errors.add(:base, "La date de la première visite saisie n'est pas valide.") if volet6? and (date_visite_1 < date_accouchement || date_visite_1 > date_accouchement.end_of_month + 8.months)

    errors.add(:base, "La date de la deuxième visite saisie n'est pas valide.") if volet6? and (date_visite_2 < date_accouchement || date_visite_2 > date_accouchement.end_of_month + 10.months)

    errors.add(:base, "La date de la troisième visite saisie n'est pas valide.") if volet6? and (date_visite_3 < date_accouchement || date_visite_3 > date_accouchement.end_of_month + 12.months)
  end

  def validate_volet_7
    errors.add(:base, "La date de la première visite saisie n'est pas valide.") if volet7? and (date_visite_1 < date_accouchement || date_visite_1 > date_accouchement.end_of_month + 14.months)

    errors.add(:base, "La date de la deuxième visite saisie n'est pas valide.") if volet7? and (date_visite_2 < date_accouchement || date_visite_2 > date_accouchement.end_of_month + 16.months)

    errors.add(:base, "La date de la troisième visite saisie n'est pas valide.") if volet7? and (date_visite_3 < date_accouchement || date_visite_3 > date_accouchement.end_of_month + 18.months)
  end

  def validate_volet_8
    errors.add(:base, "La date de la première visite saisie n'est pas valide.") if volet8? and (date_visite_1 < date_accouchement || date_visite_1 > date_accouchement.end_of_month + 20.months)

    errors.add(:base, "La date de la deuxième visite saisie n'est pas valide.") if volet8? and (date_visite_2 < date_accouchement || date_visite_2 > date_accouchement.end_of_month + 22.months)

    errors.add(:base, "La date de la troisième visite saisie n'est pas valide.") if volet8? and (date_visite_3 < date_accouchement || date_visite_3 > date_accouchement.end_of_month + 24.months)
  end

  def set_date_visite_volet4
    if volet4?
      self.date_visite_1 = nil
      self.date_visite_2 = nil
      self.date_visite_3 = nil
    end
  end

  def date_ouverture_droit_valid
    if self.dossier_prestation.date_ouverture.nil?
      errors.add(:base, "La date d'ouverture des droits du dossier pf doit être renseignée ! ")
      return
    end
    if self.dossier_prestation.date_ouverture > self.date_reception
      errors.add(:base, "La date de réception du volet ne peut être antérieur à la date d'ouverture des droits")
    end
  end
end
