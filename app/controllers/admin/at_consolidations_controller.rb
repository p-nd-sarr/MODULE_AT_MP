class Admin::AtConsolidationsController < Admin::ApplicationController
    before_action :set_at_consolidation, except: [:new, :create, :index, :en_attente_soumission, 
                                                :consolidations_soumises_chef_agence, 
                                                :consolidations_soumises_chef_service, 
                                                :en_attente_validation_mc, :en_attente_affectation_tech,
                                                :en_attente_verification, :en_attente_validation_chef_agence,
                                                :en_attente_validation_chef_service_at,:en_attente_validation_dir_at,
                                                :en_attente_validation_agence, :en_attente_validation_direction, :en_attente_validation_audit, :en_attente_validation_dg]

    before_action :set_arret_travail, except: [:en_attente_soumission,:index, :update,:edit, :consolidations_soumises_chef_agence, 
                                                :consolidations_soumises_chef_service, :en_attente_validation_mc, 
                                                :en_attente_affectation_tech, :en_attente_verification, :en_attente_validation_chef_agence,
                                                :en_attente_validation_chef_service_at, :en_attente_validation_dir_at, :en_attente_validation_dg,
                                                :en_attente_validation_agence, :en_attente_validation_direction, :show, :retourner_process,:accord_ipp, :add_salaire, :notification, :en_attente_validation_audit]
    def index
       @at_consolidations= AtConsolidation.all.page(params[:page]).per(100)
    end

    def new
        @at_consolidation= AtConsolidation.new
    end

    def show
      @arret_travail = ArretTravail.find(@at_consolidation.arret_travail_id)
      if @arret_travail.creer_en_agence?
         @techniciens = User.technicien_at # avoir la liste des gestionnaires
      else
        @techniciens = User.technicien_direction_at
      end
      @at_salaire = AtSalaire.new
    end

    def edit
      @arret_travail = ArretTravail.find(@at_consolidation.arret_travail_id)
    end

    def en_attente_soumission
      @at_consolidations = AtConsolidation.en_attente_soumission.page(params[:page]).per(100)
    end

    def consolidations_soumises_chef_agence
      @at_consolidations = AtConsolidation.consolidations_soumises_chef_agence.page(params[:page]).per(100)
    end

    def consolidations_soumises_chef_service
      @at_consolidations = AtConsolidation.consolidations_soumises_chef_service.page(params[:page]).per(100)
    end

    def en_attente_validation_mc
      @at_consolidations = AtConsolidation.en_attente_validation_mc.page(params[:page]).per(100)
    end

    def en_attente_affectation_tech
      @at_consolidations = AtConsolidation.en_attente_affectation_tech.page(params[:page]).per(100)
    end

    def en_attente_verification
      @at_consolidations = AtConsolidation.en_attente_verification.page(params[:page]).per(100)
    end
    
    def en_attente_validation_chef_agence
      @at_consolidations = AtConsolidation.tableau_rente_verifie.where(creer_en_agence: true).page(params[:page]).per(100)
    end

    def en_attente_validation_agence
      @at_consolidations = AtConsolidation.en_attente_validation_chef_service_at.page(params[:page]).per(100)
    end

    def en_attente_validation_direction
      @at_consolidations = AtConsolidation.tableau_rente_verifie.where(creer_en_agence: false).page(params[:page]).per(100)

    end
      
    def en_attente_validation_dir_at
      @at_consolidations = AtConsolidation.en_attente_validation_dir_at.page(params[:page]).per(100)
    end

    def en_attente_validation_audit
      @at_consolidations = AtConsolidation.en_attente_validation_audit.page(params[:page]).per(100)
    end

    def en_attente_validation_dg
      @at_consolidations = AtConsolidation.en_attente_validation_dg.page(params[:page]).per(100)
    end
    
    def create
      @at_consolidation = AtConsolidation.new(at_consolidation_params)
      @at_consolidation.arret_travail= @arret_travail
        if @arret_travail.creer_par_ag_direction_at?
          @at_consolidation.creer_en_agence = false
        end
      if @at_consolidation.save
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'La demande de consolidation est créée.'
      else
        render :new
      end
    end

    def update
      @arret_travail = ArretTravail.find(@at_consolidation.arret_travail_id)
      if @at_consolidation.update(at_consolidation_params)
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'La demande at_consolidation est bien mise à jour.'
      else
        render :edit
      end
    end

   # region : valider toutes les infos de la demande
   def valider_information_consolidation
    @at_consolidation.information_consolidation!
    redirect_to [:admin, @arret_travail, @at_consolidation], notice: "Les informations de la validation sont validées"
   end

    def valider_documents
      puts "======OKK", @at_consolidation.documents_valide!
      unless @at_consolidation.documents_valide!
        flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
      end
      redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'Les documents sont bien validés'
    end

    def valider_information_salaire
      unless @at_consolidation.information_salaire_valide!
        flash[:error] = "Veuillez entrer les 12 derniers salaires avant la validation"
      end
      redirect_to [:admin,@arret_travail, @at_consolidation]
    end

    def valider_tableau_rente
      @at_consolidation.tableau_rente_valide!
      redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'Le tableau de rente a été bien validé .'
     end

    def soumettre
      if @at_consolidation.creation?
        if @at_consolidation.arret_travail.creer_en_agence? 
           @at_consolidation.est_soumis_chef_agence!
        else
          @at_consolidation.est_soumis_chef_service!
        end
        @at_consolidation.date_soumission_tech = DateTime.now
        @at_consolidation.soumis_par = current_user
        @at_consolidation.motif = nil
        @at_consolidation.save
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'Consolidation a été bien soumise .'
      else
        redirect_to [:admin,@arret_travail, @at_consolidation]
      end
    end

    def soumettre_chef_service
      if @at_consolidation.soumis_chef_agence?
        @at_consolidation.est_soumis_chef_service!
        @at_consolidation.date_soumission_chef_agence = DateTime.now
        @at_consolidation.soumis_par = current_user
        @at_consolidation.motif = nil
        @at_consolidation.save
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'Consolidation a été bien soumise au chef service AT .'
      else
        redirect_to [:admin,@arret_travail, @at_consolidation]
      end
    end

    def soumettre_medecin_conseil
      if @at_consolidation.soumis_chef_service? or @at_consolidation.soumis_chef_agence?
        @at_consolidation.est_soumis_mc!
        @at_consolidation.date_soumission_chef_service = DateTime.now
        @at_consolidation.soumis_par = current_user
        @at_consolidation.motif = nil
        @at_consolidation.save
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'Consolidation a été bien soumise au chef service AT .'
      else
        redirect_to [:admin,@arret_travail, @at_consolidation]
      end
    end

    def decision_medecin_conseil
      if @at_consolidation.update(at_consolidation_params)
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'Décision medecin conseil enregistrée avec succés.'
      else
        redirect_to [:admin,@arret_travail, @at_consolidation]
      end
    end

    def valider_onglet_decision_mc
      unless @at_consolidation.valider_decision_mc!
        flash[:error] = "Accord sur le taux IPP est obligatoire"
      end
      redirect_to [:admin,@arret_travail, @at_consolidation]
    end

    

    def valider_onglet_tableau_rente
      unless @at_consolidation.tableau_rente_valide!
        flash[:error] = "error"
      end
      redirect_to [:admin,@arret_travail, @at_consolidation],notice: "Onglet tableau rente validé aved succés"
    end

    def validation_mc
      if @at_consolidation.soumis_mc?
        @at_consolidation.est_valide_mc!
        @at_consolidation.date_validation_mc = DateTime.now
        @at_consolidation.motif = nil
        @at_consolidation.save
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'Consolidation a été bien validée .'
      else
        redirect_to [:admin,@arret_travail, @at_consolidation]
      end
    end

    def affectation_technicien
      #affecter une consolidation à un technicien
      @at_consolidation.update(at_consolidation_affecter_tech_params.merge(date_affectation_technicien: DateTime.now, workflow_state: :affectation_technicien))
      redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'Consolidation Affectée.'
    end

    def verification_tableau_rente
      if @at_consolidation.affectation_technicien?
        @at_consolidation.est_verifie_tableau_rente!
        @at_consolidation.date_verification = DateTime.now
        @at_consolidation.motif = nil
        @at_consolidation.save
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'Consolidation a été bien validée .'
      else
        redirect_to [:admin,@arret_travail, @at_consolidation]
      end
    end

    def validation_chef_agence
      if @at_consolidation.verifie_tableau_rente?
        @at_consolidation.est_chef_agence_valide!
        @at_consolidation.date_validation_chef_agence = DateTime.now
        @at_consolidation.motif = nil
        @at_consolidation.save
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: "Consolidation a été bien validée par le chef d'agence ."
      else
        redirect_to [:admin,@arret_travail, @at_consolidation]
      end
    end

    def validation_chef_service_at
      if @at_consolidation.chef_agence_valide? or @at_consolidation.verifie_tableau_rente? 
        @at_consolidation.est_chef_service_valide!
        @at_consolidation.motif = nil
        @at_consolidation.date_validation_chef_service = DateTime.now
        @at_consolidation.save
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: "Consolidation a été bien validée par le chef service ."
      else
        redirect_to [:admin,@arret_travail, @at_consolidation]
      end
    end

    def validation_directeur_at
      if @at_consolidation.chef_service_valide?
        @at_consolidation.est_directeur_at_valide!
        @at_consolidation.motif = nil
        @at_consolidation.date_validation_directeur_at = DateTime.now
        @at_consolidation.save
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: "Consolidation a été bien validée par le chef service ."
      else
        redirect_to [:admin,@arret_travail, @at_consolidation]
      end
    end

    def validation_audit
      if @at_consolidation.directeur_at_valide?
        @at_consolidation.est_audit_valide!
        @at_consolidation.motif = nil
        @at_consolidation.save
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: "Consolidation a été bien validée par l'audit ."
      else
        redirect_to [:admin,@arret_travail, @at_consolidation]
      end
    end

    

    def validation_directeur_general
      if @at_consolidation.audit_valide?
        @at_consolidation.est_dossier_valide!
        @at_consolidation.date_validation_directeur_general = DateTime.now
        @at_consolidation.save
        redirect_to [:admin,@arret_travail, @at_consolidation], notice: "Consolidation a été bien validée par Directeur Général ."
      else
        redirect_to [:admin,@arret_travail, @at_consolidation]
      end
    end

    def retourner_process
    
      if @at_consolidation.soumis_chef_agence?
        @at_consolidation.retour_creation!
      else
        if @at_consolidation.soumis_chef_service?
          @at_consolidation.retour_creation!
        else
          if @at_consolidation.soumis_mc?
            if @at_consolidation.arret_travail.creer_en_agence?
              @at_consolidation.retour_soumis_chef_agence!
            else
              @at_consolidation.retour_soumis_chef_service!
            end
          else
            if @at_consolidation.valide_mc?
              @at_consolidation.update(decision_mc_valide: false)
              @at_consolidation.retour_soumis_mc!
            else
              if @at_consolidation.affectation_technicien?
                @at_consolidation.update(affectation_technicien: nil, tableau_rente_valide: false)
                @at_consolidation.retour_valide_mc!
              else
                if @at_consolidation.verifie_tableau_rente?
                  @at_consolidation.retour_affectation_technicien!
                else
                  if @at_consolidation.chef_agence_valide?
                    @at_consolidation.retour_verifie_tableau_rente!
                  else
                    if @at_consolidation.chef_service_valide?
                      @at_consolidation.retour_chef_service_valide!

                    else
                      if @at_consolidation.directeur_at_valide?
                        @at_consolidation.retour_directeur_at_valide!
                      else
                        if @at_consolidation.audit_valide?
                          @at_consolidation.retour_audit_valide!
                        end
                      end
                    end
                  end
                end
  
              end
            end
          end
        end
      end
      if @at_consolidation.update(at_consolidation_motifRetouner_params)
        redirect_to admin_at_consolidation_path(@at_consolidation), notice: 'Dossier retourner avec succés.'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        render :rejeter
      end
    end

    def notification
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "Notification No. #{@at_consolidation.id}",
                 page_size: 'A4',
                 template: "admin/at_consolidations/notification.html.erb",
                 layout: "pdf.html",
                 orientation: "Landscape",
                 lowquality: true,
                 zoom: 1,
                 pi: 75
        end
      end

    end


    def accord_ipp
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "Accord  No. #{@at_consolidation.id}",
                 page_size: 'A4',
                 template: "admin/at_consolidations/accord_ipp.html.erb",
                 layout: "pdf.html",
                 orientation: "Landscape",
                 lowquality: true,
                 zoom: 1,
                 pi: 75
        end
      end

    end

    def add_salaire1
      @at_salaire = AtSalaire.new(salaire_params)
      if @at_salaire.save
       redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'Salaire was successfully submitted.'
      else
        respond_to do |format|
          format.html { redirect_to admin_at_consolidation_path(@at_consolidation), alert: 'salaire not added.' }
        end
      end
    end

    def add_salaire
      
      for i in 0..11
        @at_salaire = AtSalaire.new(salaire_params)
        first_month = AtSalaire.mois[@at_salaire.mois]
        next_month=first_month+i 
        @at_salaire.mois=next_month if next_month <= 12
        @at_salaire.mois=next_month-12 if next_month > 12
      
        @at_salaire.save
     end
     redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'Salaire was successfully submitted.'
    end

    

    private
    def set_at_consolidation
      @at_consolidation = AtConsolidation.find(params[:id] || params[:at_consolidation_id])
    end

  def at_consolidation_params
    params.require(:at_consolidation).permit(:numero_affiliation, :prenom, :nom, :date_naissance, :lieu_naissance, :ajoute_par_id, :date_visite,
                                             :taux_ipp_medecin_traitant, :date_consolidation_medecin_traitant, :date_consolidation_medecin_conseil, :date_consolidation_medecin_expert, :accord_taux_ipp, :avis_mc, :taux_ipp_mc, :taux_ipp_medecin_expert)
  end

  def set_arret_travail
    @arret_travail = ArretTravail.find(params[:arret_travail_id])
  end

  def at_consolidation_affecter_tech_params
    params.require(:at_consolidation).permit(:affectation_technicien)
  end

  def salaire_params
    params.require(:at_salaire).permit(:mois, :montant, :arret_travail_id, :at_consolidation_id)
  end

  def at_consolidation_motifRetouner_params
    params.require(:at_consolidation).permit(:motif)
  end

end