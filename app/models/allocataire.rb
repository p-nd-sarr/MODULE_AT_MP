class Allocataire < ApplicationRecord
  include MyTools
  include HasBankAccount

  REGIME = {
    general: 1,
    cadre: 2,
    employe_de_maison: 3
  }

  TYPE_CATEGORIE = {
    retraite: 1,
    veuve: 6,
    orphelin: 8,
    pension_alimentaire: 19,

    coordination: 2,
    vtr: 3,
    allocation_solidarite: 4,
    fonds_social: 5,
    remboursement_cotisation: 7,
    veuve_administration: 9,
    rente_administration: 10,
    test_interne: 11,
    rente_viagere: 12,
    asj: 13,
  }.freeze

  ETAT = {
    inactif: 0,
    actif: 1,
    soumis: 2,
    affecter: 3,
    suspendus: 4,
    lever_suspension: 5,
    rejete: 6,
    eteint: 7,
    valider: 8
  }.freeze

  REGIME_MAT = {
    monogame: 1,
    polygame: 2
  }.freeze

  SEXE = {
    homme: 1,
    femme: 2
  }.freeze

  TYPE_DE_PIECE = {
    cni: 1,
    carte_cedeao: 2,
    carte_consulaire: 3,
    passeport: 4,
    extrait_de_naissance: 5
  }.freeze

  enum categorie: TYPE_CATEGORIE

  enum etat: ETAT

  enum regime_mat: REGIME_MAT

  enum sexe: SEXE

  enum mode_paiement: MODE_PAIEMENT

  enum regime: REGIME

  enum zone: ZONE

  enum type_de_piece: TYPE_DE_PIECE

  has_many :enfants, foreign_key: :numero_affiliation, primary_key: :numero_allocataire
  has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :numero_allocataire
  has_many :carrieres_prestation, class_name: 'Carriere', foreign_key: :numero_affiliation, primary_key: :numero_allocataire
  has_many :carrieres, class_name: 'Psrm::Carriere', foreign_key: :numero_affiliation, primary_key: :numero_allocataire
  has_many :reversion_veuves, foreign_key: :numero_allocataire, primary_key: :numero_allocataire
  has_many :revision_pensions, foreign_key: :numero_allocataire, primary_key: :numero_allocataire
  has_many :pret_allocataire_lignes, foreign_key: :numero_allocataire, primary_key: :numero_allocataire
  has_many :avis_tiers, foreign_key: :numero_allocataire, primary_key: :numero_allocataire
  has_many :modifier_mode_paiements, foreign_key: :numero_allocataire, primary_key: :numero_allocataire
  has_many :modifier_adresses, class_name: 'ModifierAdresse', foreign_key: :numero_allocataire, primary_key: :numero_allocataire
  has_many :regularisation_pensions, foreign_key: :numero_allocataire, primary_key: :numero_allocataire
  has_many :update_grappe_familiales, foreign_key: :num_affiliation, primary_key: :numero_allocataire
  has_many :pension_alimentaires, foreign_key: :numero_allocataire, primary_key: :numero_allocataire
  has_many :suspension_allocataire, foreign_key: :numero_allocataire, primary_key: :numero_allocataire
  has_one :base_reversion, foreign_key: :numero_allocataire, primary_key: :numero_allocataire
  has_many :compta_transactions, foreign_key: :numero_allocataire, primary_key: :numero_allocataire
  has_many :ordre_paiements, foreign_key: :numero_allocataire, primary_key: :numero_allocataire

  belongs_to :enfant1, class_name: 'Enfant', foreign_key: :enfant1_id, optional: true
  belongs_to :enfant2, class_name: 'Enfant', foreign_key: :enfant2_id, optional: true
  belongs_to :enfant3, class_name: 'Enfant', foreign_key: :enfant3_id, optional: true
  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true


  has_one :liquidation_retraite, foreign_key: :allocataire_id
  has_one :reversion_veuve, foreign_key: :allocataire_id
  has_one :dossier_reversion_salary, foreign_key: :allocataire_id
  has_one :demande_carte_allocataire, foreign_key: :allocataire_id

  has_many :historiques, foreign_key: :allocataire_id

  has_many :allocataire_suivi_modifications, dependent: :destroy
  has_many :paiement_allocataires, foreign_key: :numero_allocataire, primary_key: :numero_allocataire

  belongs_to :admin_region, :class_name => 'Admin::Region', foreign_key: :admin_region_id, optional: true
  belongs_to :admin_agence, :class_name => 'Admin::Agence', foreign_key: :admin_agence_id, optional: true
  belongs_to :admin_association_allocataire, :class_name => 'Admin::AssociationAllocataire', foreign_key: :admin_association_allocataire_id, optional: true

  scope :eligibles_pret, -> { where(versement_unique: false, categorie: [:retraite, :veuve]) }
  scope :versement_uniques, -> { where(versement_unique: true) }
  scope :versement_mensuels, -> { where(versement_unique: false) }

  scope :periode_eteint, -> (date_debut, date_fin) { where("date_eteint > ? AND date_eteint < ?", date_debut, date_fin) }
  scope :periode_activation, -> (date_debut, date_fin) { where("date_activation_insp > ? AND date_activation_insp < ?", date_debut, date_fin) }
  scope :periode_suspension, -> (date_debut, date_fin) { where("date_suspension > ? AND date_suspension < ?", date_debut, date_fin) }
  scope :sortie_majorations, -> (date_debut, date_fin) { where("date_sortie_majoration > ? AND date_sortie_majoration < ?", date_debut, date_fin) }
  scope :allocataires_actifs, -> { where(etat: :actif).where.not(date_activation_insp: nil) }
  scope :allocataires_eteints, -> { where(etat: :eteint).where.not(date_eteint: nil) }
  scope :allocataires_affilies_association, -> { where(etat: :actif).where.not(admin_association_allocataire_id: nil) }
  #scope :majeur_current_month, -> { joins(:enfants).where("created_at > ? AND created_at < ?", Time.now.beginning_of_month, Time.now.end_of_month) }

  before_save :set_date_recalcul_points_majoration, :log_changed, :set_mode_paiement
  before_create :set_agence_paiement
  before_create :set_region

  after_save :generate_compta_transaction

  # ransacker :etat, formatter: proc { |v| etats[v] }

  def full_name
    "#{prenom} #{nom}"
  end

  def points_base
    points_base_rc + points_base_rg
  end

  def points_gratuits_rc
    (points_base_rc || 0) + (point_minoration_rc || 0) - (points_rc || 0)
  end

  def points_gratuits_rg
    (points_base_rg || 0) + (point_minoration_rg || 0) - (points_rg || 0)
  end

  def points_gratuits
    (points_gratuits_rc || 0) + (points_gratuits_rg || 0)
  end

  def nombre_annee_cotisation
    carrieres_prestation.map(&:exercice).uniq.count
  end

  def enfants_majoration
    Enfant.where(id: [enfant1_id, enfant2_id, enfant3_id].compact)
  end

  def enfants_pas_en_charge
    enfants.where.not(id: [enfant1_id, enfant2_id, enfant3_id].compact)
  end

  def set_date_recalcul_points_majoration
    self.date_recalcul_points_majoration = enfants_majoration.map(&:date_fin_mineur).min
  end

  def set_date_sortie_majoration
    self.date_sortie_majoration = [date_fin_enfant1, date_fin_enfant2, date_fin_enfant3].compact.max
    self.save
  end

  def recalculer_points_majoration(date_reference = Date.today)
    return if versement_unique?

    new_taux = recalcul_taux_majoration(date_reference)

    self.pourcentage_majoration = new_taux
    self.pourcentage_majoration_rg = new_taux
    self.pourcentage_majoration_rc = new_taux

    self.point_majoration_rg = (points_base_rg * new_taux / 100.0).round
    self.point_majoration_rc = (points_base_rc * new_taux / 100.0).round
    self.point_majoration = self.point_majoration_rg + self.point_majoration_rc

    self.points_servis_rg = (points_base_rg + self.point_majoration_rg).ceil
    self.points_servis_rc = (points_base_rc + self.point_majoration_rc).ceil
    self.points_servis = self.points_servis_rg + self.points_servis_rc

    self.montant_brut_rg = recalcul_allocation_regime_general
    self.montant_brut_rc = recalcul_allocation_regime_cadre

    m_net = self.montant_brut_rg + self.montant_brut_rc
    allocation_point_base = recalcul_allocation_point_base_rc + recalcul_allocation_point_base_rg
    subvention = 35_000 - [35_000, allocation_point_base].min

    self.montant_net = m_net + subvention
    self.montant_subvention = subvention

    self.save
  end

  def recalculer_allocation(date_reference = Date.today)
    return if versement_unique?

    if retraite?
      recalculer_points_majoration(date_reference)
    # elsif veuve? or orphelin?
    #   self.montant_brut_rg = recalcul_allocation_regime_general
    #   self.montant_brut_rc = recalcul_allocation_regime_cadre
    #
    #   m_net = self.montant_brut_rg + self.montant_brut_rc
    #   subvention = 0 # 35_000 - [35_000, m_net].min
    #
    #   self.montant_net = m_net + subvention
    #   self.montant_subvention = subvention
    #
    #   self.save
    end
  end

  def date_sortie_enfant1
    date_fin_enfant1
  end

  def date_sortie_enfant2
    date_fin_enfant2
  end

  def date_sortie_enfant3
    date_fin_enfant3
  end

  def generate_compta_transaction
    return unless actif?
    return unless retraite? or veuve? or orphelin?
    return if ComptaTransaction.exists?(dossier: self)

    if versement_unique?
      compta_trans = ComptaTransaction.create(
        dossier: self,
        code_operation: 'I_BPAC',
        code_classe_evenement: 'LIQUIDATION',
        code_agence_liquidation: 'I_SG',
        numero_allocataire: numero_allocataire,
        nom: nom,
        prenom: prenom,
        adresse: adresse_rue,
        mode_paiement: mode_paiement,
        code_banque_allocataire: compte_bancaire_code_banque,
        numero_compte_allocataire: rib,
        bank_id: bank_id,
        bank_branch_id: bank_branch_id,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: montant_net,
        code_devise: 'XOF',
        statut: :en_cours,
        description: "Versement unique allocataire #{numero_allocataire}",
        admin_region: admin_region,
        zone: zone,
        admin_agence: admin_agence,

        nin_allocataire: numero_identification_nationale,
        telephone_allocataire: telephone,
        mail_allocataire: email,

        infos_paiement_id_bhs: infos_paiement_id_bhs,
        infos_paiement_id_ccp: infos_paiement_id_ccp,
        infos_paiement_libelle_ccp: infos_paiement_libelle_ccp,
        infos_paiement_succursale_cncas: infos_paiement_succursale_cncas,
      )

      if compta_trans.persisted?
        self.etat = :eteint
        self.date_eteint = DateTime.now
        self.save
      end
    elsif not rappel_depose?
      compta_trans = ComptaTransaction.create(
        dossier: self,
        code_operation: 'I_BPAC',
        code_classe_evenement: 'LIQUIDATION',
        code_agence_liquidation: 'I_SG',
        numero_allocataire: numero_allocataire,
        nom: nom,
        prenom: prenom,
        adresse: adresse_rue,
        mode_paiement: mode_paiement,
        code_banque_allocataire: compte_bancaire_code_banque,
        numero_compte_allocataire: rib,
        bank_id: bank_id,
        bank_branch_id: bank_branch_id,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: montant_rappel,
        code_devise: 'XOF',
        statut: :en_cours,
        description: "Rappel allocataire #{numero_allocataire}",
        admin_region: admin_region,
        zone: zone,
        admin_agence: admin_agence,

        nin_allocataire: numero_identification_nationale,
        telephone_allocataire: telephone,
        mail_allocataire: email,

        infos_paiement_id_bhs: infos_paiement_id_bhs,
        infos_paiement_id_ccp: infos_paiement_id_ccp,
        infos_paiement_libelle_ccp: infos_paiement_libelle_ccp,
        infos_paiement_succursale_cncas: infos_paiement_succursale_cncas,
      )

      if compta_trans.persisted?
        self.rappel_depose = true
        self.save
      end
    end
  end

  def nombre_enfants_mineurs(date_reference = Date.today)
    n = 0
    if not date_fin_enfant1.nil? and date_fin_enfant1 >= date_reference
      n += 1
    end
    if not date_fin_enfant2.nil? and date_fin_enfant2 >= date_reference
      n += 1
    end
    if not date_fin_enfant3.nil? and date_fin_enfant3 >= date_reference
      n += 1
    end
    n
  end

  # @param [Date] date_debut
  # @param [Date] date_fin
  # @return [Array]
  def dates_sorties_enfants_periode(date_debut, date_fin)
    puts "========> #{date_debut} -> #{date_fin}  -> #{date_sortie_enfant1} -> #{date_sortie_enfant2} -> #{date_sortie_enfant3}"
    r = []
    if not date_sortie_enfant1.nil? and (date_debut <= date_sortie_enfant1) and (date_sortie_enfant1 <= date_fin)
      r << date_sortie_enfant1
    end
    if not date_sortie_enfant2.nil? and (date_debut <= date_sortie_enfant2) and (date_sortie_enfant2 <= date_fin)
      r << date_sortie_enfant2
    end
    if not date_sortie_enfant3.nil? and (date_debut <= date_sortie_enfant3) and (date_sortie_enfant3 <= date_fin)
      r << date_sortie_enfant3
    end
    r.sort
  end

  def regime_allocataire
    if regime == 1
      "GENERAL"
    elsif regime == 2
      "CADRE"
    elsif regime == 3
      "EMPLOYES DE MAISON"
    end
  end

  def calcul_points_regime_general
    carrieres_prestation.valide.regime_general.sum(&:points)
  end

  def calcul_points_regime_cadre
    carrieres_prestation.valide.regime_cadre.sum(&:points)
  end

=begin

  def self.update_affiliation(file, user_id)
    rows = CSV.read(file.path, col_sep: ';', headers: :first_row)
    user = User.find(user_id)
    associationAllocataire = Admin::AssociationAllocataire.find_by_name(row[1])

    rows.each { |row|
      unless associationAllocataire.nil?
        allocataire = Allocataire.find_by_numero_allocataire(row[0])
        allocataire.affiliation_association = associationAllocataire
        allocataire.save
      end
    }
  end
=end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |allocataire|
        csv << allocataire.attributes.values_at(*column_names)
      end
    end
  end

  def self.my_import(file, user_id, status)
    rows = CSV.read(file.path, col_sep: ';', headers: :first_row)

    rows.each { |row|
      allocataire = Allocataire.find_by_numero_allocataire(row[0])
      unless allocataire.nil?
        allocataire.etat = status
        allocataire.save
      end
    }
  end

  def echeances_manquantes
    e = EcheancePaiement.joins(:ordre_paiements).where(ordre_paiements: {dossier: self}).order('annee desc, numero_periode desc').first
    if e.nil?
      EcheancePaiement.none
    else
      EcheancePaiement.where("date(created_at) >= '2023-02-01' and (annee > ? or (annee = ? and numero_periode > ?))", e.annee, e.annee, e.numero_periode)
    end
  end

  private

  def load_enfants_majoration
    enfants.valide.mineurs.
      where("date_naissance <= ?", date_soumission || created_at).
      order('date_naissance DESC, created_at').
      limit(3)
  end

  def recalcul_taux_majoration(date_reference = Date.today)
    taux = [15, 5 * nombre_enfants_mineurs(date_reference)].min
    (1.0 * taux)
  end

  # pour versement mensuel uniquement
  def recalcul_allocation_regime_general
    # bareme_pension = Admin::TypeRegime.find_by(code: 'GENERAL').admin_bareme_pensions.en_cours.last
    # vp = bareme_pension.valeur_point_mensuelle
    vp = Admin::BaremePension.get_valeur_point_mensuelle_rg
    (points_servis_rg * vp).ceil
  end

  # pour versement mensuel uniquement
  def recalcul_allocation_regime_cadre
    # bareme_pension = Admin::TypeRegime.find_by(code: 'CADRE').admin_bareme_pensions.en_cours.last
    # vp = bareme_pension.valeur_point_mensuelle
    vp = Admin::BaremePension.get_valeur_point_mensuelle_rc
    (points_servis_rc * vp).ceil
  end

  def recalcul_allocation_point_base_rg
    vp = Admin::BaremePension.get_valeur_point_mensuelle_rg
    (points_base_rg * vp).ceil
  end

  def recalcul_allocation_point_base_rc
    vp = Admin::BaremePension.get_valeur_point_mensuelle_rc
    (points_base_rc * vp).ceil
  end

  def log_changed
    if self.changed?
      self.changed.each do |attr|
        Historique.create(:allocataire_id => self.id, :field => attr, :new_value => self.attributes[attr], :old_value => changed_attributes[attr])
      end
    end
  end

  def set_agence_paiement
    self.admin_agence = Admin::Agence.find_by(code_psrm: 'I_SG') if caisse_ipres? and admin_agence.nil?
  end

  def set_region
    self.admin_region = Admin::Region.find_by(code: 1) if admin_region.nil?
  end

  def set_mode_paiement
    if (self.wave? or self.orange_money?) and (telephone.nil? or telephone.empty?)
      self.mode_paiement = :caisse_ipres
    end
  end

  def set_etat_creation_liquidation!
    liquidation_retraite.create! unless user.nil?
    migrate_user_to_salarie!
  end

  def migrate_user_to_salarie!
    user = User.allocataire.find_by(numero_salarie: numero_affiliation)
    user.allocataire! unless user.nil?
  end
end
