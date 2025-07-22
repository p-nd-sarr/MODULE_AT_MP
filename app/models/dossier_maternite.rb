class DossierMaternite < ApplicationRecord
  include Documentable
  # include WorkflowActiverecord
  include ActionView
  include HasBankAccount

  # workflow_column :etat

=begin
  workflow do
    state :creation do
      event :est_soumis, transition_to: :soumis
    end

    state :soumis do
      event :en_cours_de_traitement, transition_to: :valide
      event :retour_creation, transition_to: :creation
    end

    state :valide do
      event :retour_soumis, transition_to: :soumis
    end
    state :rejete
  end
=end

  ETAT = {
      creation: 1,
      soumis: 2,
      traitement_en_cours: 3,
      valide: 4,
      rejete: 5,
      suspendu: 6,
      cloture: 7
  }.freeze
  enum etat: ETAT

  SEXE = {
      masculin: 1,
      feminin: 2,
  }.freeze
  enum sexe_salarie: SEXE

  TYPE_PIECE = {
      cni_tp: 1,
      passport: 2,
      cc: 3
  }.freeze
  enum type_piece: TYPE_PIECE

  NOMBRE_PART_IMPOT = {
      un: 1,
      un_cinq: 2,
      deux: 3,
      deux_cinq: 4,
      trois: 5,
      trois_cinq: 6,
      quatre: 7,
      quatre_cinq: 8,
      cinq: 9
  }.freeze
  enum nombre_part_impot: NOMBRE_PART_IMPOT

  PART_TRIMF = {
      un_trimf: 1,
      deux_trimf: 2
  }.freeze
  enum part_trimf: PART_TRIMF

  enum mode_paiement: MODE_PAIEMENT

  TYPE_DOCUMENT_OBLIGATOIRE = {
      type_piece_demandeur: 41,
      #attestation_cess_paie: 32,
      demande_conges: 28,
      attestation_travail: 3,
      certificat_medicale_gross: 29,
      attestation_susp_act: 30,
      last_bul_salaire: 31
  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      rib: 10,
      #cni: 1,
      #passeport: 8,
      #carte_consulaire: 9,
      attestation_cess_paie: 32,
      attestation_salaire: 33,
      #certif_conges_maternite: 35,
      attestation_maintien_salaire: 34,
      type_piece_attributaire: 40,
      certificat_travail: 12,
      #passeport_attributaire: 38,
      #carte_consulaire_attributaire: 39
    }
  ).freeze

  belongs_to :user, optional: true
  belongs_to :admin_agence, optional: true, :class_name => 'Admin::Agence', foreign_key: :admin_agence_id
  belongs_to :retourne_par, class_name: 'User', foreign_key: :retourne_par_id, optional: true
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  belongs_to :suspendu_par, class_name: 'User', foreign_key: :suspendu_par_id, optional: true
  belongs_to :cloture_par, class_name: 'User', foreign_key: :cloture_par_id, optional: true
  #has_many :document_dossier_maternites, dependent: :destroy
  has_many :indemnite_conges_maternites, dependent: :destroy
  has_many :indemnite_conges_maternite_migrees, foreign_key: :dossier_maternite_id, primary_key: :old_dossier_maternite_id
  has_many :composant_salaire_icms, dependent: :destroy
  has_many :carriere_dossier_maternites, dependent: :destroy
  has_many :dossier_maternite_avis_tiers, foreign_key: :dossier_maternite_id

  has_many :ordre_paiements, as: :dossier, dependent: :destroy
  has_many :compta_transactions, through: :ordre_paiements

  belongs_to :participant, :class_name => 'Psrm::Participant',
             foreign_key: :num_affiliation,
             primary_key: :matric,
             optional: true

  belongs_to :affecter_controleur, class_name: 'User', foreign_key: :affectation_controleur, optional: true
  belongs_to :affecte_a, class_name: 'User', foreign_key: :affecte_a_id, optional: true

  has_one_attached :document

  validates :num_affiliation, :debut_grossesse, :debut_conges, :prenom, :nin, :adresse_domicile, :date_naissance, :lieu_naissance, presence: true, unless: :est_repris
  validates :num_immatriculation, :mode_paiement, :raison_sociale, :adresse_employeur, :nom, :nombre_part_impot, :part_trimf, presence: true, unless: :est_repris
  validates :compte_bancaire_nom_banque, :compte_bancaire_code_banque, :compte_bancaire_code_guichet,
            :compte_bancaire_numero_compte, presence: true, if: :virement?, unless: :est_repris
  validates :date_embauche, presence: true
  validates :nom_attributaire, :prenom_attributaire, :nin_attributaire, presence: true, if: :attributaire?, unless: :est_repris
  validates :document, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true, allow_nil: true }, unless: :est_repris
  validates :telephone, presence: true, numericality: true, unless: :est_repris #, length: { :minimum => 12, :maximum => 15 },  country_specifier: -> phone { phone.country.try(:upcase) } }
  validates :email_employeur, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true, allow_nil: true }, unless: :est_repris
  validates :tel_employeur, presence: true, numericality: true, unless: :est_repris #, country_specifier: -> phone { phone.country.try(:upcase) } }
  #validates :condition_1, :condition_2, :condition_3,
  #          acceptance: {message: 'doit être acceptée'}
  #validates :condition_1, :condition_2, :condition_3,
  #          presence: true, if: :soumis?
  validate :validate_num_affiliation, unless: :est_repris
  #validate :validate_date_naissance!
  validate :validate_debut_conges!, unless: :est_repris
  validate :validate_debut_grossesse!
  validate :validate_date_suspension_salaire!, unless: :est_repris
  #validates_length_of :nin, minimum: 13, maximum: 13
  #validates_length_of :nin_attributaire, minimum: 13, maximum: 13, if: :attributaire?
  validate :sexe_salarie_validation, unless: :est_repris
  validate :verifier_doublons, on: :create
  validate :validate_delai_stage, on: :create
  validate :valider_nin, unless: :est_repris

  scope :not_deleted, -> { where(deleted: false) }
  scope :not_incomplete, -> { where(incomplete: false) }
  scope :en_attente, -> { where(etat: [:soumis, :traitement_en_cours]) }
  scope :visible_for_admins, -> { where(etat: [:creation, :soumis, :traitement_en_cours, :valide, :rejete, :suspendu, :cloture]) }

  before_validation :set_num_affiliation!
  before_create :set_user!
  before_create :set_numero_dossier!
  before_create :verifier_doublons
  before_create :date_accouchement_prevu
  before_create :fin_conges_prevu
  before_save :delai_de_stage

  def set_as_agent_chosen(id)
    self.affecte_a_id = id
    self.save
  end

  def is_not_agent_chosen_anymore(id)
    self.affecte_a_id = nil
    self.save
  end

  def is_set_manager(id)
    User.find(id) == self.affecte_a
  end

  def affecter_controle?
    !affecter_controleur.nil?
  end

  def delai
    #TimeDifference.between(date_embauche, debut_conges).humanize unless date_embauche.nil?
    a = TimeDifference.between(date_embauche, debut_conges).in_general unless date_embauche.nil?
    return if a.nil?
    an = ' ans, '
    jr = ' jours'
    if (a[:years] <= 1)
      an = ' an, '
    end
    if (a[:days] <= 1)
      jr = ' jour'
    end
    a[:years].to_s + an + a[:months].to_s + ' mois, ' + a[:days].to_s + jr
  end

  def attente_paiement?
    valide? and not indemnite_conges_maternites.valide.non_paye.empty?
  end

  def full_name
    "#{prenom unless prenom.nil?} #{nom unless nom.nil?}"
  end

  def etat_civil_demandeur_valid!(est_valide = true)
    update(etat_civil_demandeur_valid: est_valide)
  end

  def carriere_valid!(est_valide = true)
    update(carriere_valid: est_valide)
  end

  def document_valid!(est_valide = true)
    if est_valide
      return false unless required_document_uploaded?
      return false if virement? and documents.rib.empty?
      return false if subrogation? and documents.attestation_maintien_salaire.empty?
      return false if not subrogation? and documents.attestation_cess_paie.empty?
      return false if attributaire? and documents.type_piece_attributaire.empty?
      return false if documents.type_piece_demandeur.empty?
    end
    update(document_valid: est_valide)
    true
  end

  def salaire_valid!(est_valide = true)
    update(salaire_valid: est_valide)
  end

  def pret_pour_soumission?
    etat_civil_demandeur_valid and carriere_valid and document_valid and salaire_valid
  end

  def can_submit?(user)
    (!ajoute_par.nil? and user == ajoute_par) or (!ajoute_par.nil? and user == affecte_a) or (ajoute_par.nil?)
  end

  def revenu_brut
    amount = composant_salaire_icms.joins(:composant_salaire).where(admin_composant_salaires: { prise_en_compte: true }).sum(:montant)
    amount = (amount / 1000).floor * 1000
    amount
  end

  def revenu_ref
    amount = composant_salaire_icms.joins(:composant_salaire).where(admin_composant_salaires: { prise_en_compte: true }).sum(:montant)
  end

  def valeur_part
    rev = revenu_brut
    if revenu_brut <= 5_000_000
      modulo_revenu = rev % 1000
      if (modulo_revenu > 0)
        rev = rev - modulo_revenu
        if (modulo_revenu >= 500)
          rev = rev + 1000
        end
      end
      bareme = BaremeImpot.find_by(revenu_brut: rev)
      return 0 if bareme.nil?
      if un?
        bareme.un
      elsif un_cinq?
        bareme.un_cinq
      elsif deux?
        bareme.deux
      elsif deux_cinq?
        bareme.deux_cinq
      elsif trois?
        bareme.trois
      elsif trois_cinq?
        bareme.trois_cinq
      elsif quatre?
        bareme.quatre
      elsif quatre_cinq?
        bareme.quatre_cinq
      elsif cinq?
        bareme.cinq
      end
    else
      montant_ir
    end
  end

  def montant_trimf
    return 0 if revenu_brut < 50_000
    if (revenu_brut >= 50_000 and revenu_brut < 84_000)
      300
    elsif (revenu_brut >= 84_000 and revenu_brut < 167_000)
      400
    elsif (revenu_brut >= 167_000 and revenu_brut < 1_000_000)
      500
      #elsif (revenu_brut >= 1_000_000 and revenu_brut <= 5_000_000)
    elsif revenu_brut >= 1_000_000
      1_500
    end
  end

  def valeur_trimf
    return 0 if part_trimf.nil?
    if un_trimf?
      montant_trimf
    elsif deux_trimf?
      montant_trimf * 2
    end
  end

  def salaire_reference
    salaire_ref = 0
    if est_repris?
      salaire_ref = montant_salaire unless montant_salaire.nil?
    elsif !est_repris? && get_avis_tiers_trop_percu.present?
      salaire_ref = montant_salaire unless montant_salaire.nil?
    else
      salaire_ref = revenu_ref unless revenu_ref.nil?
      if est_ir_trimf_applique? and not revenu_ref.nil?
        salaire_ref = revenu_ref - valeur_part unless valeur_part.nil?
        salaire_ref = salaire_ref - valeur_trimf
      end
    end
    salaire_ref
  end

  def fin_conges_prevu
    self.date_fin_cong_prev = date_accouchement_prev + 56.days unless date_accouchement_prev.nil?
  end

  def date_accouchement_prevu
    self.date_accouchement_prev = debut_conges + 42.days unless debut_conges.nil?
  end

  def delai_de_stage
    self.delai_stage = (debut_conges - date_embauche).to_i unless date_embauche.nil?
  end

  def repos_avant_accouchement_reel
    return 0 if date_accouchement_reel.nil?
    return 0 if debut_conges.nil?
    (date_accouchement_reel - debut_conges).to_i
  end

  def repos_apres_accouchement_reel
    return 0 if date_accouchement_reel.nil? or date_fin_cong_reel.nil?
    (date_fin_cong_reel - date_accouchement_reel).to_i
  end

  def total_repos_reel
    repos_avant_accouchement_reel + repos_apres_accouchement_reel
  end

  def jr_indem_avant_accouchement
    indemnites = indemnite_conges_maternites.avant_acouchement.existes
    return 0 if indemnites.empty?
    a = 0
    indemnites.each do |indem|
      a = indem.nbre_jr_payes
    end
    a
  end

  def jr_indem_apres_accouchement
    indemnites2 = indemnite_conges_maternites.apres_acouchement.existes
    indemnites3 = indemnite_conges_maternites.apres_reprise.existes
    a = 0
    b = 0
    return 0 if indemnites2.empty?
    indemnites2.each do |indem2|
      a = indem2.nbre_jr_payes
    end
    unless indemnites3.empty?
      indemnites3.each do |indem3|
        b = indem3.nbre_jr_payes
      end
    end
    a + b
  end

  def total_jr_indem
    jr_indem_avant_accouchement + jr_indem_apres_accouchement
  end

  def tranches_eligibles
    #return {} unless creation?

    tranches = {
      avant_acouchement: 1,
      apres_acouchement: 2,
      apres_reprise: 3,
      tranche_prolongation: 4
    }

    # tranches.except!(:avant_acouchement) unless indemnite_conges_maternites.avant_acouchement.existes.empty? and indemnite_conges_maternite_migrees.find_by(num_tranche: 1).nil?
    # tranches.except!(:apres_acouchement) unless indemnite_conges_maternites.apres_acouchement.existes.empty? and indemnite_conges_maternite_migrees.find_by(num_tranche: 2).nil?
    # tranches.except!(:apres_reprise) unless indemnite_conges_maternites.apres_reprise.existes.empty? and indemnite_conges_maternite_migrees.find_by(num_tranche: 3).nil?
    # tranches.except!(:tranche_prolongation) unless indemnite_conges_maternites.any? { |i| i.prolongation == true } and indemnite_conges_maternite_migrees.find_by(num_tranche: 4).nil?

    tranches.except!(:avant_acouchement) unless indemnite_conges_maternites.avant_acouchement.existes.empty?
    tranches.except!(:apres_acouchement) unless indemnite_conges_maternites.apres_acouchement.existes.empty?
    tranches.except!(:apres_reprise) unless indemnite_conges_maternites.apres_reprise.existes.empty?
    tranches.except!(:tranche_prolongation) unless indemnite_conges_maternites.any? { |i| i.prolongation == true }

    tranches
  end

  def valider_nin
    salarie = Psrm::Participant.find_by(matric: self.num_affiliation)
    return if salarie.nil?

    if cni_tp?
      first_char = !nin.first.match(/\A[a-zA-Z]*\z/).nil?

      if salarie.homme? and (nin[0].to_i == 2 || first_char)
        errors.add(:nin, ': Le NIN doit commencer par (2) pour une femme ')
      elsif salarie.femme? and (nin[0].to_i == 1 || first_char)
        errors.add(:nin, ': Le NIN doit commencer par (1) pour un homme ')
      end

    end

  end

  def check_if_avis_tiers_exist?
    dossier_maternite_avis_tiers.exists?(type_avis: :trop_percu, etat: :valide, status: :non_paye)
  end

  def get_avis_tiers
    dossier_maternite_avis_tiers.where(type_avis: :trop_percu, etat: :valide, status: :non_paye).first
  end

  def get_avis_tiers_trop_percu
    dossier_maternite_avis_tiers.where(type_avis: :trop_percu, etat: :valide, status: :non_paye, type_motif: :salaire_reference_errone).first
  end

  def check_avis_tiers_valide?
    dossier_maternite_avis_tiers.exists?(type_avis: :trop_percu, etat: :valide)
  end

  def update_montant_salaire(salaire_reference_a_cons)
    update_column(:montant_salaire, salaire_reference_a_cons)
  end

  def avis_tiers_salaire_reference_errone
    salaire_ref = revenu_ref unless revenu_ref.nil?
    if est_ir_trimf_applique? and not revenu_ref.nil?
      salaire_ref = revenu_ref - valeur_part unless valeur_part.nil?
      salaire_ref = salaire_ref - valeur_trimf
    end
    salaire_ref
  end

  def manage_avis_tiers(allocations, op)
    if check_if_avis_tiers_exist?
      avis_tiers = get_avis_tiers
      tranche_amount = allocations.to_a.sum(&:montant_paiement)   
      ref_amount = avis_tiers.remaining_amount > avis_tiers.montant_avis ? avis_tiers.montant_avis : avis_tiers.remaining_amount
      # ref_amount = avis_tiers.remaining_amount
      paid_amount = ref_amount <= tranche_amount ? ref_amount : tranche_amount
      li = LigneIcmAvisTiersTransaction.new
      li.dossier_maternite_avis_tier = avis_tiers
      li.ordre_paiement = op
      li.montant = paid_amount
      li.montant_paye = 0
      li.ajoute_par = User.current
      puts 'error', li.errors.full_messages unless li.save

      # if avis_tiers.montant_avis == avis_tiers.get_amount_paid
      #   avis_tiers.status = DossierMaterniteAvisTier.statuses['paye']
      #   puts "STATUT CHANGE"
      #   avis_tiers.save
      # end
    end
  end

  def valider_paiements(utilisateur)
    prestation_icms = indemnite_conges_maternites.valide.non_paye.where('montant_paiement <> 0')

    if prestation_icms.count.zero?
      self.update_columns(generation_paiement_encours: false)
      return false
    end

    op = OrdrePaiement.create(dossier: self, numero_allocataire: num_affiliation)

    # Gérer le trop-perçu s'il existe
    if check_if_avis_tiers_exist?
      manage_avis_tiers(prestation_icms, op)
    end

    prestation_icms.each do |prestation|
      prestation.traite_par = utilisateur
      prestation.paiement = true
      prestation.ordre_paiement = op
      prestation.save
    end

    self.update_columns(generation_paiement_encours: false)
    true
  end

  private

  def set_num_affiliation!
    self.num_affiliation = user.numero_salarie unless user.nil?
  end

  def validate_delai_stage
    return if delai_stage < 3.months
    errors.add(:date_embauche, "Délai de stage inférieure à 3 mois. On ne peut demander des indemnités.")
  end

  def validate_num_affiliation
    if num_affiliation.nil? or num_affiliation.empty?
      errors.add(:num_affiliation, "Ce numéro d'affiliation est introuvable") unless Psrm::Participant.where(matric: num_affiliation).exists?
    end
  end

  #def validate_date_naissance!
  #  if date_naissance.nil? or date_naissance.blank?
  #      errors.add(:date_naissance, "Date de naissance obligatoire")
  #  end
  #
  #end

  def validate_debut_conges!
    return if debut_conges.nil?

    if debut_conges < debut_grossesse
      errors.add(:debut_conges, "Ne peut pas être antérieure à la date du début de la grossesse (#{I18n.l(debut_grossesse)})")
    end

    if debut_conges > Date.today
      errors.add(:debut_conges, "Ne peut pas être postérieure à la date du jour (#{I18n.l(Date.today)})")
    end

    unless date_accouchement_prev.nil?
      if debut_conges > date_accouchement_prev
        errors.add(:debut_conges, "Ne peut pas être postérieure à la date prév. d'accouchement (#{I18n.l(date_accouchement_prev)})")
      end
    end

  end

  def validate_debut_grossesse!
    return if debut_grossesse.blank? or date_naissance.blank?

    if debut_grossesse <= date_naissance
      errors.add(:debut_grossesse, "Ne peut pas être antérieure à la date de naissance (#{I18n.l(date_naissance)})")
    end

    if debut_grossesse > Date.today
      errors.add(:debut_grossesse, "Ne peut pas être postérieure à la date du jour (#{I18n.l(Date.today)})")
    end

    if debut_grossesse == Date.today
      errors.add(:debut_grossesse, "Ne peut pas être aujourd'hui")
    end

    #if debut_grossesse < Date.today - 1.year
    #  errors.add(:debut_grossesse, "Le délai de prescription de ce dossier est dépassé.")
    #end
  end

  def validate_date_suspension_salaire!
    return if date_suspension_salaire.blank?

    if date_suspension_salaire < debut_grossesse
      errors.add(:date_suspension_salaire, "Ne peut pas être antérieure à la date de début de grossesse (#{I18n.l(debut_grossesse)})")
    end
    if date_suspension_salaire == debut_grossesse
      errors.add(:date_suspension_salaire, "Ne peut pas être le même jour que la date de début de grossesse (#{I18n.l(debut_grossesse)})")
    end
  end

  def verifier_doublons
    if DossierMaternite.where(num_affiliation: num_affiliation, debut_grossesse: debut_grossesse).exists?
      errors.add(:num_affiliation, " ")
      errors.add(:debut_grossesse, "Vous avez déja ouvert un dossier ICM pour cette grossesse.")
    end
  end

=begin
  def verifier_doublons
    if DossierMaternite.where(num_affiliation: num_affiliation, debut_grossesse: debut_grossesse).exists?
      errors.add(:num_affiliation, " ")
      errors.add(:debut_grossesse, "Vous avez déja ouvert un dossier ICM pour cette grossesse.")
    end

    dernier_dossier_ajoute = DossierMaternite.where(
        num_affiliation: num_affiliation
    ).order('date_accouchement_reel DESC').first
  end
=end

  def sexe_salarie_validation
    if sexe_salarie == "masculin"
      errors.add(:num_affiliation, "Ce numéro d'affiliation appartient à un homme et un homme ne peut pas faire de demande d'Indemnités de Congés Maternité.")
    end
  end

  def set_user!
    self.user = User.find_by(numero_salarie: num_affiliation)
  end

  def set_numero_dossier!
    annee = Date.today.year
    if DossierMaternite.exists?(num_affiliation: num_affiliation, created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year))
      dernier_dossier_ajoute = DossierMaternite.where(num_affiliation: num_affiliation, created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year)).order('created_at DESC').first
      self.num_dossier = dernier_dossier_ajoute.num_dossier.next
    else
      self.num_dossier = "#{num_affiliation}/#{annee}/DOSSMATER01"
    end
  end

  #def montant_trimf
  #  300 if revenu_brut.between?(50_000, 830_000)
  #  400 if revenu_brut.between?(830_001, 166_000)
  #  500 if revenu_brut.between?(166_001, 999_999)
  #  1_500 if revenu_brut.between?(1_000_000, 5_000_000)
  #  0
  #end
end
