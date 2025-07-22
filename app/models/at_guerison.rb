class AtGuerison < ApplicationRecord
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
          event :est_guerison_validee, transition_to: :guerison_validee
          event :est_guerison_rejetee, transition_to: :guerison_rejetee
          event :retour_creation, transition_to: :creation
        end
  
        state :soumis_chef_service do
          event :est_guerison_validee, transition_to: :guerison_validee
          event :est_guerison_rejetee, transition_to: :guerison_rejetee
          event :retour_creation, transition_to: :creation
        end
  
        
        state :guerison_validee
        state :guerison_rejetee
  
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
        certificat_guerison: 60,
      }.freeze
    
      TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
        {
      
        }
      ).freeze

    belongs_to :arret_travail, optional: true
    belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
    belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true
    belongs_to :valide_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
    belongs_to :rejete_par, class_name: 'User', foreign_key: :rejete_par_id, optional: true
    
    scope :en_attente_soumission, -> { where(workflow_state: [:creation]) }
    scope :soumis_chef_agence, -> { where(workflow_state: [:soumis_chef_agence]) }
    scope :soumis_chef_service, -> { where(workflow_state: [:soumis_chef_service]) }
    scope :mes_creations, ->(id) { where("ajoute_par_id = ?", id) }
    scope :mes_dossiers_retournes, ->(id) { where("ajoute_par_id = ?", id).where.not(motif: nil) }

    validate :validate_date_ouverture_guerison

    def can_update?(current_user)
        ajoute_par == current_user and
        creation?
    end

      
    def information_generale!(est_valide = true)
        update(information_generale: est_valide)
    end
  
    def documents_valide!(est_valide = true)
        if est_valide
            return false if documents.certificat_guerison.empty?
            update(documents_valide: est_valide)
        else
            update(documents_valide: est_valide)
        end

        true
    end

    def pret_pour_soumission?(current_user)
        creation? and
        information_generale
        documents_valide and 
        (current_user.technicien_at? || current_user.technicien_direction_at?)
    end

    def can_valide_agence?(current_user)
        current_user.chef_agence? and soumis_chef_agence?
    end

    def can_valide_dir?(current_user)
        current_user.chef_division_at? and soumis_chef_service?
    end

    private

    def validate_date_ouverture_guerison
      if date_ouverture_guerison <=  arret_travail.date_accident
          errors.add(:date_ouverture_guerison, "doit etre supérieure à la date d'accident du dossier AT (#{arret_travail.date_accident.strftime("%d/%m/%Y")}) ")
      end
    end
end
