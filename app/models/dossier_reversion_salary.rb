class DossierReversionSalary < ApplicationRecord
  include Documentable

  TYPE_DOCUMENT_ORPHELIN_OBLIGATOIRE = {
    extrait_naissance: 2,
    carte_identite_tuteur: 24,
    certificat_tutelle: 25,
    demande_reversion_orphelin: 63
  }.freeze

  TYPE_DOCUMENT_ORPHELIN = TYPE_DOCUMENT_ORPHELIN_OBLIGATOIRE.merge(
    {
      copie_cni_legalise: 17,
      certificat_travail: 12,
      rib: 10,
      certificat_vie_collectif: 81,
    }
  ).freeze

  TYPE_DOCUMENT_VEUVE_OBLIGATOIRE = {
    copie_cni_legalise: 17,
    certificat_mariage: 4,
    certificat_non_divorce: 14,
    demande_reversion_veuve: 64
  }.freeze

  TYPE_DOCUMENT_VEUVE = TYPE_DOCUMENT_VEUVE_OBLIGATOIRE.merge(
    {
      declaration_sur_honneur: 20,
      jug_here_cert_non_opp_non_app: 23,
      certificat_travail: 12,
      extrait_naissance_defunt: 16,
      extraits_naissance_enfant: 65,
      certificat_vie_individuelle: 62,
      rib: 10,
      certificat_vie_collectif: 81,
    }
  ).freeze

  ETAT = {
    creation: 0,
    complete: 1,
    soumis: 2,
    recap_soumis: 3,
    recap_valide: 4,
    valide: 5,
    rejete: 6
  }.freeze

  enum etat: ETAT

  enum mode_paiement: MODE_PAIEMENT

  TYPE_AYANT_DROIT = {
    veuve: 1,
    orphelin: 2
  }.freeze

  enum type_ayant_droit: TYPE_AYANT_DROIT

  belongs_to :conjoint, optional: true
  belongs_to :enfant, optional: true
  belongs_to :base_reversion_salary, :class_name => 'BaseReversionSalary', foreign_key: :base_reversion_salary_id, optional: true
  has_one_attached :document

  belongs_to :traite_par, class_name: 'User', foreign_key: :traite_par_id, optional: true
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :instruit_par, class_name: 'User', foreign_key: :instruit_par_id, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :affecter_a, optional: true
  belongs_to :allocataire, optional: true

  validates :conjoint_id, presence: true, uniqueness: { message: 'Une demande de reversion existe déjà pour cette personne' }, if: :veuve?
  validates :enfant_id, presence: true, uniqueness: { message: 'Une demande de reversion existe déjà pour cette personne' }, if: :orphelin?

  #validates :compte_bancaire_code_banque, :compte_bancaire_nom_banque, :compte_bancaire_code_guichet, :compte_bancaire_numero_compte,
  #          presence: true,
  #          if: :virement?

  validate :validate_eligible

  scope :eligibles, -> { where(eligible: :true) }
  scope :non_eligibles, -> { where(eligible: :false) }

  before_create :set_numero_dossier
  # after_save :create_allocataire!
  #before_save :set_infos_beneficiaires!

  # after_create :update_allocataire!

  def part
    return 0 unless eligible?
    if veuve?
      n = base_reversion_salary.nombre_veuves_eligibles
      n.zero? ? 0 : base_reversion_salary.part_veuves / n
    else
      n = base_reversion_salary.nombre_orphelins_eligibles
      n.zero? ? 0 : base_reversion_salary.part_orphelins / n
    end.ceil(1)
  end

  def age
    date_fin = Date.today
    age = date_fin.year - date_naissance.year
    age -= 1 if date_fin < date_naissance + age.years
    age
  end

  def age_enfant
    # date_fin = Date.today
    date_fin = created_at
    age = date_fin.year - enfant.date_naissance.year
    age -= 1 if date_fin < enfant.date_naissance + age.years
    age
  end

  def age_conjoint
    date_fin = Date.today
    age = date_fin.year - conjoint.date_naissance.year
    age -= 1 if date_fin < conjoint.date_naissance + age.years
    age
  end

  def nb_mois_avant_majeur
    date_debut = Date.today
    date_fin = date_naissance + 21.years
    nb_jours = (date_fin - date_debut).to_i + 1
    (nb_jours / 30.437).ceil
  end

  def duree_mariage_avant_deces
    return 0 unless veuve? and conjoint_id?
    date_fin = base_reversion_salary.date_deces
    date_debut = conjoint.date_mariage
    age = date_fin.year - date_debut.year
    age -= 1 if date_fin < date_debut + age.years
    age
  end

  def est_mineur?
    age_enfant < 21
  end

  def nombre_enfants_mineurs
    (conjoint.enfants.valide.mariage.mineurs.count + conjoint.enfants.valide.adulterin.mineurs.count) 
  end


  def peut_etre_eligible?
    if veuve?
      return false if duree_mariage_avant_deces < 2
      return false if conjoint.deces?
      return false if conjoint.divorce?
      if base_reversion_salary.femme?
        return age >= 60
      else
        return ((age_conjoint >= 50) or nombre_enfants_mineurs >= 2)
      end
    else
      if est_mineur?
        mere_enfant = DossierReversionSalary.veuve.where(conjoint: enfant.conjoint)
        return false if mere_enfant.eligibles.exists?
        return !enfant.deces?
      end
      false
    end
  end

  def year_will_be_eligible
    if veuve?
      if base_reversion_salary.femme? and age_conjoint < 60
        return (Date.today.year + (60 - age_conjoint))
      else
        return (Date.today.year + (50 - age_conjoint))
      end
    end
  end

  def display_message
    if veuve?
      if duree_mariage_avant_deces < 2
        return "Veuf(ve) n'est pas éligible car elle n'a pas fait plus de deux ans de mariage"
      elsif base_reversion_salary.femme? and age < 60
        return "Veuf n'est pas éligible car il n'a pas l'age, sera éligible #{year_will_be_eligible}"
      elsif age_conjoint < 50 and nombre_enfants_mineurs < 2
        return "Cette veuve n'est pas éligible car elle n'a pas l'age et elles sera éligible en #{year_will_be_eligible}"
      elsif conjoint.deces?
        return "N'est pas éligilible car décédé(e) le #{conjoint.date_deces.strftime("%d/%m/%Y")}"
      elsif conjoint.divorce?
        return "N'est pas éligilible car divorcé"
      else
        if age_conjoint > 50 or (base_reversion_salary.femme? and age < 60)
          return "Conjoint eligible car elle a l'age"
        end
        if nombre_enfants_mineurs >= 2
          return "Conjoint eligible car elle a deux enfants mineurs"
        end
      end
    else
      if DossierReversionSalary.veuve.where(conjoint: enfant.conjoint).eligibles.exists?
        return " Orphelin n'est pas éligible car majoré par sa mere"
      elsif !est_mineur?
        return "Orphelin n'est pas éligible car il est majeur"
      elsif enfant.deces?
        return "N'est pas éligible car décédé(e) le  #{enfant.date_deces.strftime("%d/%m/%Y")}"
      else
        return "Orphelin est éligible car il est mineur"
      end
    end
  end

  def nb_veuves_peut_etre_eligibles
    conjoints = base_reversion_salary.conjoints
    nb = 0
    conjoints.each do |conjoint|
      if (base_reversion_salary.date_deces.year - conjoint.date_mariage.year) > 2
        nb = nb + 1
      end
    end
    nb
  end

  def taux_majoration
    return 0 if orphelin?
    nombre_enfants_mineurs = conjoint.enfants.valide.mineurs.
      where("date_naissance <= ?", DateTime.now).count
    taux = [15, 5 * nombre_enfants_mineurs].min
    (1.0 * taux)
  end

  def calcul_points_base_rc
    (1.0 * part * base_reversion_salary.calcul_points_base_regime_cadre / 100).ceil
  end

  def calcul_points_base_rg
    (1.0 * part * base_reversion_salary.calcul_points_base_regime_general / 100).ceil
  end

  def calcul_points_base
    calcul_points_base_rg + calcul_points_base_rc
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
    # da.beginning_of_month == base_reversion_salary.created_at.beginning_of_month ? da.next_month.beginning_of_month : da.beginning_of_month
    da = date_ouverture || created_at || Date.today
    dj = da.beginning_of_bimester

    if base_reversion_salary.date_deces > dj
      dj = base_reversion_salary.date_deces.beginning_of_month + 1.months
    end

    dj
  end

  def calcul_montant_rappel
    return 0 unless versement_mensuel? 
    montant_net = calcul_allocation
    date_validation = valider_le || Date.today
    nombre_mois = (date_validation.year * 12 + date_validation.month) - (calcul_date_jouissance.year * 12 + calcul_date_jouissance.month)
    nombre_jours = (calcul_date_jouissance.end_of_month.day - calcul_date_jouissance.day).to_i
    (([nombre_jours, 30].min * montant_net) / 30).ceil + montant_net * (nombre_mois + 1)
  end

  def etat_ayant_droit_valide!(est_valide = true)
    update(etat_ayant_droit_valide: est_valide)
  end

  def documents_valide!(est_valide = true)
    if est_valide
      if veuve?
        return false if documents.where(type_document: [:certificat_mariage]).empty?
        return false if documents.where(type_document: [:certificat_non_divorce]).empty?
        return false if documents.where(type_document: [:copie_cni_legalise]).empty?
        return false if documents.where(type_document: [:demande_reversion_veuve]).empty?
      else
        return false if documents.where(type_document: [:extrait_naissance]).empty?
        return false if documents.where(type_document: [:carte_identite_tuteur]).empty?
        return false if documents.where(type_document: [:certificat_tutelle]).empty?
        return false if documents.where(type_document: [:demande_reversion_orphelin]).empty?
      end
      update(documents_valide: est_valide)
    else
      update(documents_valide: est_valide)
    end
    true
  end

  def pret_pour_valider_dossier?
    etat_ayant_droit_valide and documents_valide
  end

  def pret_pour_soumission?
    etat_ayant_droit_valide and documents_valide
  end

  def new_numero_allocataire
    a = numero_dossier.split('/')
    a.delete_at(2)
    numero = a.join
    numero
  end

  def create_allocataire
    a = numero_dossier.split('/')
    a.delete_at(2)
    numero = a.join
    if valide? and not Allocataire.exists?(numero_allocataire: numero)
      allocataire = Allocataire.new(
        numero_allocataire: numero,
        nom: nom,
        prenom: prenom,
        date_naissance: date_naissance,
        categorie: veuve? ? :veuve : :orphelin,
        etat: :inactif,
        nombre_epouses: 0,
        nombre_enfants: veuve? ? conjoint.enfants.valide.count : 0,
        adresse_rue: adresse,
        code_pays: "SN",

        regime: self.base_reversion_salary.carrieres_prestation.regime_cadre.any? ? 2 : 1, # 1 : général, 2 : cadre
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
        mode_paiement: self.mode_paiement,
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
        montant_premier_paiement: 0
      )

      if allocataire.save
        self.update_columns(allocataire_id: allocataire.id)
      end
    end
  end

  private

  def validate_eligible
    if eligible and not peut_etre_eligible?
      errors.add(:eligible, "Cet ayant droit ne peut pas être éligible")
    end
  end

  def validate_conjoint_or_enfant
    errors.add(:conjoint_id, "Dossier pour cet ayant droit existe déjà") if DossierReversionSalary.where(conjoint_id: conjoint_id).exists?
    errors.add(:enfant_id, "Dossier pour cet ayant droit existe déjà") if DossierReversionSalary.where(enfant_id: enfant_id).exists?
  end

  def set_numero_dossier
    annee = Date.today.year
    prefixe = veuve? ? 'V' : 'O'
    dernier_dossier_ajoute = DossierReversionSalary.where(
      numero_affiliation: numero_affiliation,
      type_ayant_droit: type_ayant_droit
    ).order('created_at DESC').first

    if dernier_dossier_ajoute.nil?
      self.numero_dossier = "#{prefixe}/#{numero_affiliation}/#{annee}/01"
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
    allocataire.etat = :inactif
    allocataire.save
  end
end
