class AtConsolidation < ApplicationRecord
  include Documentable
  TYPE_DOCUMENT_OBLIGATOIRE = {
    certificat_medical_consolidation: 42
  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      pv_enquete: 44,
      bulletin_salaire_precedent_accident: 45,
      rapport_evaluation_medecin: 43,
      accord_sur_ipp: 88,
    }
  ).freeze
  include WorkflowActiverecord
  InvalidTransitionError = Class.new(StandardError)
  workflow_column :workflow_state

  workflow do
    state :creation do
      event :est_soumis_chef_agence, transition_to: :soumis_chef_agence
      event :est_soumis_chef_service, transition_to: :soumis_chef_service
    end

    state :soumis_chef_agence do
      event :est_soumis_mc, transition_to: :soumis_mc
      event :retour_creation, transition_to: :creation

    end

    state :soumis_chef_service do
      event :est_soumis_mc, transition_to: :soumis_mc
      event :retour_creation, transition_to: :creation
    end

    state :soumis_mc do
      event :est_valide_mc, transition_to: :valide_mc
      event :retour_soumis_chef_service, transition_to: :soumis_chef_service
      event :retour_soumis_chef_agence, transition_to: :soumis_chef_agence
    end

    state :valide_mc do
      event :est_affectation_technicien, transition_to: :affectation_technicien
      event :retour_soumis_mc, transition_to: :soumis_mc
    end

    state :affectation_technicien do
      event :est_verifie_tableau_rente, transition_to: :verifie_tableau_rente
      event :retour_valide_mc, transition_to: :valide_mc
    end

    state :verifie_tableau_rente do
      event :est_chef_agence_valide, transition_to: :chef_agence_valide
      event :est_chef_service_valide, transition_to: :chef_service_valide
      event :retour_affectation_technicien, transition_to: :affectation_technicien
    end

    state :chef_agence_valide do
      event :est_chef_service_valide, transition_to: :chef_service_valide
      event :retour_verifie_tableau_rente, transition_to: :verifie_tableau_rente
    end

    state :chef_service_valide do
      event :est_directeur_at_valide, transition_to: :directeur_at_valide
      event :retour_verifie_tableau_rente, transition_to: :verifie_tableau_rente
      event :retour_chef_agence_valide, transition_to: :chef_agence_valide
    end

    state :directeur_at_valide do
      event :est_audit_valide, transition_to: :audit_valide
      event :retour_chef_service_valide, transition_to: :chef_service_valide
    end

    state :audit_valide do
      event :est_dossier_valide, transition_to: :dossier_valide
      event :retour_directeur_at_valide, transition_to: :directeur_at_valide
    end
    state :dossier_valide
  end

  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  belongs_to :valide_chef_service_par, class_name: 'User', foreign_key: :valide_chef_service_par_id, optional: true
  belongs_to :valide_chef_agence_par, class_name: 'User', foreign_key: :valide_chef_agence_par_id, optional: true
  belongs_to :valide_dir_at_par, class_name: 'User', foreign_key: :valide_dir_at_par_id, optional: true
  belongs_to :valide_dg_par, class_name: 'User', foreign_key: :valide_dg_par_id, optional: true

  belongs_to :arret_travail
  has_many :carrieres_prestation, class_name: 'Carriere', foreign_key: :numero_affiliation, primary_key: :numero_affiliation
  has_many :carrieres, class_name: 'Psrm::Carriere', foreign_key: :matric, primary_key: :numero_affiliation
  has_many :at_salaires
  belongs_to :rentier, optional: true
  validates_uniqueness_of :arret_travail_id, message: "Une seule demande de consolidation est autosiré"
  after_save :create_rentier!, if: :dossier_valide?
  after_save :derniers_douze_salaire!, if: :affectation_technicien?
  validate :validate_date_consolidation_medecin_traitant

  scope :en_attente_soumission, -> { where(workflow_state: [:creation]) }
  scope :consolidations_soumises_chef_agence, -> { where(workflow_state: [:soumis_chef_agence]) }
  scope :consolidations_soumises_chef_service, -> { where(workflow_state: [:soumis_chef_service]) }
  scope :en_attente_validation_mc, -> { where(workflow_state: [:soumis_mc]) }
  scope :en_attente_affectation_tech, -> { where(workflow_state: [:valide_mc]) }
  scope :en_attente_verification, -> { where(workflow_state: [:affectation_technicien]).where.not(affectation_technicien: nil) }
  scope :tableau_rente_verifie, -> { where(workflow_state: [:verifie_tableau_rente]) }
  scope :en_attente_validation_chef_service_at, -> { where(workflow_state: [:chef_agence_valide]) }
  scope :en_attente_validation_dir_at, -> { where(workflow_state: [:chef_service_valide]) }
  scope :en_attente_validation_audit, -> { where(workflow_state: [:directeur_at_valide]) }
  scope :en_attente_validation_dg, -> { where(workflow_state: [:audit_valide]) }

  def information_consolidation!(est_valide = true)
    update(information_consolidation_valide: est_valide)
  end

  def documents_valide!(est_valide = true)
    if est_valide

      #return false if documents.certificat_medical_consolidation.empty? and date_consolidation.nil?
      #return false if documents.rapport_evaluation_medecin.empty?
      return false if documents.certificat_medical_consolidation.empty?
      #return false if documents.bulletin_salaire_precedent_accident.empty?
      update(documents_valide: est_valide)
    else
      update(documents_valide: est_valide)
    end
    true
  end

  def valider_decision_mc!(est_valide = true)
    if est_valide

      return false if avis_mc.nil? and taux_ipp_mc.nil?
      return false if accord_taux_ipp == false

      update(decision_mc_valide: est_valide)
    else
      update(decision_mc_valide: est_valide)
    end
    true
  end

  def information_salaire_valide!(est_valide = true)
    nb_salaire = at_salaires.map { |salaire| salaire.montant }.count
    if est_valide
      return false if nb_salaire < 12
      update(information_salaire_valide: est_valide)
    else
      update(information_salaire_valide: est_valide)

    end
    true
  end

  def valide_nb_salaire_annuel?
    nb_salaire = at_salaires.map { |salaire| salaire.montant }.count

    if nb_salaire == 12
      puts "=== ok", nb_salaire
      return true
    else
      puts "=== no", nb_salaire
      return false
    end

  end

  def tableau_rente_valide!(est_valide = true)
    update(tableau_rente_valide: est_valide)
  end

  def pret_pour_soumission(current_user)
    information_consolidation_valide and
      documents_valide and
      (current_user.technicien_at? || current_user.technicien_direction_at?)
  end

  def pret_pour_validation_mc?(current_user)
    current_user.medecin_conseil? and
      soumis_mc? and (!taux_ipp_mc.nil? or !taux_ipp_medecin_expert) and
      decision_mc_valide
  end

  def valide_onglet_consolidation
    information_consolidation_valide and
      documents_valide and
      information_salaire_valide and
      tableau_rente_valide
  end

  def can_affecte_tech(current_user)
    (current_user.chef_division_at? || current_user.chef_agence?) and
      valide_mc?
  end

  def chef_agence_can_valide(current_user)
    (current_user.chef_agence?) and
      verifie_tableau_rente?
  end

  def chef_service_at_can_valide(current_user)
    current_user.chef_division_at? and
      (verifie_tableau_rente? or chef_agence_valide?)
  end

  def tech_can_valide(current_user)
    tableau_rente_valide and
      (current_user.technicien_at? || current_user.technicien_direction_at?) and
      affectation_technicien?
  end

  def dir_at_can_valide(current_user)
    (current_user.directeur_at?) and
      chef_service_valide?
  end

  def auditeur_can_valide(current_user)
    (current_user.auditeur_css?) and
      directeur_at_valide?
  end

  def dg_can_valide(current_user)
    (current_user.directeur_general?) and
      audit_valide?
  end

  def salaire_mensuel_rg
    if !carrieres.nil?
      puts "OK"
      salaire = arret_travail.carrieres.map { |carriere| carriere.salaire_rg }.last
    else
      puts "PAS OK"
      return 0
    end
  end

  def salaire_mensuel_rc
    if !carrieres.nil?
      puts "OK"
      salaire = arret_travail.carrieres.map { |carriere| carriere.salaire_rcc }.last
    else
      puts "PAS OK"
      return 0
    end
  end

  def salaire_mensuel
    !salaire_mensuel_rc.nil? ? salaire_mensuel_rc : salaire_mensuel_rg
  end

  def salaire_annuel1
    puts "SALAIRE MENSUEL", salaire_mensuel
    if !salaire_mensuel.nil?
      return salaire_mensuel * 12
    else
      return 0
    end
  end

  def nb_mois_payes
    return at_salaires.map { |sal| sal.montant > 0 }.count
  end

  def calcul_salaire_annuel
    unless nb_mois_payes <= 0
      salaire_annuel = (at_salaires.map { |salaire| salaire.montant }.sum / nb_mois_payes) * 12
      return salaire_annuel
    else
      return 0
    end
  end

  def salaire_annuel_reduit_a
    annee_accident = arret_travail.date_accident.year
    plafond = Admin::SalaireAnnuel.find_by(annee: annee_accident).plafond.to_f

    if !plafond.nil? and calcul_salaire_annuel > plafond
      return plafond
    else
      return 0
    end
  end

  def salaire_annuel_porte_a
    annee_accident = arret_travail.date_accident.year
    plancher = Admin::SalaireAnnuel.find_by(annee: annee_accident).plancher.to_f

    if !plancher.nil? and calcul_salaire_annuel < plancher
      return plancher
    else
      return 0
    end

  end

  def salaire_annuel
    if salaire_annuel_porte_a != 0
      return salaire_annuel_porte_a
    elsif salaire_annuel_reduit_a != 0
      return salaire_annuel_reduit_a
    else
      calcul_salaire_annuel
    end
  end

  def date_consolidation_retenu
    return date_consolidation_medecin_expert if !date_consolidation_medecin_expert
    return date_consolidation_medecin_conseil if !date_consolidation_medecin_conseil.nil?
    return date_consolidation_medecin_traitant if !date_consolidation_medecin_traitant.nil?
  end

  def date_depart_rente
    date_depart_rente = date_consolidation_medecin_conseil + 1.day
    return date_depart_rente
  end

  def date_liquidation
    #return date_validation_chef_service unless date_validation_chef_service.nil?
    return Date.today
  end

  def nombre_jours_echus
    if date_liquidation.nil? and date_depart_rente.nil? and date_depart_rente >= date_liquidation
      return 0
    else
      ecart_time = (date_liquidation.to_time - date_depart_rente.to_time).to_i
      ecart_hour = ecart_time / 3600
      ecart_jour = (ecart_hour / 24 + 1)
    end
    return ecart_jour
  end

  def taux_ipp_retenu
    return taux_ipp_medecin_expert if !taux_ipp_medecin_expert.nil?
    return taux_ipp_mc if !taux_ipp_mc.nil?
    return taux_ipp_medecin_traitant if !taux_ipp_medecin_traitant.nil?
    return 0
  end

  def taux_utile
    if taux_ipp_retenu <= 50
      return taux_ipp_retenu.to_f / 2
    else
      taux_ipp_retenu > 50
      return ((50 / 2) + (taux_ipp_retenu - 50) / 2 + (taux_ipp_retenu - 50))
    end
  end

  def age_conversion
    return (date_consolidation_medecin_conseil.year - arret_travail.date_de_naissance_salarie.year)
  end

  def prix_franc_rente
    puts "AGE Conversion", age_conversion
    if age_conversion <= 80
      return Admin::Rente.find_by(age: age_conversion).prix
    else
      return Admin::Rente.find_by(age: 80).prix
    end
  end

  def capital
    return (salaire_annuel * (taux_utile.to_f / 100) * prix_franc_rente).round
  end

  def montant_annuel_rente
    return salaire_annuel * (taux_utile.to_f / 100)
  end

  def versement_unique?
    return true if taux_ipp_retenu > 0 and taux_ipp_retenu <= 10
  end

  def versement_trimeste?
    return true if taux_ipp_retenu > 10 and taux_ipp_retenu < 100
  end

  def versement_mensuel?
    return true if taux_ipp_retenu == 100
  end

  def montant_majoration
    if versement_mensuel?
      return (salaire_annuel * 40 / 100)
    else
      return 0
    end

  end

  def rente_majoree
    return (montant_annuel_rente + montant_majoration)
  end

  def montant_rente_trimestre
    return montant_annuel_rente / 4 if versement_trimeste?
  end

  def rente_versement_unique
    return capital if versement_unique?
  end

  def montant_average
    if versement_mensuel?
      return (montant_mensuel * nombre_jours_echus / 30).round
    end
    if versement_trimeste?
      return (montant_rente_trimestre * nombre_jours_echus / 90).round
    end
  end

  def type_versement_rente
    if taux_ipp_retenu > 0 and taux_ipp_retenu <= 10
      return " versement unique"
    elsif taux_ipp_retenu > 10 and taux_ipp_retenu <= 99
      return "versement par trimestre"
    else
      return "versement mensuel"
    end
  end

  def montant_mensuel
    return (rente_majoree / 12)
  end

  def can_see_accord?(current_user)
    !taux_ipp_mc.nil? and accord_taux_ipp? and current_user.medecin_conseil?
  end

  def montant_versement
    if versement_unique?
      return rente_versement_unique
    elsif versement_trimeste?
      return montant_annuel_rente
    else
      return rente_majoree
    end
  end

  private

  def derniers_douze_salaire!
    unless AtSalaire.exists?(at_consolidation_id: id)
      puts "======12 dernier bulletins"
      last_month = arret_travail.date_accident.month
      puts "======12 dernier bulletins",
           for i in 1..12
             salaire = AtSalaire.new
             next_month = last_month + i
             salaire.mois = next_month if next_month <= 12
             salaire.mois = next_month - 12 if next_month > 12
             salaire.montant = arret_travail.salaire_reference
             salaire.arret_travail_id = arret_travail.id
             salaire.at_consolidation_id = id
             salaire.save
           end
    end
  end

  def create_rentier!
    puts "======RENTIER"
    unless Rentier.exists?(numero_rentier: arret_travail.numero_affiliation)
      puts "======RENTIER111"
      rentier = Rentier.new(
        numero_rentier: arret_travail.numero_affiliation,
        numero_sinistre: arret_travail.num_dossier,
        nom: arret_travail.nom_salarie,
        prenom: arret_travail.prenom_salarie,
        email: arret_travail.email,
        lieu_naissance: '',
        sexe: arret_travail.sexe,
        date_naissance: arret_travail.date_de_naissance_salarie,
        date_consolidation: date_consolidation_medecin_conseil,
        date_depart_rente: date_depart_rente,
        etat: :inactif,
        telephone: arret_travail.telephone,
        age_conversion: age_conversion,
        salaire_mensuel: salaire_mensuel,
        salaire_annuel: salaire_annuel,
        taux_utile: taux_utile,
        taux_ipp_retenu: taux_ipp_retenu,
        prix_franc_rente: prix_franc_rente,
        type_versement: type_versement_rente,
        montant_net: montant_versement,
        type_rente: "victime",
        montant_rente_mensuel: montant_mensuel,
        montant_rente_trimestre: montant_rente_trimestre,
        montant_versement_unique: rente_versement_unique,
        montant_majoration: montant_average,
        rente_majoree: rente_majoree,
      )
      if rentier.save
        self.rentier = rentier
        self.save
      end

    end
  end

  def validate_date_consolidation_medecin_traitant
    if date_consolidation_medecin_traitant <= arret_travail.date_accident
      errors.add(:date_consolidation_medecin_traitant, "doit etre supérieure à la date accident (#{arret_travail.date_accident.strftime("%d/%m/%Y")}) ")
    end
  end

  def arrondir_cfa(mnt)
    arr = mnt.round
    while arr % 5 != 0 do
      arr = arr.next
    end
    arr
  end

  def multiple_de_4(mnt)
    arr = mnt.round
    while arr % 4 != 0 do
      arr = arr.next
    end
    arr
  end

end
