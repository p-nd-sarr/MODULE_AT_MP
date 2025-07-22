class ReversionVeuve < ApplicationRecord
  include Documentable
  include HasBankAccount

  def type_document_obligatoire
    if orphelin?
      super.merge({
                    extrait_naissance: 2,
                    carte_identite_tuteur: 24,
                    certificat_tutelle: 25,
                    certificat_vie_individuelle: 62,
                    formulaire_demande: 90,
                  })
    elsif veuve?
      docs = super.merge({
                           certificat_mariage: 4,
                           certificat_non_divorce: 14,
                           copie_cni: 21,
                           formulaire_demande: 90,
                         })

      if age < 45
        docs = docs.merge({ certificat_non_remariage: 15 })
      end
      return docs
    else
      super
    end
  end

  TYPE_DOCUMENT_OBLIGATOIRE = {

  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      rib: 10,
      certificat_non_remariage: 15,
      certificat_medical: 19,
      declaration_sur_honneur: 20,
      copie_cni: 21,
      acte_etat_civil_jug_supp_veuve: 22,
      jug_here_cert_non_opp_non_app: 23,
      carte_identite_tuteur: 24,
      certificat_tutelle: 25,
      acte_naissance_enf_moins_21: 76,
      certificat_vie_collective_enf_moins_21: 77,
      actes_deces_coepouse: 93,
    }
  ).freeze

  include WorkflowActiverecord

  InvalidTransitionError = Class.new(StandardError)

  enum mode_paiement: MODE_PAIEMENT

  TYPE_AYANT_DROIT = {
    veuve: 1,
    orphelin: 2
  }.freeze

  enum type_ayant_droit: TYPE_AYANT_DROIT

  belongs_to :allocataire,
             foreign_key: :numero_allocataire,
             primary_key: :numero_allocataire

  belongs_to :conjoint, optional: true
  belongs_to :enfant, optional: true

  has_one :base_reversion, through: :allocataire

  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :instruit_par, class_name: 'User', foreign_key: :instruit_par_id, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affecter_a, optional: true
  belongs_to :admin_agence, class_name: 'Admin::Agence', foreign_key: :admin_agence_id, optional: true
  belongs_to :affecte_a, class_name: 'User', foreign_key: :affecte_a_id, optional: true
  # belongs_to :allocataire, optional: true

  validates :numero_allocataire, :type_ayant_droit, :mode_paiement,
            presence: true
  validates :conjoint_id, presence: true, uniqueness: { message: 'Une demande de reversion existe déjà pour cette personne' }, if: :veuve?
  validates :enfant_id, presence: true, uniqueness: { message: 'Une demande de reversion existe déjà pour cette personne' }, if: :orphelin?

  validates :compte_bancaire_code_banque, :compte_bancaire_nom_banque, :compte_bancaire_code_guichet, :compte_bancaire_numero_compte,
            presence: true,
            if: :virement?
  
  validates :agence_paiement_id, 
            presence: true,
            if: :caisse_ipres?,
            on: :create

  validates :nom_tuteur, :prenom_tuteur,
            presence: true,
            if: :orphelin?

  validate :validate_numero_affiliation, :validate_eligible

  scope :eligibles, -> { where(eligible: :true) }
  scope :non_eligibles, -> { where(eligible: :false) }
  scope :en_attente_allocation, -> { where(workflow_state: [:instruit]).where(affecter_allocataire: nil) }
  scope :en_attente_validation, -> { where(workflow_state: [:liquide]).where(valider_par: nil) }
  scope :en_attente_instruction, -> { where(workflow_state: [:soumis]).where(instruit_par: nil) }
  scope :en_attente_validation_recap, -> { where(workflow_state: [:instruit]) }
  scope :mes_affectations_allocataire, ->(id) { where("affecter_a = ?", id) }

  before_create :set_numero_dossier
  after_save :create_allocataire!
  before_save :set_infos_beneficiaires!

  after_create :update_allocataire!

  workflow_column :workflow_state

  workflow do
    state :creation, :meta => { label: 'Création' } do
      event :est_soumis, transition_to: :soumis
    end

    state :soumis, :meta => { label: 'Soumis' } do
      event :est_instruit, transition_to: :instruit

      event :retour_creation, transition_to: :creation
    end

    state :instruit, :meta => { label: 'Instruit' } do
      event :est_liquide, transition_to: :liquide

      event :retour_soumis, transition_to: :soumis

    end

    state :liquide, :meta => { label: 'Liquidé' } do
      event :est_valide, transition_to: :valide
      event :est_rejete, transition_to: :rejete

      event :retour_instruit, transition_to: :instruit

    end

    state :valide, :meta => { label: 'Validé' }
    state :rejete, :meta => { label: 'Rejeté' }

    on_transition do |from, to, triggering_event, *event_args|
      puts "#{from} -> #{to}"
      WorkflowHistory.create(
        dossier: self,
        from: from,
        to: to
      )
    end

    #  use after transition for historisation
    after_transition do
      puts "=> traite par : #{self.traite_par}"
    end

    on_error do |error, from, to, event, *args|
      puts "Exception(#error.class) on #{from} -> #{to}"
    end
  end

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

  def part
    return 0 unless eligible?
    if veuve?
      base_reversion.part_veuves / base_reversion.nombre_veuves_eligibles
    else
      base_reversion.part_orphelins / base_reversion.nombre_orphelins_eligibles
    end.floor(2)
  end

  def age
    date_fin = Date.today
    age = date_fin.year - date_naissance.year
    age -= 1 if date_fin < date_naissance + age.years
    age
  end

  def nb_mois_avant_majeur
    date_debut = Date.today
    date_fin = date_naissance + 21.years
    nb_jours = (date_fin - date_debut).to_i + 1
    (nb_jours / 30.437).ceil
  end

  def duree_mariage_avant_deces
    return 0 unless veuve?
    date_fin = base_reversion.date_deces
    date_debut = conjoint.date_mariage
    age = date_fin.year - date_debut.year
    age -= 1 if date_fin < date_debut + age.years
    age
  end

  def est_mineur?
    age < 21
  end

  def peut_etre_eligible?
    return false if allocataire.versement_unique?

    if veuve?
      return false if duree_mariage_avant_deces < 2

      if allocataire.femme? # pour homme
        return age >= 60
      else
        # pour femme
        return (age >= 45 or conjoint.enfants.valide.mariage.mineurs.count >= 2)
      end
    else
      return false if ReversionVeuve.veuve.with_valide_state.where(conjoint: enfant.conjoint).exists?
      est_mineur?
    end
  end

  def taux_majoration
    return 0 if orphelin?
    nombre_enfants_mineurs = conjoint.enfants.valide.mineurs.
      where("date_naissance <= ?", DateTime.now).count
    taux = [15, 5 * nombre_enfants_mineurs].min
    (1.0 * taux)
  end

  def calcul_points_gratuits_rc
    (1.0 * part * allocataire.points_gratuits_rc / 100).ceil
  end

  def calcul_points_gratuits_rg
    (1.0 * part * allocataire.points_gratuits_rg / 100).ceil
  end

  def calcul_points_gratuits
    calcul_points_gratuits_rc + calcul_points_gratuits_rg
  end

  def calcul_points_base_rc
    (1.0 * part * (allocataire.points_rc + allocataire.points_gratuits_rc) / 100).ceil
    #(1.0 * part * allocataire.calcul_points_regime_cadre / 100).ceil
  end

  def calcul_points_base_rg
    (1.0 * part * (allocataire.points_rg + allocataire.points_gratuits_rg) / 100).ceil
    #(1.0 * part * allocataire.calcul_points_regime_general / 100).ceil
  end

  def calcul_points_base
    calcul_points_base_rc + calcul_points_base_rg
  end

  def calcul_points_majoration_rc
    (1.0 * calcul_points_base_rc * taux_majoration / 100.0).ceil
  end

  def calcul_points_majoration_rg
    (1.0 * calcul_points_base_rg * taux_majoration / 100.0).ceil
  end

  def calcul_points_majoration
    calcul_points_majoration_rc + calcul_points_majoration_rg
  end

  def calcul_points_servis_rc
    calcul_points_base_rc + calcul_points_majoration_rc
  end

  def calcul_points_servis_rg
    calcul_points_base_rg + calcul_points_majoration_rg
  end

  def calcul_points_servis
    calcul_points_servis_rc + calcul_points_servis_rg
  end

  def versement_mensuel?
    calcul_points_base_rg >= 1_000
  end

  def versement_unique?
    not versement_mensuel?
  end

  def calcul_allocation_rg
    if versement_mensuel?
      valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_general_du(Date.today)
      (calcul_points_servis_rg * valeur_point_mensuelle).ceil
    else
      salaire_reference = Admin::Bareme.salaire_reference_general_du(calcul_date_jouissance.last_year)
      m1 = (calcul_points_servis_rg * salaire_reference).ceil

      if veuve?
        return m1
      else
        valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_general_du(Date.today)
        m2 = (calcul_points_servis_rg * valeur_point_mensuelle).ceil

        return [m1, nb_mois_avant_majeur * m2].min
      end
    end
  end

  def calcul_allocation_rc
    if versement_mensuel?
      valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_cadre_du(Date.today)
      (calcul_points_servis_rc * valeur_point_mensuelle).ceil
    else
      salaire_reference = Admin::Bareme.salaire_reference_cadre_du(calcul_date_jouissance.last_year)
      m1 = (calcul_points_servis_rc * salaire_reference).ceil

      if veuve?
        return m1
      else
        valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_cadre_du(Date.today)
        m2 = (calcul_points_servis_rc * valeur_point_mensuelle).ceil

        return [m1, nb_mois_avant_majeur * m2].min
      end
    end
  end

  def calcul_allocation
    calcul_allocation_rg + calcul_allocation_rc
  end

  def calcul_date_jouissance
    # da = date_ouverture || created_at || Date.today
    # da.beginning_of_month == base_reversion.date_deces.beginning_of_month ? da.next_month.beginning_of_month : da.beginning_of_month
    da = date_ouverture || created_at || Date.today
    dj = da.beginning_of_bimester

    if base_reversion.date_deces.next_month.beginning_of_month >= dj
      dj = base_reversion.date_deces.beginning_of_month + 2.months
    end

    dj
  end

  def can_affecte_gestionnaire?
    self.current_state >= :instruit
  end

  def pret_pour_soumission?
    required_document_uploaded?
  end

  def nombre_mois_majorite
    if orphelin?
      #enfant.date_fin_mineur - calcul_date_jouissance
      (enfant.date_fin_mineur.year * 12 + enfant.date_fin_mineur.month) - (calcul_date_jouissance.year * 12 + calcul_date_jouissance.month)
    end
  end

  def can_reaffect?
    self.current_state >= :liquide
  end

  def date_validation
    valider_le || Date.today
  end

  def calcul_montant_rappel
    return 0 if versement_unique?
    montant_net = calcul_allocation
    nombre_mois = (date_validation.year * 12 + date_validation.month) - (calcul_date_jouissance.year * 12 + calcul_date_jouissance.month)
    nombre_jours = (calcul_date_jouissance.end_of_month.day - calcul_date_jouissance.day).to_i

    (([nombre_jours, 30].min * montant_net) / 30).ceil + montant_net * (nombre_mois + 1)
  end

  def get_numero_allocataire
    a = numero_dossier.split('/')
    a.delete_at(2)
    a.join
  end

  private

  def create_allocataire!
    a = numero_dossier.split('/')
    a.delete_at(2)
    numero = a.join
    sexe = if veuve?
             self.allocataire.homme? ? :femme : :homme
           else
             enfant.masculin? ? :homme : :femme
           end

    if valide? and not Allocataire.exists?(numero_allocataire: numero)
      allocataire = Allocataire.new(
        numero_allocataire: numero,
        nom: nom,
        prenom: prenom,
        sexe: sexe,
        date_naissance: date_naissance,
        categorie: veuve? ? :veuve : :orphelin,
        etat: :inactif,
        nombre_epouses: 0,
        nombre_enfants: veuve? ? conjoint.enfants.valide.count : 0,
        adresse_rue: adresse,
        code_pays: "SN",

        mode_paiement: mode_paiement,
        admin_banque_agence: admin_banque_agence,
        compte_bancaire_numero_compte: compte_bancaire_numero_compte,
        compte_bancaire_cle_rib: compte_bancaire_cle_rib,
        admin_agence_id: caisse_ipres? ? (agence_paiement_id || admin_agence.try(:id)) : nil,

        regime: self.allocataire.carrieres_prestation.regime_cadre.any? ? 2 : 1, # 1 : général, 2 : cadre
        age_revolu: 0,

        versement_unique: (not versement_mensuel?),
        date_jouissance: calcul_date_jouissance,

        moyenne: 0,
        mois_gratuis: 0,
        points: 0,
        points_base: calcul_points_base,
        point_minoration: 0,
        pourcentage_majoration: taux_majoration,
        point_majoration: calcul_points_majoration,
        points_complementaires: 0,
        points_servis: calcul_points_servis,
        montant_imposable: 0,

        moyenne_rg: 0,
        mois_gratuis_rg: 0,
        points_rg: 0,
        points_base_rg: calcul_points_base_rg,
        pourcentage_minoration_rg: 0,
        point_minoration_rg: 0,
        pourcentage_majoration_rg: taux_majoration,
        point_majoration_rg: calcul_points_majoration_rg,
        points_complementaires_rg: 0,
        points_servis_rg: calcul_points_servis_rg,
        montant_brut_rg: calcul_allocation_rg,
        montant_imposable_rg: 0,
        moyenne_rc: 0,
        mois_gratuis_rc: 0,
        points_rc: 0,
        points_base_rc: calcul_points_base_rc,
        pourcentage_minoration_rc: 0,
        point_minoration_rc: 0,
        pourcentage_majoration_rc: taux_majoration,
        point_majoration_rc: calcul_points_majoration_rc,
        points_complementaires_rc: 0,
        points_servis_rc: calcul_points_servis_rc,
        montant_brut_rc: calcul_allocation_rc,
        montant_imposable_rc: 0,
        montant_net: calcul_allocation,
        montant_minimum_fiscal: 0,
        montant_igr: 0,
        montant_rappel: calcul_montant_rappel,
        montant_premier_paiement: 0,
        montant_subvention: 0,
      )

      if allocataire.save
        self.update_columns(allocataire_id: allocataire.id)
      end

      if veuve?
        enfants_du_conjoint = Enfant.where(conjoint: conjoint)

        ReversionVeuve.orphelin.where(enfant: enfants_du_conjoint).each { |r|
          a = r.numero_dossier.split('/')
          a.delete_at(2)
          numero = a.join

          allocataire_orphelin = Allocataire.find_by(numero_allocataire: numero)

          unless allocataire_orphelin.nil?
            allocataire_orphelin.date_eteint = DateTime.now
            allocataire_orphelin.eteint!
            AllocataireSuiviModification.create(allocataire: allocataire_orphelin,
                                                commentaire: "Le parent #{conjoint.full_name} ##{conjoint.id} est éligible",
                                                date_validation: DateTime.now,
                                                dossier_revision: self,
                                                impacte_montant_paiement: true)
          end
        }
      end
    end
  end

  def validate_eligible
    if eligible and not peut_etre_eligible?
      errors.add(:eligible, "Cet ayant droit ne peut pas être éligible")
    end
  end

  def validate_numero_affiliation
    return if numero_allocataire.nil?
    errors.add(:numero_affiliation, "Ce numéro d'affiliation est introuvable") unless Allocataire.where(numero_allocataire: numero_allocataire).exists?
  end

  def set_numero_dossier
    annee = Date.today.year
    prefixe = veuve? ? 'V' : 'O'

    dernier_dossier_ajoute = ReversionVeuve.where(
      numero_allocataire: numero_allocataire,
      type_ayant_droit: type_ayant_droit
    ).order('created_at DESC').first

    if dernier_dossier_ajoute.nil?
      self.numero_dossier = "#{prefixe}/#{numero_allocataire}/#{annee}/01"
    else
      a = dernier_dossier_ajoute.numero_dossier.split('/')
      a[2] = annee
      self.numero_dossier = a.join('/').next
    end
  end

  def set_infos_beneficiaires!
    if veuve?
      self.enfant = nil
    else
      self.conjoint = nil
    end

    self.prenom = (conjoint || enfant).prenom
    self.nom = (conjoint || enfant).nom
    self.date_naissance = (conjoint || enfant).date_naissance
  end

  def update_allocataire!
    allocataire_update = self.allocataire
    allocataire_update.etat = :eteint
    allocataire_update.date_eteint = DateTime.now
    allocataire_update.save
  end
end
