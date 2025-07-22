class Admin::ArretTravailGedsController < ApplicationController
  before_action :set_arret_travail_ged, only: [:show, :edit, :update, :destroy, :migrer_prod]

    def index
      @est_mp = params[:est_mp]      
      @q = ArretTravailGed.where(status_ged: :en_creation)
      if @est_mp == 'true'
        @q = ArretTravailGed.where(est_mp: true)
      else
        @q = ArretTravailGed.where(est_mp: [nil,false])
      end

      if !current_user.admin?
        @q = @q.where(admin_agence_id: current_user.admin_agence.id)
      end
      @q = @q.ransack(params[:q])
      @arret_travail_geds = @q.result.page(params[:page])
    end

    def show
    end

    def new
      @arret_travail_ged = ArretTravailGed.new
    end

    def edit
    end

    def create
      @arret_travail_ged = ArretTravailGed.new(arret_travail_ged_params)

      if @arret_travail_ged.save
        redirect_to admin_arret_travail_ged_path(@arret_travail_ged), notice: 'Arret travail ged was successfully created.'
      else
        render :new
      end
    end

    def update
      if @arret_travail_ged.update(arret_travail_ged_params)
        redirect_to admin_arret_travail_ged_path(@arret_travail_ged), notice: 'Arret travail ged was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @arret_travail_ged.destroy
      redirect_to admin_arret_travail_geds_path, notice: 'Arret travail ged was successfully destroyed.'
    end

    def migrer_prod
      @demande_arret_travail = ArretTravail.new()
      @demande_arret_travail.raison_sociale_employeur = @arret_travail_ged.raison_sociale_employeur    
      @demande_arret_travail.numero_employeur = @arret_travail_ged.numero_employeur 
      @demande_arret_travail.adresse_employeur  = @arret_travail_ged.adresse_employeur 
      @demande_arret_travail.email_employeur  = @arret_travail_ged.email_employeur 
      @demande_arret_travail.telephone_employeur  = @arret_travail_ged.telephone_employeur 
      @demande_arret_travail.activite_principale_entreprise  = @arret_travail_ged.activite_principale_entreprise 
      @demande_arret_travail.numero_affiliation  = @arret_travail_ged.numero_affiliation 
      if Psrm::Participant.where(matric: @arret_travail_ged.numero_affiliation).exists? && !@arret_travail_ged.est_journalier?
        @demande_arret_travail.has_numero_affiliation = true
      else
        @demande_arret_travail.has_numero_affiliation = false
        @demande_arret_travail.numero_affiliation = ""
      end
      @demande_arret_travail.type_de_piece  = @arret_travail_ged.type_de_piece 
      @demande_arret_travail.nin_salarie  = @arret_travail_ged.nin_salarie 
      @demande_arret_travail.prenom_salarie  = @arret_travail_ged.prenom_salarie 
      @demande_arret_travail.nom_salarie  = @arret_travail_ged.nom_salarie 
      @demande_arret_travail.sexe  = @arret_travail_ged.sexe 
      @demande_arret_travail.date_de_naissance_salarie  = @arret_travail_ged.date_de_naissance_salarie 
      @demande_arret_travail.nationalite_salarie  = @arret_travail_ged.nationalite_salarie 
      @demande_arret_travail.adresse  = @arret_travail_ged.adresse_domiciliaire_salarie  
      @demande_arret_travail.situation_matrimoniale_salarie  = @arret_travail_ged.situation_matrimoniale_salarie 
      @demande_arret_travail.telephone_salarie  = @arret_travail_ged.telephone_salarie 
      @demande_arret_travail.qualification_professionnelle_salarie  = @arret_travail_ged.qualification_professionnelle_salarie
      @demande_arret_travail.date_embauche_salarie  = @arret_travail_ged.date_embauche_salarie 
      @demande_arret_travail.type_de_contrat_travail_salarie  = @arret_travail_ged.type_de_contrat_travail_salarie
      if @demande_arret_travail.type_de_contrat_travail_salarie == 'journalier'
        @arret_travail_ged.est_journalier = true
      end 
      @demande_arret_travail.nature_du_travail_au_moment_accident  = @arret_travail_ged.nature_du_travail_au_moment_accident
      @demande_arret_travail.infirmite_anterieure_accident  = @arret_travail_ged.infirmite_anterieure_accident 
      @demande_arret_travail.taux_infirmite_anterieure_accident  = @arret_travail_ged.taux_infirmite_anterieure_accident 
      @demande_arret_travail.numero_rente_infirmite_anterieure_accident  = @arret_travail_ged.numero_rente_infirmite_anterieure_accident
      @demande_arret_travail.date_accident  = @arret_travail_ged.date_accident 
      @demande_arret_travail.nombre_hr_entre_accident_et_prise_travail  = @arret_travail_ged.nombre_hr_entre_accident_et_prise_travail
      @demande_arret_travail.lieu_accident  = @arret_travail_ged.lieu_accident 
      @demande_arret_travail.accident_mortel  = @arret_travail_ged.accident_mortel 
      @demande_arret_travail.debut_arret_travail  = @arret_travail_ged.debut_arret_travail 
      @demande_arret_travail.agent_materiel  = @arret_travail_ged.agent_materiel 
      @demande_arret_travail.cause_circonstances_acccident  = @arret_travail_ged.cause_circonstances_acccident 
      @demande_arret_travail.avec_constat  = @arret_travail_ged.avec_constat 
      @demande_arret_travail.detail_constat  = @arret_travail_ged.detail_constat 
      @demande_arret_travail.raison_absence_constat = @arret_travail_ged.raison_absence_constat 
      @demande_arret_travail.avec_temoin  = @arret_travail_ged.avec_temoin 
      @demande_arret_travail.nom_temoin  = @arret_travail_ged.nom_temoin 
      @demande_arret_travail.adresse_temoin  = @arret_travail_ged.adresse_temoin 
      @demande_arret_travail.personne_avisee  = @arret_travail_ged.personne_avisee 
      @demande_arret_travail.nom_personne_avisee  = @arret_travail_ged.nom_personne_avisee 
      @demande_arret_travail.adresse_personne_avisee  = @arret_travail_ged.adresse_personne_avisee 
      @demande_arret_travail.personne_avisee_quand  = @arret_travail_ged.personne_avisee_quand 
      @demande_arret_travail.personne_avisee_par_qui  = @arret_travail_ged.personne_avisee_par_qui 
      @demande_arret_travail.accident_cause_par_tiers  = @arret_travail_ged.accident_cause_par_tiers 
      @demande_arret_travail.prenom_tiers  = @arret_travail_ged.prenom_tiers 
      @demande_arret_travail.nom_tiers  = @arret_travail_ged.nom_tiers 
      @demande_arret_travail.adresse_tiers  = @arret_travail_ged.adresse_tiers 
      @demande_arret_travail.prenom_civilement_responsable  = @arret_travail_ged.prenom_civilement_responsable 
      @demande_arret_travail.nom_civilement_responsable  = @arret_travail_ged.nom_civilement_responsable 
      @demande_arret_travail.adresse_civilement_responsable  = @arret_travail_ged.adresse_civilement_responsable 
      @demande_arret_travail.raison_sociale_assureur  = @arret_travail_ged.raison_sociale_assureur 
      @demande_arret_travail.nom_assureur  = @arret_travail_ged.nom_assureur 
      @demande_arret_travail.adresse_assureur  = @arret_travail_ged.adresse_assureur 
      @demande_arret_travail.numero_police_assurance  = @arret_travail_ged.numero_police_assurance 
      @demande_arret_travail.salaire_verse_en_totalite_en_at  = @arret_travail_ged.salaire_verse_en_totalite_en_at 
      @demande_arret_travail.declarant  = @arret_travail_ged.declarant 
      @demande_arret_travail.prenom_declarant  = @arret_travail_ged.prenom_declarant 
      @demande_arret_travail.nom_declarant  = @arret_travail_ged.nom_declarant 
      @demande_arret_travail.adresse_declarant  = @arret_travail_ged.adresse_declarant 
      @demande_arret_travail.telephone_declarant  = @arret_travail_ged.telephone_declarant 
      @demande_arret_travail.lieu_declaration  = @arret_travail_ged.lieu_declaration 
      @demande_arret_travail.qualite_declarant  = @arret_travail_ged.qualite_declarant 
      @demande_arret_travail.date_declaration  = @arret_travail_ged.date_declaration 
      @demande_arret_travail.est_journalier  = @arret_travail_ged.est_journalier 
      @demande_arret_travail.is_subrogation  = @arret_travail_ged.is_subrogation 
      @demande_arret_travail.admin_agence_id  = @arret_travail_ged.admin_agence_id 
      @demande_arret_travail.date_reception  = @arret_travail_ged.date_reception 
      @demande_arret_travail.etat  = @arret_travail_ged.etat 
      @demande_arret_travail.id_item  = @arret_travail_ged.id_item 
      @demande_arret_travail.est_mp = @arret_travail_ged.est_mp

      @demande_arret_travail.user_id = current_user.id
      @demande_arret_travail.admin_agence = current_user.admin_agence
      @demande_arret_travail.etat = 'instruction'
      @demande_arret_travail.workflow_state = 'creation'
      if current_user.gestionnaire_compte_allocataire?
        @demande_arret_travail.creer_par_ag_direction_at = true
      end
      if @demande_arret_travail.save
        @arret_travail_ged.status_ged = :valide
        @arret_travail_ged.save
        # desc = "Création du dossier AT n° #{@demande_arret_travail.num_dossier} par #{current_user.email} (#{current_user.type_profil})"
        # ajouter_event(@demande_arret_travail, current_user, desc)
        redirect_to [:admin, @demande_arret_travail], notice: 'Dossier est créé avec succès.'
      else
        error_messages = @demande_arret_travail.errors.full_messages.join(', ')
        redirect_to admin_arret_travail_ged_path(@arret_travail_ged), alert: "Erreur lors de la migration : #{error_messages}"
      end
    end

    private
      def set_arret_travail_ged
        @arret_travail_ged = ArretTravailGed.find(params[:id] || params[:arret_travail_ged_id])
      end

      def arret_travail_ged_params
        params.require(:arret_travail_ged).permit(
          :raison_sociale_employeur, :numero_employeur, :adresse_employeur, :email_employeur, 
          :telephone_employeur, :activite_principale_entreprise, :numero_affiliation, :type_de_piece, 
          :nin_salarie, :prenom_salarie, :nom_salarie, :sexe, :date_de_naissance_salarie, 
          :nationalite_salarie, :adresse_domiciliaire_salarie, :telephone_salarie, 
          :qualification_professionnelle_salarie, :date_embauche_salarie, :type_de_contrat_travail_salarie, 
          :nature_du_travail_au_moment_accident, :infirmite_anterieure_accident, 
          :taux_infirmite_anterieure_accident, :numero_rente_infirmite_anterieure_accident, 
          :date_accident, :nombre_hr_entre_accident_et_prise_travail, :lieu_accident, 
          :accident_mortel, :debut_arret_travail, :agent_materiel, :cause_circonstances_acccident, 
          :avec_constat, :detail_constat, :raison_absence_constat, :avec_temoin, :nom_temoin, 
          :adresse_temoin, :personne_avisee, :nom_personne_avisee, :adresse_personne_avisee, 
          :personne_avisee_quand, :personne_avisee_par_qui, :accident_cause_par_tiers, 
          :prenom_tiers, :nom_tiers, :adresse_tiers, :prenom_civilement_responsable, 
          :nom_civilement_responsable, :adresse_civilement_responsable, :raison_sociale_assureur, 
          :nom_assureur, :adresse_assureur, :numero_police_assurance, :salaire_verse_en_totalite_en_at, 
          :declarant, :prenom_declarant, :nom_declarant, :adresse_declarant, :telephone_declarant, 
          :lieu_declaration, :qualite_declarant, :date_declaration, :est_journalier, :is_subrogation, 
          :admin_agence_id, :date_reception, :etat, :status_ged, :id_item, :lien_ged, :est_mp
        )
      end


      def demande_arret_travail_params
        params.require(:arret_travail).permit(
          :raison_sociale_employeur, :numero_employeur, :adresse_employeur, :email_employeur, 
          :telephone_employeur, :activite_principale_entreprise, :numero_affiliation, :type_de_piece, 
          :nin_salarie, :prenom_salarie, :nom_salarie, :sexe, :date_de_naissance_salarie, 
          :nationalite_salarie, :adresse_domiciliaire_salarie, :telephone_salarie, 
          :qualification_professionnelle_salarie, :date_embauche_salarie, :type_de_contrat_travail_salarie, 
          :nature_du_travail_au_moment_accident, :infirmite_anterieure_accident, 
          :taux_infirmite_anterieure_accident, :numero_rente_infirmite_anterieure_accident, 
          :date_accident, :nombre_hr_entre_accident_et_prise_travail, :lieu_accident, 
          :accident_mortel, :debut_arret_travail, :agent_materiel, :cause_circonstances_acccident, 
          :avec_constat, :detail_constat, :raison_absence_constat, :avec_temoin, :nom_temoin, 
          :adresse_temoin, :personne_avisee, :nom_personne_avisee, :adresse_personne_avisee, 
          :personne_avisee_quand, :personne_avisee_par_qui, :accident_cause_par_tiers, 
          :prenom_tiers, :nom_tiers, :adresse_tiers, :prenom_civilement_responsable, 
          :nom_civilement_responsable, :adresse_civilement_responsable, :raison_sociale_assureur, 
          :nom_assureur, :adresse_assureur, :numero_police_assurance, :salaire_verse_en_totalite_en_at, 
          :declarant, :prenom_declarant, :nom_declarant, :adresse_declarant, :telephone_declarant, 
          :lieu_declaration, :qualite_declarant, :date_declaration, :est_journalier, :is_subrogation, 
          :admin_agence_id, :date_reception, :etat, :status_ged, :id_item, :lien_ged, :est_mp
        )
      end
end