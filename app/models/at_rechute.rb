class AtRechute < ApplicationRecord
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
        event :est_soumis_mc, transition_to: :soumis_mc
      end

      state :soumis_chef_service do
        event :est_soumis_mc, transition_to: :soumis_mc
      end

      state :soumis_mc do
        event :est_soumis_directeur_at, transition_to: :soumis_directeur_at
      end

      state :soumis_directeur_at do
        event :est_rechute_validee, transition_to: :rechute_validee
        event :est_rechute_rejetee, transition_to: :rechute_rejetee
      end
      
      state :rechute_validee
      state :rechute_rejetee

      on_transition do |from, to, triggering_event, *event_args|
        puts "#{from} -> #{to}"
      end
  
      #  use after transition for historisation
      after_transition do
        #puts "=> traite par : #{self.traite_par}"
      end
  
      on_error do |error, from, to, event, *args|
        puts "Exception(#error.class) on #{from} -> #{to}"
      end
    end
      

    TYPE_DOCUMENT_OBLIGATOIRE = {
      certificat_travail_rechute: 95,
      bulletin_salaire_precedent_rechute: 98,
        
    }.freeze
  
    TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
      {
    
      }
    ).freeze

    MONTH_IN_FR = {
      january: 'janvier',
      february: 'fevrier',
      march: 'mars',
      april: 'avril',
      may: 'mai',
      june: 'juin',
      july: 'juillet',
      august: 'aout',
      september: 'septembre',
      october: 'octobre',
      november: 'novembre',
      december: 'decembre'
    }.freeze

    AVIS = {
      favorable: 'favorable',
      defavorable: 'défavorable'
    }
    enum avis: AVIS
  
    belongs_to :arret_travail, optional: true
    has_many :at_salaires
    has_many :at_code_prime_salaires
    accepts_nested_attributes_for :at_code_prime_salaires, :allow_destroy => true

    belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
    belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par, optional: true
    belongs_to :valide_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
    belongs_to :rejete_par, class_name: 'User', foreign_key: :rejete_par_id, optional: true

    scope :en_attente_soumission, -> { where(workflow_state: [:creation]) }
    scope :soumis_chef_agence, -> { where(workflow_state: [:soumis_chef_agence]) }
    scope :soumis_chef_service, -> { where(workflow_state: [:soumis_chef_service]) }
    scope :en_attente_avis_mc, -> { where(workflow_state: [:soumis_mc]) }
    scope :en_attente_validation_dir_at, -> { where(workflow_state: [:soumis_directeur_at]) }
    validate :validate_date_rechute
    
   
    def information_generale!(est_valide = true)
      update(information_generale: est_valide)
    end

    def documents_valide!(est_valide = true)
      if est_valide
        return false if documents.bulletin_salaire_precedent_rechute.empty?
        return false if documents.certificat_travail_rechute.empty?
        update(documents_valide: est_valide)
      else
          update(documents_valide: est_valide)
      end
         true
    end

    def information_salaire_valide!(est_valide = true)
      update(information_salaire: est_valide)
    end


    def avis_mc_valide!(est_valide = true)
      if est_valide
          return false if avis.blank? 
          return false if description_avis.blank?
          update(avis_mc_valide: est_valide)
      else
         update(avis_mc_valide: est_valide)

      end
          true
    end

    def pret_pour_soumission?(current_user)
      creation? and
      information_generale
      documents_valide and 
      information_salaire and
      (current_user.technicien_at? || current_user.technicien_direction_at?)
    end

    def can_valide?(current_user)
      (current_user.chef_division_at? || current_user.chef_agence?) and
      (soumis_chef_agence? || soumis_chef_service?)
    end

    def chef_service_can_valide?(current_user)
      (current_user.chef_division_at?) and
      (soumis_chef_service?)
    end

    def mc_can_valide?(current_user)
      current_user.medecin_conseil? and soumis_mc? and avis_mc_valide!
    end

    def dirAtCanValideOrRejete?(current_user)
      current_user.directeur_at? and soumis_directeur_at?
    end

    def salaire_reference
      at_code_salaires = self.at_code_prime_salaires.where(prise_en_compte: true).select(:montant)
      return 0 if at_code_salaires.empty?
      salaire = at_code_salaires.map(&:montant).compact.reduce(:+) || 0
      return salaire
    end

    def salaire_journalier_reference
      return salaire_reference if arret_travail.est_journalier?
      return (salaire_reference/nombre_jours_ouvres).round
    end

   
    def salaire_annuel
      salaire_annuel =  at_salaires.map { |salaire| salaire.montant}.sum
      return salaire_annuel 
    end

    def mois_precedent_rechute
      return (date_rechute - 1.month).strftime("%B").downcase
    end

    def nombre_jours_ouvres
      joa = Admin::JourOuvrableAnnuel.where(mois: MONTH_IN_FR[mois_precedent_rechute.to_sym], annee: mois_precedent_rechute).first
      unless joa.nil?
        return joa.nombre_jour_ouvrable  
      else
        return 24
      end
    end

    def can_add_elt_salaire?(current_user)
      arret_travail.meme_agence?(current_user) &&
      ( current_user.technicien_at? ||
      current_user.technicien_direction_at?)  && creation? &&
      !nombre_jours_ouvres.nil? and !information_salaire
    end

    private

    def validate_date_rechute
      if date_rechute <=  arret_travail.at_guerison.date_validation
          errors.add(:date_rechute, "doit etre supérieure à la date de guérison (#{arret_travail.at_guerison.date_validation.strftime("%d/%m/%Y")}) ")
      end
    end
    

end
