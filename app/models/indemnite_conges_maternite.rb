class IndemniteCongesMaternite < ApplicationRecord
  TRANCHE_PAIEMENT = {
    avant_acouchement: 1,
    apres_acouchement: 2,
    apres_reprise: 3,
    tranche_prolongation: 4
  }.freeze

  ETAT = {
    creation: 1,
    soumis: 2,
    traitement_en_cours: 3,
    valide: 4,
    rejete: 5
  }.freeze

  LIEU_ACCOUCHEMENT = {
    senegal: 1,
    hors_senegal: 2
  }.freeze

  enum etat: ETAT
  enum tranche_paiement: TRANCHE_PAIEMENT
  enum lieu_accouchement: LIEU_ACCOUCHEMENT

  scope :est_liquide, -> { where(etat: :soumis) }
  scope :non_paye, -> { where(paiement: false) }
  scope :paye, -> { where(paiement: true) }

  belongs_to :dossier_maternite, class_name: 'DossierMaternite', foreign_key: :dossier_maternite_id
  belongs_to :user, optional: true
  belongs_to :retourne_par, class_name: 'User', foreign_key: :retourne_par_id, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :paiement_allocataire, class_name: 'PaiementAllocataire', foreign_key: :paiement_id, optional: true
  belongs_to :ordre_paiement, optional: true

  has_one_attached :attestation_accouchement
  has_one_attached :certificat_reprise
  has_one_attached :certificat_non_reprise
  has_one_attached :certificat_deces
  has_one_attached :procuration_legalisee
  has_one_attached :certificat_heredite
  has_one_attached :document_cas_force_majeur
  has_one_attached :certificat_medical

  #validate :verif_presciption , if: :soumis?
  validate :verif_tranche1!
  validate :verif_deuxieme_tranche
  validates :attestation_accouchement, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, if: :apres_acouchement?
  validates :certificat_deces, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, if: :decedee?
  validates :procuration_legalisee, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, if: :decedee?
  validates :certificat_heredite, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, if: :decedee?
  validates :document_cas_force_majeur, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, if: :cas_force_majeur?

  validates :certificat_reprise, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, if: -> { (apres_reprise? and not prolongation) or tranche_prolongation? }
  validates :certificat_non_reprise, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, if: -> { apres_reprise? and prolongation? }
  validates :certificat_medical, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }, if: -> { apres_reprise? and prolongation? }

  validates :jours_prolongation, presence: true, if: -> { apres_reprise? and prolongation }
  validates :date_deces, :nom_mandataire, :prenom_mandataire, :nin_mandataire, presence: true, if: :decedee?
  validates :tranche_paiement, presence: true
  validates :date_accouchement, :lieu_accouchement, presence: true, if: :apres_acouchement?
  # validates :tranche_paiement, uniqueness: {
  #   scope: :dossier_maternite,
  #   message: "Vous avez déjà enregistré cette tranche"
  # }, allow_nil: false
  validate :prescription_tranche
  validate :tranche_exists, on: :create
  validate :debut_conges_check, on: :create

  #validates :date_accouchement, presence: true, if: :apres_reprise
  #validates :condition_1, :condition_2, acceptance: {message: 'doit être acceptée'}
  #validates :condition_1, :condition_2, presence: true, if: :soumis?

  scope :en_attente, -> { where(etat: [:soumis, :traitement_en_cours]) }
  scope :visible_for_admins, -> { where(etat: [:soumis, :traitement_en_cours, :valide, :rejete]) }
  #scope :existes, -> { where(etat: [:creation, :soumis, :traitement_en_cours, :valide]) }
  scope :existes, -> { where(etat: [:creation, :soumis, :traitement_en_cours, :valide]) }

  #before_save :set_numero_liquidation!, if: :soumis?

  before_create :date_reprise, if: -> { apres_acouchement? or apres_reprise? or tranche_prolongation? }
  before_create :jr_payes1, if: :avant_acouchement?
  before_create :jr_payes2, if: :apres_acouchement?
  before_create :jr_payes3, if: :apres_reprise?
  before_create :jr_payes4, if: :tranche_prolongation?
  before_create :date_reprise_reelle, if: :apres_reprise? and :prolongation?
  before_create :date_echeance
  #before_create :nbre_jr_repos
  after_save :generate_compta_transaction
  after_save :dates_accouchement_et_date_rep
  after_save :dossier_decedee

  def debut_conges_check
    if dossier_maternite.debut_conges.nil?
      errors.add(:base, "Veuillez renseigner la date de début de congès dans le dossier de maternité.")
    end
  end

  def prescription_tranche
    if soumis? and self.date_echeance + 12.months < Date.today
      errors.add(:base, "le délai de prescription est dépassé.")
    end
  end

  def tranche_exists
    if IndemniteCongesMaternite.where(dossier_maternite_id: self.dossier_maternite.id, tranche_paiement: self.tranche_paiement, etat: [:creation, :soumis, :traitement_en_cours, :valide]).exists?
      errors.add(:base, "Vous avez déjà enregistré cette tranche.")
    end
  end

  def date_reprise
    if apres_acouchement?
      self.date_reprise_service = self.date_accouchement + 56.days
    end
    unless dossier_maternite.date_accouchement_reel.nil?
      self.date_reprise_service = dossier_maternite.date_accouchement_reel + 56.days
      if tranche_prolongation?
        unless dossier_maternite.jours_prolongation.nil?
          self.date_reprise_reelle = dossier_maternite.date_accouchement_reel + 56.days + dossier_maternite.jours_prolongation.days
        end
      end
    end
  end

  def date_reprise_reelle
    unless dossier_maternite.date_accouchement_reel.nil? and not jours_prolongation.nil?
      if apres_reprise? and prolongation?
        self.date_reprise_reelle = dossier_maternite.date_accouchement_reel + 56.days + jours_prolongation.days
      end
    end
  end

  def dates_accouchement_et_date_rep
    if apres_acouchement?
      dossier_maternite.update(date_accouchement_reel: date_accouchement)
    elsif apres_reprise? and not prolongation?
      dossier_maternite.update(date_fin_cong_reel: date_reprise_service - 1.day)
    elsif apres_reprise? and prolongation?
      dossier_maternite.update(date_fin_cong_reel: date_reprise_reelle - 1.day, jours_prolongation: jours_prolongation)
    end
  end

  def dossier_decedee
    if decedee?
      dossier_maternite.update(decedee: true, date_deces: date_deces, nin_mandataire: nin_mandataire, nom_mandataire: nom_mandataire,
                               prenom_mandataire: prenom_mandataire)
    end
  end

  def traite?
    valide? or rejete?
  end

  def calcul_nbre_jr_mois(date)
    if date.month == 2
      if Date.new(date.year).leap?
        29
      else
        28
      end
    else
      date.end_of_month.day;
    end
  end

  #   def date_echeance
  #     self.date_echeance = if avant_acouchement?
  #                            debut_conges + 30.days
  #                          elsif apres_acouchement?
  #                            date_accouchement + 30.days
  #                          elsif apres_reprise?
  #                            unless date_reprise_service.nil?
  #                              date_reprise_service + 30.days
  #                            end
  #                          elsif tranche_prolongation?
  #                            dossier_maternite.date_fin_cong_reel + 1.days
  #                          end
  #   end

  def date_echeance
    self.date_echeance = if avant_acouchement?
                           debut_conges + calcul_nbre_jr_mois(debut_conges).days
                         elsif apres_acouchement?
                           date_conges = dossier_maternite.debut_conges
                           #echéance de la 2e tranche commence le lendemain de l'échéance de la première tranche
                           date_echance1 = date_conges + calcul_nbre_jr_mois(date_conges).days
                           date_echance1 + 30.days
                         elsif apres_reprise?
                           if dossier_maternite.jours_prolongation.nil?
                             date_reprise_service + 1.day unless date_reprise_service.nil?
                           else
                             date_conges = dossier_maternite.debut_conges
                             date_echance2 = date_conges + (calcul_nbre_jr_mois(date_conges) + 30).days
                             date_echance2 + 30.days
                           end
                         elsif tranche_prolongation?
                           dossier_maternite.date_fin_cong_reel + 1.day unless dossier_maternite.date_fin_cong_reel.nil?
                         end
  end

  #   def date_echeance
  #     self.date_echeance = if avant_acouchement?
  #                            #debut_conges + 30.days
  #                            #Date.new(debut_conges.year, debut_conges.month, -1).day
  #                            #nombre_jours_mois = debut_conges.end_of_month.day;
  #                            #nombre_jours = (debut_conges.end_of_month.day - debut_conges.day).to_i
  #                            debut_conges + calcul_nbre_jr_mois(debut_conges).days
  #                          elsif apres_acouchement?
  #                            date_conges = dossier_maternite.debut_conges
  #                            #echéance de la 2e tranche commence le lendemain de l'échéance de la première tranche
  #                            debut = Date.new(date_conges + (calcul_nbre_jr_mois(date_conges) + 1).days)
  #                            #date_accouchement + calcul_nbre_jr_mois(date_accouchement).days
  #                            debut + calcul_nbre_jr_mois(debut).days
  #                          elsif apres_reprise?
  #                            unless date_reprise_service.nil?
  #                              date_reprise_service + calcul_nbre_jr_mois(debut_conges).days
  #                            end
  #                          elsif tranche_prolongation?
  #                            dossier_maternite.date_fin_cong_reel + 1.days
  #                          end
  #   end

  def jr_payes1
    return unless avant_acouchement?

    if dossier_maternite.decedee?
      jrs_avant_deces = (dossier_maternite.date_deces - dossier_maternite.debut_conges).days
      if jrs_avant_deces < 30.days
        self.nbre_jr_payes = jrs_avant_deces
      else
        self.nbre_jr_payes = 30
      end
    else
      self.nbre_jr_payes = 30
    end
    self.num_tranche = 1
  end

  def jr_payes4
    return unless tranche_prolongation?
    tranche3 = dossier_maternite.indemnite_conges_maternites.find_by(tranche_paiement: 3)
    jours_prolongation = dossier_maternite.jours_prolongation.nil? ? tranche3.jours_prolongation : dossier_maternite.jours_prolongation
    return if jours_prolongation.nil?

    if dossier_maternite.decedee?
      date_rep = dossier_maternite.date_accouchement_reel + 56.days
      if dossier_maternite.date_deces > date_rep and dossier_maternite.date_deces < date_rep + jours_prolongation.days
        self.nbre_jr_payes = (dossier_maternite.date_deces - date_rep).days
      else
        self.nbre_jr_payes = jours_prolongation
      end
    else
      self.nbre_jr_payes = jours_prolongation
    end

    self.num_tranche = 4
  end

  def jr_payes2
    if dossier_maternite.subrogation
      duree = (date_accouchement - dossier_maternite.debut_conges).to_i
    else
      if dossier_maternite.debut_conges == dossier_maternite.date_suspension_salaire
        duree = (date_accouchement - dossier_maternite.debut_conges).to_i
      else
        duree = (date_accouchement - dossier_maternite.date_suspension_salaire).to_i
      end
    end

    if dossier_maternite.decedee?
      jrs_vie = (dossier_maternite.date_deces - dossier_maternite.debut_conges).days
      if jrs_vie > 30.days
        duree = jrs_vie
      end
    end

    if (duree >= 42)
      payes2 = 12 + 18
    elsif (duree > 30 and duree <= 42)
      tampon = duree - 30
      x = 30 - tampon
      payes2 = tampon + x
    elsif (duree == 30)
      payes2 = 30
    elsif (duree < 30)
      tampon1 = 30 - duree
      tampon2 = 56 - tampon1 - 30
      if (tampon2 >= 0)
        payes2 = 30
      elsif (tampon2 < 0)
        payes2 = tampon2 + 30
      end
    end

    if apres_acouchement?
      self.nbre_jr_payes = payes2
      self.num_tranche = 2
    end

  end

  def jr_payes3
    return 0 if dossier_maternite.date_accouchement_reel.nil?

    if dossier_maternite.subrogation
      duree = (dossier_maternite.date_accouchement_reel - dossier_maternite.debut_conges).to_i
    else
      if dossier_maternite.debut_conges == dossier_maternite.date_suspension_salaire
        duree = (dossier_maternite.date_accouchement_reel - dossier_maternite.debut_conges).to_i
      else
        duree = (dossier_maternite.date_accouchement_reel - dossier_maternite.date_suspension_salaire).to_i
      end
    end

    if apres_reprise?
      if (duree >= 42)
        payes3 = 56 - 18
      elsif (duree > 30 and duree <= 42)
        tampon = duree - 30
        x = 30 - tampon
        payes3 = 56 - x
      elsif (duree == 30)
        payes3 = 56 - 30
      elsif (duree < 30)
        tampon1 = 30 - duree
        tampon2 = 56 - tampon1 - 30
        if (tampon2 >= 0)
          payes3 = tampon2
        elsif (tampon2 < 0)
          payes3 = 0
        end
      end
      self.nbre_jr_payes = payes3
      if prolongation?
        if nbre_jr_payes > 30
          self.jours_prolongation += (nbre_jr_payes - 30)
          self.nbre_jr_payes = 30
        end
        if nbre_jr_payes < 30
          nb_jr_tr_3 = self.nbre_jr_payes
          self.nbre_jr_payes = self.nbre_jr_payes + self.jours_prolongation > 30 ? 30 : self.nbre_jr_payes + self.jours_prolongation
          self.jours_prolongation = nb_jr_tr_3 + self.jours_prolongation > 30 ? (nb_jr_tr_3 + self.jours_prolongation) - 30 : 0
        end
      end
    end
    self.num_tranche = 3
  end

  def dif
    return 0 if dossier_maternite.date_accouchement_reel.nil?
    duree = (dossier_maternite.date_accouchement_reel - dossier_maternite.debut_conges).to_i + 1

  end

  def montant_paiement
    return if dossier_maternite.salaire_reference.nil? or nbre_jr_payes.nil?
    if dossier_maternite.check_avis_tiers_valide?
      salaire_jour = (dossier_maternite.montant_salaire / 30).to_f
      unless tranche_prolongation?
        if nbre_jr_payes == 30
          montant_paiement = dossier_maternite.montant_salaire
        else
          montant_paiement = (salaire_jour * nbre_jr_payes).round(2)
        end
      else
        montant_paiement = (salaire_jour * nbre_jr_payes).round(2)
      end
    else
      salaire_jour = (dossier_maternite.salaire_reference / 30).to_f
      unless tranche_prolongation?
        if nbre_jr_payes == 30
          montant_paiement = dossier_maternite.salaire_reference
        else
          montant_paiement = (salaire_jour * nbre_jr_payes).round(2)
        end
      else
        montant_paiement = (salaire_jour * nbre_jr_payes).round(2)
      end
    end


  end

  def generate_compta_transaction
    unless traite_par.nil?
      if valide? and traite_par.comptable? and not traite_par.nil? and not ComptaTransaction.exists?(dossier: self, statut: [:paye, :en_cours])
        new_transaction_amount = montant_paiement
        # if dossier_maternite.virement?
        #   vir = :virement
        #   cb = dossier_maternite.compte_bancaire_code_banque
        #   nc = dossier_maternite.rib
        # else
        #   vir = dossier_maternite.mode_paiement
        #   cb = nil
        #   nc = nil
        # end

        # Gestion du trop-perçu
        if dossier_maternite.check_if_avis_tiers_exist?
          ech_amount = ordre_paiement.ligne_icm_avis_tiers_transaction.montant
          already_paid = ordre_paiement.ligne_icm_avis_tiers_transaction.montant_paye
          remaining_amount = ech_amount - already_paid
        
          max_deductible = montant_paiement * 0.25
          deduction_amount = [remaining_amount, max_deductible].min
          new_transaction_amount = montant_paiement - deduction_amount
        
          unless remaining_amount == 0
            new_paid_amount = already_paid + deduction_amount
            ordre_paiement.ligne_icm_avis_tiers_transaction.update(montant_paye: new_paid_amount)
          end
        end

        # Mode de paiement
        payment_mode = new_transaction_amount < 100_000 ? :caisse_css : :cheque
        cb = nil
        nc = nil

        transaction = ComptaTransaction.create(
          dossier: self,
          ordre_paiement: ordre_paiement,
          code_operation: 'PF_IJCM',
          code_classe_evenement: 'LIQUIDATION',
          code_agence_liquidation: traite_par.agence.try(:code_psrm) || 'C_SG', # à définir
          est_attributaire: dossier_maternite.attributaire?,
          par_subrogation: dossier_maternite.subrogation?,
          numero_allocataire: if dossier_maternite.subrogation?
                                dossier_maternite.participant.psrm_employeur.fhnum
                              else
                                dossier_maternite.attributaire? ? dossier_maternite.nin_attributaire : dossier_maternite.num_dossier
                              end,
          nom: if dossier_maternite.subrogation?
                 dossier_maternite.participant.psrm_employeur.fhrsoc
               else
                 dossier_maternite.attributaire? ? dossier_maternite.nom_attributaire : dossier_maternite.nom
               end,
          prenom: dossier_maternite.attributaire? ? dossier_maternite.prenom_attributaire : dossier_maternite.prenom,
          adresse: dossier_maternite.adresse_domicile,
          mode_paiement: payment_mode,
          code_banque_allocataire: cb,
          numero_compte_allocataire: nc,
          bank_id: dossier_maternite.bank_id,
          bank_branch_id: dossier_maternite.bank_branch_id,
          date_debut_periode: nil,
          date_fin_periode: nil,
          montant: new_transaction_amount,
          code_devise: 'XOF',
          description: "Indemnité congés marternité. Allocataire : #{dossier_maternite.num_dossier}",
          id_reel_allocataire: dossier_maternite.attributaire? ? dossier_maternite.num_dossier : nil,
          nom_reel_allocataire: dossier_maternite.attributaire? ? dossier_maternite.nom : nil,
          prenom_reel_allocataire: dossier_maternite.attributaire? ? dossier_maternite.prenom : nil,
          statut: :en_cours,
        )

        if transaction.persisted? && dossier_maternite.check_if_avis_tiers_exist?
          avis_tiers = dossier_maternite.get_avis_tiers
          if avis_tiers.montant_avis == avis_tiers.get_amount_paid
             avis_tiers.update_column(:status, DossierMaterniteAvisTier.statuses['paye'])
          end
        end
      end
    end
  end

  private

  def verif_tranche1!
    if avant_acouchement?
=begin
      unless dossier_maternite.debut_conges.nil?
        if dossier_maternite.debut_conges + 30.days > Date.today
          errors.add(:tranche_paiement, 'La première tranche est déposée 30jours apres le début de congès')
          return
        end
      end
=end
    end

    if apres_acouchement?
      unless date_accouchement.nil?
        unless dossier_maternite.debut_grossesse.nil?
          if dossier_maternite.debut_grossesse + 5.months > date_accouchement
            errors.add(:date_accouchement, "La durée de la grossesse doit etre supérieure à 5 mois.  (#{I18n.l(dossier_maternite.debut_grossesse)}) -  (#{I18n.l(date_accouchement)})")
            return
          end
        end

        unless dossier_maternite.debut_conges.nil?
          if dossier_maternite.debut_conges > date_accouchement
            errors.add(:date_accouchement, "La date d’accouchement ne doit pas être antérieure à la date de départ en congés :  #{I18n.l(date_accouchement)}.")
            return
          end
        end
      end
    end
  end

  def verif_deuxieme_tranche
    if apres_acouchement?
      if dossier_maternite.date_suspension_salaire.nil? and not dossier_maternite.subrogation?
        errors.add(:tranche_paiement, "Veuillez renseigner la date de suspension de salaire dans le dossier de maternité")
      end
      unless date_accouchement.nil? or dossier_maternite.date_suspension_salaire.nil?
        if self.date_accouchement < dossier_maternite.date_suspension_salaire
          errors.add(:tranche_paiement, "La date de suspension de salaire ne peut pas être antérieure à la date d'accouchement")
        end
      end
    end
    # if apres_reprise?
    #   unless dossier_maternite.indemnite_conges_maternites.apres_acouchement.exists?
    #     errors.add(:tranche_paiement, "Veuillez d'abord renseigner la deuxième tranche")
    #   end
    # end
  end

  def verif_presciption
=begin
    if avant_acouchement?
      if debut_conges + 12.months <= Date.today
        errors.add(:tranche_paiement, " Début congés: #{I18n.l(date_accouchement)} - Délai de prescription dépassé.")
        return
      end
    end

    if apres_acouchement?
      unless date_accouchement.nil?
        if date_accouchement + 12.months <= Date.today
          errors.add(:date_accouchement, " : #{I18n.l(date_accouchement)} - Délai de prescription dépassé.")
          return
        end
        if date_accouchement > Date.today
          errors.add(:date_accouchement, " : #{I18n.l(date_accouchement)} ne doit pas être postérieure à la date du jour.")
          return
        end
      end
    end

    if apres_reprise?
      unless dossier_maternite.date_accouchement_reel.nil?
        reprise = dossier_maternite.date_accouchement_reel + 56.days
        if reprise + 12.months <= Date.today
          errors.add(:tranche_paiement, 'Le délai de prescription dépassé.')
          return
        end
      end
    end
=end

    unless date_echeance.nil?
      if date_echeance + 12.months < Date.today
        if avant_acouchement?
          errors.add(:tranche_paiement, " Début congés: #{I18n.l(debut_conges)} - Le délai de prescription est dépassé.")
          return
        end

        if apres_acouchement?
          unless date_accouchement.nil?
            errors.add(:date_accouchement, " : #{I18n.l(date_accouchement)} - Le délai de prescription est dépassé.")
          end
        end

        if apres_reprise?
          errors.add(:tranche_paiement, 'Le délai de prescription est dépassé.')
          return
        end

        if tranche_prolongation?
          errors.add(:tranche_paiement, 'Le délai de prescription est dépassé.')
          return
        end

      end
    end

    if apres_acouchement?
      unless date_accouchement.nil?
        if date_accouchement > Date.today
          errors.add(:date_accouchement, " : #{I18n.l(date_accouchement)} ne doit pas être postérieure à la date du jour.")
          return
        end
      end
    end

  end

  def set_numero_liquidation!
    annee = Date.today.year
    nbreLiq = IndemniteCongesMaternite.soumis.count
    if IndemniteCongesMaternite.exists?(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year))
      derniere_tranche_ajoute = IndemniteCongesMaternite.where(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year)).order('created_at DESC').first
      self.numero_liquidation = derniere_tranche_ajoute.numero_liquidation.next
    else
      self.numero_liquidation = "#{dossier_maternite.num_affiliation}/#{annee}/LiquidICM001"
    end
  end
end
