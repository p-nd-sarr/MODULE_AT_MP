class AllocationFamiliale < ApplicationRecord
  include Documentable

  TRIMESTRE = {
    trimestre1: 1,
    trimestre2: 2,
    trimestre3: 3,
    trimestre4: 4
  }.freeze

  ETAT = {
    creation: 1,
    soumis: 2,
    traitement_en_cours: 3,
    valide: 4,
    rejete: 5,
    suspendu: 6,
    echu: 7
  }.freeze

  MOTIF_REJET = {
    motif1: 1,
    motif2: 2,
    motif3: 3
  }

  TYPE_DOCUMENT_OBLIGATOIRE = {

  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      # certificat_medical: 19,
      certificat_scolarite: 36,
      certificat_apprentissage: 67,
      certificat_infirmite: 66
    }
  ).freeze

  TYPE_DOCUMENT_1 = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      certificat_medical: 19,
      certificat_scolarite: 36
    }
  ).freeze

  enum etat: ETAT
  enum trimestre: TRIMESTRE
  enum motif_rejet: MOTIF_REJET

  belongs_to :dossier_prestation
  belongs_to :enfant
  belongs_to :user, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :rejete_par, class_name: 'User', foreign_key: :rejete_par_id, optional: true
  belongs_to :retourne_par, class_name: 'User', foreign_key: :retourne_par_id, optional: true
  belongs_to :valide_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true
  belongs_to :ordre_paiement, optional: true
  belongs_to :bordereau_collectif, :class_name => 'BordereauCollectif', foreign_key: :bordereau_collectif_id, optional: true
  belongs_to :liquide_par_bordereau, :class_name => 'BordereauCollectif', foreign_key: :liquide_par_bordereau_id, optional: true
  belongs_to :maintien_prestation, :class_name => 'MaintienPrestation', foreign_key: :maintien_prestation_id, optional: true
  belongs_to :admin_agence, optional: true, :class_name => 'Admin::Agence', foreign_key: :admin_agence_id
  belongs_to :echeance_caisse, :class_name => 'EcheanceCaisse', optional: true
  belongs_to :echeance_caisse_lot_liquidation, :class_name => 'EcheanceCaisseLotLiquidation', foreign_key: :echeance_caisse_lot_liquidation_id, optional: true
  belongs_to :echeance_veuves_caisse, :class_name => 'EcheanceVeuvesCaisse', optional: true
  belongs_to :echeance_veuves_caisse_lot_liquidation, :class_name => 'EcheanceVeuvesCaisseLotLiquidation', foreign_key: :echeance_veuves_caisse_lot_liquidation_id, optional: true

  has_many :document_allocat_familiales, dependent: :destroy

  validates :trimestre, presence: true
  #validates :condition_1, :condition_2, acceptance: {message: 'doit être acceptée'}, if: :soumis?
  #validates :condition_1, :condition_2, presence: true, if: :soumis?
  #validate :enfant_eligible, if: :creation?
  validate :annee_eligible, if: :creation?
  #validate :valider_temps_de_presence
  #validate :valider_trimestre
  validate :trimestre_exist, on: :create

  after_save :generate_compta_transaction
  after_create :remove_allocation_if_invalid
  #after_create :set_document
  before_create :set_document_valid
  before_save :set_num_liquidation

  scope :en_agence, ->(id) { where(admin_agence_id: id) }
  scope :not_from_echeance, -> { where(echeance_caisse_id: nil).or(where.not(echeance_caisse_id: nil).where(is_from_ech_paid: true)) }
  #scope :not_from_echeance, -> { where(echeance_caisse_id: nil).or(where.not(echeance_caisse_id: nil, is_from_ech_paid: true).where(dossier_prestation_id: BeneficiaryAssociationsToDp.all.pluck(:dossier_prestation_id))) }
  scope :est_liquide, -> { where(etat: :soumis) }
  scope :est_valide, -> { where(etat: :valide) }
  scope :est_rejete, -> { where(etat: :rejete) }
  scope :est_suspendu, -> { where(etat: :suspendu) }
  scope :prescit, -> { where(etat: :echu) }
  scope :non_echu, -> { where('date_debut_validite > ?', Date.today).where(etat: :creation) }
  scope :en_attente_liquidation, -> { where('date_debut_validite <= ?', Date.today).where(etat: :creation) }
  scope :en_attente_validation, -> { where('date_debut_validite <= ?', Date.today).where(etat: :soumis) }
  scope :en_attente_validation_paiement, -> { where('date_debut_validite <= ?', Date.today).where(etat: :valide) }
  scope :non_paye, -> { where(paiement: false) }
  scope :by_periode, ->(trimestre, annee) { where(trimestre: trimestre, annee: annee) }
  scope :by_year, ->(annee) { where(annee: annee) }
  scope :by_bordereau, ->(bordereau) { where(bordereau_collectif_id: bordereau.id) }
  scope :liqui_par_bordereau, ->(bordereau) { where(liquide_par_bordereau_id: bordereau.id) }
  scope :when_document_valid, -> { where(document_valid: true) }
  scope :paye, -> { where(paiement: true) }
  scope :en_attente, -> { where(etat: [:soumis, :traitement_en_cours]) }
  scope :visible_for_admins, -> { where(etat: [:soumis, :traitement_en_cours, :valide, :rejete]) }
  scope :from_maintein_by_death, -> { joins([dossier_prestation: :maintien_prestations]).where(dossier_prestations: { etat: :suspendu }).where(maintien_prestations: { etat: MaintienPrestation.etats[:actif], type_maintien: MaintienPrestation.type_maintiens[:deces] }) }

=begin
  def is_out_of_date?
    annee = self.annee
    month = self.read_attribute_before_type_cast(:trimestre) * 3

    date = Date.new(annee, month, 1).end_of_month
    Date.today >= date + 1.year
  end
=end

  def set_num_liquidation
    return unless soumis?
    annee = Date.today.year
    if self.numero_liquidation_generer.nil?
      self.numero_liquidation_generer = "#{self.dossier_prestation.id}" + "/" + "#{self.id}" + "/" + "#{annee}/DOSSALFAM0001"
    end
  end

  def after_hired_date?
    end_date = self.dossier_prestation.participant.carrieres.order('date_debut_periode_cotisation DESC').last.try(:date_fin_contrat)
    return false if end_date.nil?
    end_date < self.date_debut_validite
  end

  def get_reception_date
    carrier = self.dossier_prestation.carriere_dossier_prestations.where(trimestre: self.trimestre, annee: self.annee).first
    return if carrier.nil?
    carrier.date_document
  end

  def set_document
    allocations = self.enfant.allocation_familiales
    doc = Document.where("date_expiration > ?", (Date.today - 1.year)).where(documentable: allocations).order('date_expiration DESC').first
    if doc and doc.date_expiration.year == self.annee
      self.date_expiration_piece = doc.date_expiration
      self.document_valid = true
      self.save
    end
  end

  def get_end_allocation
    Date.new(self.annee, self.read_attribute_before_type_cast(:trimestre) * 3, 1).end_of_month
  end

  def set_document_valid
    unless self.enfant.migrated_document_exp_date.nil?
      if self.enfant.migrated_document_exp_date >= self.get_end_allocation
        self.document_valid = true
        return
      end
    end

    documents = Document.where(documentable: self.enfant)
    return if documents.length == 0
    if documents.where("date_expiration >= ?", self.get_end_allocation).exists?
      self.document_valid = true
    else
      self.document_valid = false
    end
  end

  def traite?
    valide? or rejete?
  end

  def document_valid!(est_valide = true)
    update(document_valid: est_valide)
  end

  def date_expiration_piece?
    unless self.documents.last.nil?
     self.documents.last.date_expiration > Date.today
    end
    unless self.date_expiration_piece.nil?
      self.date_expiration_piece > Date.today
    end
  end

  def pret_pour_soumission?
    document_valid
  end

  def age_a_la_soumission
    age = date_soumission.year - enfant.date_naissance.year
    age -= 1 if date_soumission < enfant.date_naissance + age.years
    age
  end

  def enfant_eligible
    age = DateTime.now.year - enfant.date_naissance.year
    if age < 2 or age > 21
      errors.add(:enfant_id, "Age de l'enfant non éligible.")
    end
  end

  def annee_eligible
    if annee < enfant.date_naissance.year
      errors.add(:annee, "Année choisie est antérieur à la naissance de l'enfant")
    end
  end

  def trmimestre_eligible
    date_year = Date.parse("01-01-#{annee}")

    if trimestre1?

    elsif trimestre2?
      date_year = date_year + 3.month
    elsif trimestre3?
      date_year = date_year + 6.month
    elsif trimestre4?
      date_year = date_year + 9.month
    end

    if (date_year - enfant.date_naissance) < 2
      errors.add(:enfant_id, "Année non éligible.")
    end
  end

  def valider_temps_de_presence
    carrieres = CarriereDossierPrestation.where(dossier_prestation_id: dossier_prestation_id)
    return if carrieres.count.nil?

    unless carrieres.pluck(:trimestre).include? trimestre
      errors.add(:base, 'Le temps de présence est obligatoire pour l’ouverture des droits. ')
    end

    carrieres.each { |carriere|
      if carriere.infos_jour?
        if (carriere.trimestre.eql? trimestre and carriere.annee.eql? annee and carriere.premier_mois < 18) ||
          (carriere.trimestre.eql? trimestre and carriere.annee.eql? annee and carriere.deuxiem_mois < 18) ||
          (carriere.trimestre.eql? trimestre and carriere.annee.eql? annee and carriere.troisiem_mois < 18)

          errors.add(:base, 'Le temps de présence renseigné pour ce trimestre ne permet pas l’ouverture des droits. ')
        end
      else
        if (carriere.trimestre.eql? trimestre and carriere.annee.eql? annee and carriere.premier_mois < 120) ||
          (carriere.trimestre.eql? trimestre and carriere.annee.eql? annee and carriere.deuxiem_mois < 120) ||
          (carriere.trimestre.eql? trimestre and carriere.annee.eql? annee and carriere.troisiem_mois < 120)

          errors.add(:base, 'Le temps de présence renseigné pour ce trimestre ne permet pas l’ouverture des droits. ')
        end
      end
    }
  end

  def can_be_liquidate?
    year = annee.to_i
    month = 3 * read_attribute_before_type_cast(:trimestre)
    date_ref = Date.new(year, month, 19)
    #date_end_alloc = date_ref.change(day: date_ref.end_of_month.day) -
    Date.today >= date_ref
  end

  def valider_doucment_familiale?
    self.documents.length > 0 and !self.document_valid
  end

  def valider_trimestre
    annee_en_cours = Date.today.year
    mois_en_cours = Date.today.month
    trim_en_cours = (mois_en_cours / 3.0).ceil

    err = false

    if trimestre1?
      err = (trim_en_cours > 1 and annee < annee_en_cours)
    elsif trimestre2?
      err = (trim_en_cours > 2 and annee < annee_en_cours)
    elsif trimestre3?
      err = (trim_en_cours > 3 and annee < annee_en_cours)
    elsif trimestre4?
      err = (trim_en_cours > 4 and annee < annee_en_cours)
    end

    errors.add(:base, "Le temps de présence renseigné date plus d'un an.") if err
  end

  def trimestre_exist
    alloc = AllocationFamiliale.where(trimestre: self.read_attribute_before_type_cast(:trimestre), annee: self.annee, dossier_prestation_id: self.dossier_prestation_id, enfant: self.enfant_id).first

    unless alloc.nil?
      errors.add(:base, "Cette allocation existe déjà.")
    end
  end

  def montant_a_payer
    interval_month = find_interval(self.trimestre)

    time_of_presence = self.dossier_prestation.carriere_dossier_prestations.where(annee: self.annee, trimestre: self.read_attribute_before_type_cast(:trimestre)).first

    birth_year = self.enfant.date_naissance.year
    birth_month = self.enfant.date_naissance.month
    salary_birth_year = dossier_prestation.date_naissance.year
    salary_birth_month = dossier_prestation.date_naissance.month
    amount = 0
    cpt = [1, 1, 1]

    if self.annee === birth_year + 2 and find_interval(self.trimestre).include? birth_month

      if [1, 4, 7, 10].include? birth_month
        cpt[0] = 0
      end
      if [2, 5, 8, 11].include? birth_month
        cpt[0] = 0
        cpt[1] = 0
      end
      if [3, 6, 9, 12].include? birth_month
        cpt[0] = 0
        cpt[1] = 0
        cpt[2] = 0
      end

    end

    if self.annee === birth_year + 21 and find_interval(self.trimestre).include? birth_month

      if [1, 4, 7, 10].include? birth_month
        cpt[1] = 0
        cpt[2] = 0
      end

      if [2, 5, 8, 11].include? birth_month
        cpt[2] = 0
      end

    end

    if dossier_prestation.valide?
      if time_of_presence.infos_jour?
        if time_of_presence.premier_mois < 18 && time_of_presence.est_justifier == false
          cpt[0] = 0
        end
        if time_of_presence.deuxiem_mois < 18 && time_of_presence.est_justifier_mois2 == false
          cpt[1] = 0
        end
        if time_of_presence.troisiem_mois < 18 && time_of_presence.est_justifier_mois3 == false
          cpt[2] = 0
        end

      else

        if time_of_presence.premier_mois < 120 && time_of_presence.est_justifier == false
          cpt[0] = 0
        end
        if time_of_presence.deuxiem_mois < 120 && time_of_presence.est_justifier_mois2 == false
          cpt[1] = 0
        end
        if time_of_presence.troisiem_mois < 120 && time_of_presence.est_justifier_mois3 == false
          cpt[2] = 0
        end

        if (time_of_presence.est_justifier == true && time_of_presence.motif_mois1 == 'Travail intermittent') or
          (time_of_presence.est_justifier_mois2 == true && time_of_presence.motif_mois2 == 'Travail intermittent') or
          (time_of_presence.est_justifier_mois3 == true && time_of_presence.motif_mois3 == 'Travail intermittent')

          number_day_array = [time_of_presence.premier_mois, time_of_presence.deuxiem_mois, time_of_presence.troisiem_mois]

          number_day_array_dispatched = get_dispatched_array(number_day_array)

          if number_day_array_dispatched[0] < 120
            cpt[0] = 0
          end
          if number_day_array_dispatched[1] < 120
            cpt[1] = 0
          end
          if number_day_array_dispatched[2] < 120
            cpt[2] = 0
          end
        end
      end

      if self.annee === salary_birth_year + 60 and find_interval(self.trimestre).include? salary_birth_month

        if [1, 4, 7, 10].include? salary_birth_month
          cpt[0] = 1
        end
        if [2, 5, 8, 11].include? salary_birth_month
          cpt[1] = 1
        end
        if [3, 6, 9, 12].include? salary_birth_month
          cpt[2] = 1
        end
      end

      reception_date = self.date_reception.nil? ? self.get_reception_date : self.date_reception

      if reception_date > (Date.new(self.annee, interval_month[0], 1).end_of_month + 1.year)
        cpt[0] = 0
      end
      if reception_date > (Date.new(self.annee, interval_month[1], 1).end_of_month + 1.year)
        cpt[1] = 0
      end
      if reception_date > (Date.new(self.annee, interval_month[2], 1).end_of_month + 1.year)
        cpt[2] = 0
      end
    end

    unless dossier_prestation.date_ouverture.nil?
      if dossier_prestation.date_ouverture + 18.days > (Date.new(self.annee, interval_month[0], 1).end_of_month)
        cpt[0] = 0
      end
      if dossier_prestation.date_ouverture + 18.days > (Date.new(self.annee, interval_month[1], 1).end_of_month)
        cpt[1] = 0
      end
      if dossier_prestation.date_ouverture + 18.days > (Date.new(self.annee, interval_month[2], 1).end_of_month)
        cpt[2] = 0
      end
    end

    if self.enfant.deces?
      dead_child = DecesEnfant.where(enfant_id: self.enfant.id).first

      if dead_child.date_deces < (Date.new(self.annee, interval_month[0], 1))
        cpt[0] = 0
      end
      if dead_child.date_deces < (Date.new(self.annee, interval_month[1], 1))
        cpt[1] = 0
      end
      if dead_child.date_deces < (Date.new(self.annee, interval_month[2], 1))
        cpt[2] = 0
      end

    end

    cpt.each do |x|
      amount += (x * 2600)
    end

    amount
  end

  def get_dispatched_array(number_array)
    reserve = 0
    i = 0
    number_array.each do |item|
      if item > 120
        reserve += item - 120
        number_array[i] = 120
      end
      i += 1
    end

    i = 0

    number_array.each do |item|
      if item < 120
        if item + reserve >= 120
          reserve = item + reserve - 120
          number_array[i] = 120
          puts 'reserve', reserve
        end
      end
      i += 1
    end

    puts 'number_array', number_array
    number_array
  end

  def reinitialize_amount

    birth_year = self.enfant.date_naissance.year
    birth_month = self.enfant.date_naissance.month
    salary_birth_year = dossier_prestation.date_naissance.year
    salary_birth_month = dossier_prestation.date_naissance.month
    amount = 0
    cpt = [1, 1, 1]

    if dossier_prestation.valide?
      if self.annee === salary_birth_year + 60 and find_interval(self.trimestre).include? salary_birth_month

        if [1, 4, 7, 10].include? salary_birth_month
          cpt[0] = 0
        end
        if [2, 5, 8, 11].include? salary_birth_month
          cpt[0] = 0
          cpt[1] = 0
        end
        if [3, 6, 9, 12].include? salary_birth_month
          cpt[0] = 0
          cpt[1] = 0
          cpt[2] = 0
        end

      end

      interval_month = find_interval(self.trimestre)
      reception_date = self.date_reception.nil? ? self.get_reception_date : self.date_reception

      unless reception_date.nil?
        if reception_date > (Date.new(self.annee, interval_month[0], 1).end_of_month + 1.year)
          cpt[0] = 0
        end
        if reception_date > (Date.new(self.annee, interval_month[1], 1).end_of_month + 1.year)
          cpt[1] = 0
        end
        if reception_date > (Date.new(self.annee, interval_month[2], 1).end_of_month + 1.year)
          cpt[2] = 0
        end
      end
    end

    if self.annee === birth_year + 2 and find_interval(self.trimestre).include? birth_month

      if [1, 4, 7, 10].include? birth_month
        cpt[0] = 0
      end
      if [2, 5, 8, 11].include? birth_month
        cpt[0] = 0
        cpt[1] = 0
      end
      if [3, 6, 9, 12].include? birth_month
        cpt[0] = 0
        cpt[1] = 0
        cpt[2] = 0
      end

    end

    if self.annee === birth_year + 21 and find_interval(self.trimestre).include? birth_month

      if [1, 4, 7, 10].include? birth_month
        cpt[1] = 0
        cpt[2] = 0
      end

      if [2, 5, 8, 11].include? birth_month
        cpt[2] = 0
      end

    end

    unless dossier_prestation.date_ouverture.nil?
      if dossier_prestation.date_ouverture + 18.days > (Date.new(self.annee, interval_month[0], 1).end_of_month)
        cpt[0] = 0
      end
      if dossier_prestation.date_ouverture + 18.days > (Date.new(self.annee, interval_month[1], 1).end_of_month)
        cpt[1] = 0
      end
      if dossier_prestation.date_ouverture + 18.days > (Date.new(self.annee, interval_month[2], 1).end_of_month)
        cpt[2] = 0
      end
    end

    if self.enfant.deces?
      dead_child = DecesEnfant.where(enfant_id: self.enfant.id).first

      if dead_child.date_deces < (Date.new(self.annee, interval_month[0], 1))
        cpt[0] = 0
      end
      if dead_child.date_deces < (Date.new(self.annee, interval_month[1], 1))
        cpt[1] = 0
      end
      if dead_child.date_deces < (Date.new(self.annee, interval_month[2], 1))
        cpt[2] = 0
      end

    end

    cpt.each do |x|
      amount += (x * 2600)
    end

    amount
  end

  def find_interval(trimestre)
    if trimestre === 'trimestre1'
      return [1, 2, 3]
    elsif trimestre === 'trimestre2'
      return [4, 5, 6]
    elsif trimestre === 'trimestre3'
      return [7, 8, 9]
    elsif trimestre === 'trimestre4'
      return [10, 11, 12]
    end
  end

  def generate_compta_transaction
    return if est_repris?
    return if montant_paiement.nil?
    new_transaction_amount = montant_paiement
    if valide? and traite_par and traite_par.comptable? and not ComptaTransaction.exists?(dossier: self, statut: [:paye, :en_cours]) and (echeance_caisse.nil? or (not echeance_caisse.nil? and dossier_prestation.has_beneficiaries?))
      if ordre_paiement.nil?
        self.ordre_paiement = OrdrePaiement.create(dossier: dossier_prestation,
                                                   numero_allocataire: dossier_prestation.num_affiliation)
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
      conjoint_veuf = Conjoint.find_by(numero_affiliation: dossier_prestation.num_affiliation, id: enfant.conjoint_id)
      ComptaTransaction.create(
        en_tete: en_tete_comptabilite,
        dossier: self,
        ordre_paiement: ordre_paiement,
        code_operation: 'PF_AF',
        code_classe_evenement: 'LIQUIDATION',
        code_agence_liquidation: traite_par.agence.try(:code_psrm) || 'C_SG', # à définir
        numero_allocataire: if dossier_prestation.est_suspendu?
                              conjoint_veuf.try(:numero_piece)
                            else
                              dossier_prestation.num_affiliation
                            end,
        nom: if dossier_prestation.est_suspendu?
                conjoint_veuf.try(:nom) || dossier_prestation.nom
             else
                dossier_prestation.conjoint.try(:nom) || dossier_prestation.nom
             end,
        prenom: if dossier_prestation.est_suspendu?
                  conjoint_veuf.try(:prenom) || dossier_prestation.prenom
                else
                  dossier_prestation.conjoint.try(:prenom) || dossier_prestation.prenom
                end,
        adresse: (dossier_prestation.conjoint.nil? ? nil : dossier_prestation.adresse_domicile),
        mode_paiement: :caisse_css,
        code_banque_allocataire: nil,
        numero_compte_allocataire: nil,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: new_transaction_amount,
        code_devise: 'XOF',
        statut: :en_cours,
        description: "Allocation familiale #{trimestre}, enfant : #{enfant.try(:full_name)}",
        nom_reel_allocataire: if dossier_prestation.est_suspendu?
                                dossier_prestation.nom
                              end,
        prenom_reel_allocataire: if dossier_prestation.est_suspendu?
                                    dossier_prestation.prenom
                                 end,
      )
    end
  end

  def remove_allocation_if_invalid
    if montant_paiement.nil?
      if montant_a_payer === 0
        self.destroy
      end
    end
  end

end
