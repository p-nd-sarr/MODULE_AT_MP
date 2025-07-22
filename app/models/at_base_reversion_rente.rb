class AtBaseReversionRente < ApplicationRecord
    include Documentable
    TYPE_DOCUMENT_OBLIGATOIRE = {
        certificat_medical_consolidation: 42,
        rapport_evaluation_medecin: 43,
        pv_enquete: 44,
        bulletin_salaire_precedent_accident: 45
    }.freeze
  
    TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
        {
            certificat_non_remariage: 15,
            extrait_naissance_defunt: 16,
        }
    ).freeze
    include WorkflowActiverecord
    InvalidTransitionError = Class.new(StandardError)
    workflow_column :workflow_state

    workflow do
      state :creation do
        event :est_soumis, transition_to: :soumis
      end
    end
    belongs_to :arret_travail
    has_many :carrieres_prestation, class_name: 'Carriere', foreign_key: :numero_affiliation, primary_key: :numero_affiliation
    has_many :carrieres, class_name: 'Psrm::Carriere', foreign_key: :matric, primary_key: :numero_affiliation
    has_many :enfants, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
    has_many :conjoints, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
    has_many :ascendants, foreign_key: :numero_affiliation, primary_key: :numero_affiliation
    has_many :at_dossier_reversion_rentes
    validates_uniqueness_of :arret_travail_id, message: "Une seule demande de consolidation est autosiré"
   
    def etat_civil_demandeur_valide!(est_valide = true)
        update(etat_civil_demandeur_valide: est_valide)
    end

    def documents_valide!(est_valide = true)
        if est_valide
          return false if documents.where(type_document: [:certificat_medical_consolidation]).empty?
          update(documents_valide: est_valide)
        else
            update(documents_valide: est_valide)
        end
           true
    end


    def pret_pour_soumission(current_user)
        etat_civil_demandeur_valide  and documents_valide and (current_user.technicien_at? || current_user.technicien_direction_at?)
    end

    def valide_onglet_consolidation
        etat_civil_demandeur_valide  and documents_valide
    end

    def salaire_annuel
        if !carrieres_prestation.nil?
           salaire_mensuel =  carrieres_prestation.map { |carriere| carriere.salaire}.last 
        else
            return 0
        end
       if !salaire_mensuel.nil?
          return salaire_mensuel*12
       else
           return 0
       end
    end
  

    def taux_utile
        if taux_incapacite <= 50
            return taux_incapacite/2 
        else taux_incapacite > 50
            return  ((50/2) + (taux_incapacite - 50)/2 + (taux_incapacite - 50))
        end
    end
    def age_conversion
        return (date_consolidation.year - arret_travail.date_de_naissance_salarie.year)
        
    end

    def prix_franc_rente
        return Admin::Rente.find_by(age: 36).prix
    end
    def montant_annuel_rente
        return salaire_annuel*(taux_utile.to_f/100)*prix_franc_rente
    end
    def versement_unique?
        return true if taux_incapacite <75
    end

    def versement_trimeste?
        return true if taux_incapacite >= 75 and taux_incapacite < 100
    end
    def versement_mensuel?
        return true if taux_incapacite == 100
    end

    def rente_mensuelle_majoree
        return rente_mensuelle_majoree = ((salaire_annuel * taux_utile.to_f/100) + (salaire_annuel * 40/100 )) if versement_mensuel?
    end

    def rente_trimestrielle
        return montant_annuel_rente/4 if versement_trimeste?
    end

    def rente_versement_unique
        return montant_annuel_rente if versement_unique?
    end

    def type_versement_rente
        if taux_incapacite < 75
            return " versement unique"
        elsif taux_incapacite >= 75 and taux_incapacite<100
            return "versement par trimestre"
        else
            return "versement mensuel"
        end
    end

    def montant_versement 
        if versement_unique?
            return rente_versement_unique
        elsif versement_trimeste?
            return rente_trimestrielle
        else
            return rente_mensuelle_majoree
        end
    end

end
