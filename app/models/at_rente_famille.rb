class AtRenteFamille < ApplicationRecord
    include MyTools
    include WorkflowActiverecord
    include Documentable
    include ActsAsWorkflowHistory
    InvalidTransitionError = Class.new(StandardError)
    workflow_column :workflow_state
    workflow do
      state :creation do
        event :est_soumis_chef_agence, transition_to: :soumis_chef_agence
        event :est_soumis_chef_service, transition_to: :soumis_chef_service

      end

      state :soumis_chef_agence do
        event :est_soumis_chef_service, transition_to: :soumis_chef_service
        event :retour_creation, transition_to: :creation
      end

      state :soumis_chef_service do
        event :est_soumis_directeur_at, transition_to: :soumis_directeur_at
        event :retour_creation, transition_to: :creation
        event :retour_soumis_chef_agence, transition_to: :soumis_chef_agence
      end

      state :soumis_directeur_at do
        event :est_soumis_audit, transition_to: :soumis_audit
        event :retour_soumis_chef_service, transition_to: :soumis_chef_service
      end

      state :soumis_audit do
        event :est_soumis_dg, transition_to: :soumis_dg
        event :retour_soumis_directeur_at, transition_to: :soumis_directeur_at
      end

      state :soumis_dg do
        event :est_dossier_valide, transition_to: :dossier_valide
        event :est_dossier_rejete, transition_to: :dossier_rejete
        event :retour_soumis_audit, transition_to: :soumis_audit
      end

      state :dossier_valide
      state :dossier_rejete
    end

      TYPE_DOCUMENT_OBLIGATOIRE = {
        certificat_deces: 11,
        bulletin_salaire_precedent_accident: 45,
        jug_here_cert_non_opp_non_app: 23,
        certificat_genre_de_mort: 59,
        pv_enquete: 44,
          
      }.freeze
  
    TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
        {
          cni_epouse: 6,
          extrait_naissance_epouse: 7,
          cni_extrait_enfant: 86,
          cni_extrait_ascendant: 87,
          certificat_mariage: 4,
          certificat_scolarite: 36,
          certificat_non_divorce: 14,
          certificat_non_remariage: 15,
        }
    ).freeze

    TYPE_AYANT_DROIT = {
        veuve: 1,
        orphelin: 2,
        ascendant: 3
    }.freeze
  
    enum type_ayant_droit: TYPE_AYANT_DROIT

    belongs_to :arret_travail, optional: true
    has_many :enfants, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
    has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
    has_many :ascendants_salaries, class_name: 'AscendantsSalarie', foreign_key: :numero_affiliation, primary_key: :numero_affiliation
    has_many :at_dossier_reversion_rentes, dependent: :destroy
    has_many :carrieres, class_name: 'Psrm::Carriere', foreign_key: :matric, primary_key: :numero_affiliation
    has_many :at_salaires

    belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
    belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par, optional: true
    belongs_to :valider_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
    belongs_to :valide_chef_service_par, class_name: 'User', foreign_key: :valide_chef_service_par_id, optional: true
    belongs_to :valide_chef_agence_par, class_name: 'User', foreign_key: :valide_chef_agence_par_id, optional: true
    belongs_to :valide_dir_at_par, class_name: 'User', foreign_key: :valide_dir_at_par_id, optional: true
    belongs_to :valide_dg_par, class_name: 'User', foreign_key: :valide_dg_par_id, optional: true
    belongs_to :validation_audit_par, class_name: 'User', foreign_key: :validation_audit_par_id, optional: true
    
    
    
    scope :en_attente_soumission, -> { where(workflow_state: [:creation]) }
    scope :soumis_chef_agence, -> { where(workflow_state: [:soumis_chef_agence]) }
    scope :soumis_chef_service, -> { where(workflow_state: [:soumis_chef_service]) }
    scope :soumis_dir_at, -> { where(workflow_state: [:soumis_directeur_at]) } 
    scope :soumis_audit, -> { where(workflow_state: [:soumis_audit]) } 
    scope :soumis_dg, -> { where(workflow_state: [:soumis_dg]) } 
    validate :validate_date_deces
    
    after_save :derniers_douze_salaire!
    
    def information_defunt!(est_valide = true)
      update(information_defunt: est_valide)
    end

    def documents_valide!(est_valide = true)
      if est_valide
        return false if documents.certificat_deces.empty?
        return false if documents.bulletin_salaire_precedent_accident.empty?
        return false if documents.certificat_genre_de_mort.empty?
        update(documents_valide: est_valide)
      else
          update(documents_valide: est_valide)
      end
         true
    end

    def epouses_valide!(est_valide = true)
      update(epouses_valide: est_valide)
    end
  
    def enfants_valide!(est_valide = true)
      update(enfants_valide: est_valide)
    end

    def valide_nb_salaire_annuel?
      nb_salaire =  at_salaires.map { |salaire| salaire.montant}.count
      if nb_salaire == 12
          puts "=== ok",nb_salaire
          return true
      else
          puts "=== no",nb_salaire
          return false
      end
    end

    def tableau_rente_valide!(est_valide = true)
      update(tableau_rente_valide: est_valide)
    end

 

    def information_salaire_valide!(est_valide = true)
      nb_salaire =  at_salaires.map { |salaire| salaire.montant}.count
      if est_valide
          return false if nb_salaire < 12
          update(information_salaire: est_valide)
      else
         update(information_salaire: est_valide)

      end
          true
    end

    def pret_pour_soumission(current_user)
      information_defunt and 
      epouses_valide and 
      enfants_valide
      documents_valide and 
      information_salaire and
      tableau_rente_valide and
      creation? and
      (current_user.technicien_at? || current_user.technicien_direction_at?)
    end

    def can_affecte_tech(current_user)
      (current_user.chef_division_at? || current_user.chef_agence?) and
      (soumis_chef_agence? || soumis_chef_service?)
    end

    def nombre_enfants
      return at_dossier_reversion_rentes.orphelin.count unless at_dossier_reversion_rentes.nil?
      return 0
    end

    def nombre_conjoints
      return at_dossier_reversion_rentes.veuve.count unless at_dossier_reversion_rentes.nil?
      return 0
    end

    def nombre_ascendants
      return  ascendants_salaries.count 
    end

    def age_conversion
      return 0 if date_deces.nil? and arret_travail.date_de_naissance_salarie.nil?
      return (date_deces.year - arret_travail.date_de_naissance_salarie.year) 
    end

  def prix_franc_rente
    return 0 if age_conversion <= 0
    if age_conversion <= 80
      return Admin::Rente.find_by(age: age_conversion).prix 
    else
      return Admin::Rente.find_by(age: 80).prix 
    end
  end

  def date_depart_rente
    date_depart_rente=date_deces + 1
    return date_depart_rente
  end

  def date_liquidation
    #return date_validation_chef_service unless date_validation_chef_service.nil?
    return Date.today
  end

  def nombre_jours_echus
    nombre_jour= ((date_liquidation + 1)- date_depart_rente).to_i
    return nombre_jour
  end

    ### Taux des ayants droit


  def taux_total_conjoints
    return 0 if nombre_conjoints == 0
    return 30 if nombre_conjoints >= 1
  end

  def taux_total_enfants
    return 0 if nombre_enfants == 0
    return 15 if nombre_enfants == 1
    return 30 if nombre_enfants == 2
    return 30 + 10 * (nombre_enfants-2) if nombre_enfants >= 3 
  end

  def taux_total_ascendants
    return 0 if nombre_ascendants == 0
    return 10 if nombre_ascendants >= 1
  end

  def taux_total
    taux_total_enfants + taux_total_conjoints + taux_total_ascendants
  end

  ### Montant total des ayants droit

  def montant_rente_total_enfants
    salaire_annuel_retenu * taux_total_enfants/100
  end

  def montant_rente_total_conjoints
    salaire_annuel_retenu * taux_total_conjoints/100
  end

  def montant_rente_total_ascendants
    salaire_annuel_retenu * taux_total_ascendants/100
  end

  ## Montant pour chaque ayant droit
  
  def montant_rente_annuel_enfant
    return montant_rente_total_enfants/nombre_enfants
  end

  def montant_rente_annuel_conjoit
    return montant_rente_total_conjoints/nombre_conjoints
  end

  def montant_rente_annuel_ascendant
    return montant_rente_total_ascendants/nombre_ascendants
  end
  
  def salaire_annuel
    salaire_annuel =  (at_salaires.map { |salaire| salaire.montant}.sum / at_salaires.size)*12
    return salaire_annuel 
  end

  def salaire_annuel_retenu
    return (salaire_annuel*85/100).round if taux_total >= 85
    return salaire_annuel if taux_total < 85
  end


  def conjoint_checked(id)
    unless conjoints_id.nil?
      id.to_s.in?(conjoints_id)? true : false  
    else
      return false
    end
  end

  def enfant_checked(id)
    unless enfants_id.nil?
      id= id.to_s
      id.in?(enfants_id)? true : false  
    else
      return false
    end
  end

    private

    def derniers_douze_salaire!
      unless AtSalaire.exists?(at_rente_famille_id: id)
        last_month = arret_travail.date_accident.month
        for i in 1..12
            salaire = AtSalaire.new
            next_month=last_month + i
                salaire.mois=next_month if next_month <= 12
                salaire.mois=next_month-12 if next_month > 12
                salaire.montant = arret_travail.salaire_reference
                salaire.arret_travail_id = arret_travail.id
                salaire.at_rente_famille_id = id
            salaire.save
        end
      end
  end

  def validate_date_deces
    if date_deces.nil?
      errors.add(:date_deces, "est obligatoire")
    elsif date_deces > date_liquidation
      errors.add(:date_deces, " doit etre antérieure à la date d'aujourd'hui ")
    elsif date_deces <= arret_travail.date_accident
      errors.add(:date_deces, " doit etre postérieure à la date d'accident ")
    end
  end

end
