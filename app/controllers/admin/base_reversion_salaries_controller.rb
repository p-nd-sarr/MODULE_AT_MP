class Admin::BaseReversionSalariesController < ApplicationController
  before_action :set_reversion_veuve_salary, except: [:new, :create, :index, :en_attente_instruction, :en_attente_affectation_salarie, :en_attente_validation_recap,
                                                      :en_attente_validation_salaire, :en_attente_validation_carriere, :en_attente_affectation_allocataire,
                                                      :en_attente_validation, :en_attente_validation_allocataire, :liste_dossiers_valides,:en_attente_validation_instruction, :demandes_affectees, :dossiers_incomplets]
  before_action :set_demandeur, only: [:add_base_reversion]
  # GET /admin/reversion_veuve_salaries
  # GET /admin/reversion_veuve_salaries.json
  def index
    
    @q = BaseReversionSalary.visible_for_admins.ransack(params[:q])
    @reversion_veuve_salaries = @q.result.order('created_at DESC')
    @reversion_veuve_salaries = @reversion_veuve_salaries.page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def en_attente_instruction
    @reversion_veuve_salaries = BaseReversionSalary.en_attente_instruction.page(params[:page]).per(100)
  end


  def en_attente_affectation_salarie
    @reversion_veuve_salaries = BaseReversionSalary.en_attente_salaire.page(params[:page]).per(100)
  end

  def en_attente_validation_salaire
    @reversion_veuve_salaries = BaseReversionSalary.where(affectation_salarie: current_user.id).can_affecte.page(params[:page]).per(100)
  end

  def en_attente_validation_carriere
    @reversion_veuve_salaries = BaseReversionSalary.en_attente_validation_carrieres.page(params[:page]).per(100)
  end

  def en_attente_affectation_allocataire
    @reversion_veuve_salaries = BaseReversionSalary.en_attente_allocation.page(params[:page]).per(100)
  end

  def en_attente_validation_allocataire
    @reversion_veuve_salaries = BaseReversionSalary.where(affectation_allocataire: current_user.id).can_affecte.page(params[:page]).per(100)
  end

  def en_attente_validation_recap
    @reversion_veuve_salaries = BaseReversionSalary.with_recap_soumis_state.page(params[:page]).per(100)
  end

  def en_attente_validation
    @reversion_veuve_salaries = BaseReversionSalary.with_liquidation_valide_state.page(params[:page]).per(100)
  end

  def liste_dossiers_valides
    @reversion_veuve_salaries = BaseReversionSalary.with_dossier_valide_state.page(params[:page]).per(100)
  end
  def demandes_affectees
    @q = BaseReversionSalary.demandes_affectees.ransack(params[:q])
    @reversion_veuve_salaries = @q.result
    @reversion_veuve_salaries = @reversion_veuve_salaries.page(params[:page]).per(100)
    @reversion_veuve_salaries_export = BaseReversionSalary.demandes_affectees
  end

  def dossiers_incomplets
    @reversion_veuve_salaries = BaseReversionSalary.dossiers_incomplets.page(params[:page]).per(100)
  end

  # GET /admin/reversion_veuve_salaries/1
  # GET /admin/reversion_veuve_salaries/1.json
  def show
    @gestionnaires = User.gestionnaire_compte_allocataire.where.not(id: @reversion_veuve_salarie.ajoute_par.id) # avoir la liste des gestionnaires
    @gestionnaires_salaries = User.gestionnaire_compte_salarie # avoir la liste des gestionnaires
    @carriere = Carriere.new
    @dossier_reversion_salarie = DossierReversionSalary.new
    @dossier_reversion_salaries = @reversion_veuve_salarie.dossier_reversion_salaries
    @agents = User.users_for_type('gestionnaire_compte_allocataire').en_agence(current_user.agence_id)
  end

  def affecter_dossier
    @agent = User.find(params[:agent_id])
    @reversion_veuve_salarie.set_as_agent_chosen(@agent.id)
    redirect_to [:admin, @allocataire, @reversion_veuve_salarie], notice: 'L' 'agent a été choisi en tant que titulaire du dossier.'
  end

  def annuler_affectation_dossier
    @agent = User.find(params[:agent_id])
    @reversion_veuve_salarie.is_not_agent_chosen_anymore(@agent.id)
    redirect_to [:admin, @allocataire, @reversion_veuve_salarie], notice: 'L' 'agent a été retiré en tant que titulaire du dossier.'
  end

  # GET /admin/reversion_veuve_salaries/new
  def new
    @reversion_veuve_salarie = BaseReversionSalary.new

  end

  # GET /admin/reversion_veuve_salaries/1/edit
  def edit
    @enfants = Enfant.where(numero_affiliation: @reversion_veuve_salarie.numero_affiliation)
    @conjoints = Conjoint.where(numero_affiliation: @reversion_veuve_salarie.numero_affiliation)
    
  end

  # POST /admin/reversion_veuve_salaries
  # POST /admin/reversion_veuve_salaries.json
  def create
 
    @reversion_veuve_salarie = BaseReversionSalary.new(admin_reversion_veuve_salary_params)
    participant = Psrm::Participant.find_by(matric: @reversion_veuve_salarie.numero_affiliation)
    @reversion_veuve_salarie.prenom =  participant.prenom
    @reversion_veuve_salarie.nom =  participant.nom
    @reversion_veuve_salarie.enfants_id=params[:enfants_id]
    @reversion_veuve_salarie.conjoints_id=params[:conjoints_id]
      
    @reversion_veuve_salarie.ajoute_par = current_user
    @reversion_veuve_salarie.ajouter_le = DateTime.now

    @reversion_veuve_salarie.documents_deposes_obligatoires = params[:documents_deposes_obligatoires]
    @reversion_veuve_salarie.documents_deposes_facultatifs = params[:documents_deposes_facultatifs]
    
    if @reversion_veuve_salarie.save
      create_reversion_veuve(@reversion_veuve_salarie.conjoints_id)
      create_reversion_orphelin(@reversion_veuve_salarie.enfants_id)
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'La demande de reversion salarié est créée.'
    else
      render :new 
    end
  end

  # PATCH/PUT /admin/reversion_veuve_salaries/1
  # PATCH/PUT /admin/reversion_veuve_salaries/1.json
  def update
    if @reversion_veuve_salarie.update(admin_reversion_veuve_salary_params)

      @reversion_veuve_salarie.enfants_id=params[:enfants_id]
      @reversion_veuve_salarie.conjoints_id=params[:conjoints_id]
      create_reversion_veuve(@reversion_veuve_salarie.conjoints_id)
      create_reversion_orphelin(@reversion_veuve_salarie.enfants_id)

      @reversion_veuve_salarie.documents_deposes_obligatoires = params[:documents_deposes_obligatoires]
      @reversion_veuve_salarie.documents_deposes_facultatifs = params[:documents_deposes_facultatifs]

      if @reversion_veuve_salarie.save
        redirect_to [:admin, @reversion_veuve_salarie], notice: 'La demande de reversion salarié est mise à jour.'
      else
        redirect_to [:admin, @reversion_veuve_salarie], alert: 'Error lors de la mise à jour.'
      end

    else
      render :new
    end
  end

  def exceptional_edit
  end

  def update_exceptionally
    if @reversion_veuve_salarie.update(admin_exceptional_reversion_veuve_salary_params)
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'La demande de reversion salarié est mise à jour.'
    else
      render :exceptional_edit
    end
  end

  # DELETE /admin/reversion_veuve_salaries/1
  # DELETE /admin/reversion_veuve_salaries/1.json
  def destroy
    @reversion_veuve_salarie.destroy
    respond_to do |format|
      format.html { redirect_to admin_base_reversion_salaries_url, notice: 'Reversion veuve salarie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end



  # region : valider toutes les infos de la demande
   def valider_etat_civil_demandeur
    @reversion_veuve_salarie.etat_civil_demandeur_valide!
    redirect_to [:admin, @reversion_veuve_salarie]
  end

  def valider_epouses
    @reversion_veuve_salarie.epouses_valide!
    redirect_to [:admin, @reversion_veuve_salarie]
  end

  def valider_enfants
    @reversion_veuve_salarie.enfants_valide!
    redirect_to [:admin, @reversion_veuve_salarie]
  end

  def valider_carriere
    if @reversion_veuve_salarie.instruit?
      @reversion_veuve_salarie.carriere_valide!
      if @reversion_veuve_salarie.est_carriere_soumis!
        redirect_to [:admin, @reversion_veuve_salarie], notice: 'Validation carrières avec succés!'
      else
        redirect_to [:admin, @reversion_veuve_salarie]
      end
    else
      redirect_to [:admin, @reversion_veuve_salarie]
    end
  end

  def valider_documents
    unless @reversion_veuve_salarie.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:admin, @reversion_veuve_salarie]
  end

  def recap_point_valide
    @reversion_veuve_salarie.recap_point_valide!
    redirect_to [:admin, @reversion_veuve_salarie]
  end

  def dossier_demandeur_valide
    unless @reversion_veuve_salarie.dossier_demandeur_valide!
      flash[:error] = "Veuillez soumettre tous les dossiers qui sont peut etre eligibles"
    end
    redirect_to [:admin, @reversion_veuve_salarie]
  end
  # endregion


  # region : Workflow Validation DOSSIER BASE REVERSION SALAIRIE


  def soumettre_action
    if @reversion_veuve_salarie.creation?
      if @reversion_veuve_salarie.update(commentaire_soumission_params.merge(motif: nil))
        @reversion_veuve_salarie.date_soumission = DateTime.now
        @reversion_veuve_salarie.traite_par = current_user
        @reversion_veuve_salarie.traite_le = DateTime.now
        @reversion_veuve_salarie.motif = nil
        @reversion_veuve_salarie.est_soumis!
        @reversion_veuve_salarie.save
        redirect_to [:admin, @reversion_veuve_salarie], notice: 'La demande de liquidation est soumise'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @reversion_veuve_salarie]
      end
    else
      redirect_to [:admin, @reversion_veuve_salarie]
    end
  end

  def instruire_action
    if current_user.can_instruction? and @reversion_veuve_salarie.ajoute_par.admin_agence != current_user.admin_agence
      flash[:error] = 'Vous n\'avez pas le droit de faire une action sur ce dossier'
      redirect_to [:admin, @reversion_veuve_salarie]
      return
    end

    if @reversion_veuve_salarie.soumis?
      if @reversion_veuve_salarie.update(commentaire_instruction_params.merge(motif: nil))

        @reversion_veuve_salarie.traite_par = current_user
        @reversion_veuve_salarie.instruit_par = current_user
        @reversion_veuve_salarie.instruit_le = DateTime.now
        @reversion_veuve_salarie.est_instruit!
        @reversion_veuve_salarie.save
        redirect_to [:admin, @reversion_veuve_salarie], notice: 'Demande Instruit'
        else
          flash[:error] = 'Une erreur est survenue lors du traitement'
          redirect_to [:admin, @reversion_veuve_salarie]
        end
    else
      redirect_to [:admin, @reversion_veuve_salarie]
    end
  end


  def valider_carriere_action

    if @reversion_veuve_salarie.instruit?
      if @reversion_veuve_salarie.update(commentaire_carriere_params.merge(motif: nil))

        @reversion_veuve_salarie.soumission_carriere_par = current_user
        @reversion_veuve_salarie.traite_par = current_user
        @reversion_veuve_salarie.date_soumission_carriere = DateTime.now
        @reversion_veuve_salarie.motif = nil
        @reversion_veuve_salarie.est_carriere_soumis!
        #@reversion_veuve_salarie.date_generation = DateTime.now # Ajouter la date de generation de la lettre de notification de la liquidation
        @reversion_veuve_salarie.save

        redirect_to [:admin, @reversion_veuve_salarie], notice: 'Carrière soumis pour validation'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @reversion_veuve_salarie]
      end
    else
      redirect_to [:admin, @reversion_veuve_salarie]
    end

  end

  def cotisation_valide_action
      if @reversion_veuve_salarie.cotisation_valide?
        redirect_to [:admin, @reversion_veuve_salarie]
      else
        if @reversion_veuve_salarie.update(commentaire_validation_carriere_params.merge(motif: nil))

          @reversion_veuve_salarie.validation_carriere_par = current_user
          @reversion_veuve_salarie.traite_par = current_user
          @reversion_veuve_salarie.date_validation_carriere = DateTime.now
          @reversion_veuve_salarie.motif = nil
          @reversion_veuve_salarie.est_carriere_valide!
          @reversion_veuve_salarie.save

          redirect_to [:admin, @reversion_veuve_salarie], notice: 'Carrière validée avec succés'
        else
          flash[:error] = 'Une erreur est survenue lors du traitement'
          redirect_to [:admin, @reversion_veuve_salarie]
        end

      end
  end

  def valider_recapitulatif_action
    if @reversion_veuve_salarie.cotisation_valide?
      if @reversion_veuve_salarie.update(commentaire_tableau_params.merge(motif: nil))

        @reversion_veuve_salarie.soumission_validation_par = current_user
        @reversion_veuve_salarie.traite_par = current_user
        @reversion_veuve_salarie.date_soumission_validation = DateTime.now
        @reversion_veuve_salarie.est_recap_soumis!
        @reversion_veuve_salarie.save
        redirect_to [:admin, @reversion_veuve_salarie], notice: 'Recap soumis pour validation'

      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @reversion_veuve_salarie]
      end
    else
      redirect_to [:admin, @reversion_veuve_salarie]
    end

  end


  def liquidation_valide_action
      if @reversion_veuve_salarie.recap_soumis?
        if @reversion_veuve_salarie.update(commentaire_validation_tableau_params.merge(motif: nil))

          @reversion_veuve_salarie.validation_liquidation_par = current_user
          @reversion_veuve_salarie.traite_par = current_user
          @reversion_veuve_salarie.date_validation_liquidation = DateTime.now
          @reversion_veuve_salarie.motif = nil
          @reversion_veuve_salarie.est_recap_valide!
          @reversion_veuve_salarie.save

          redirect_to [:admin, @reversion_veuve_salarie], notice: 'Recap validée avec succés'
        else
          flash[:error] = 'Une erreur est survenue lors du traitement'
          redirect_to [:admin, @reversion_veuve_salarie]
        end

      else
        redirect_to [:admin, @reversion_veuve_salarie]
      end
  end

  def dossier_valide_action
    if @reversion_veuve_salarie.update(commentaire_validation_params.merge(motif: nil))

      @reversion_veuve_salarie.traite_par = current_user
        if @reversion_veuve_salarie.est_dossier_valide!
          @reversion_veuve_salarie.valider_par = current_user
          @reversion_veuve_salarie.valider_le = DateTime.now
          @reversion_veuve_salarie.traite_le = DateTime.now
          @reversion_veuve_salarie.save
        elsif @reversion_veuve_salarie.halted?
          flash[:error] = @reversion_veuve_salarie.halted_because
        else
          flash[:error] = 'Une erreur est survenue lors de la validation du dossier'
        end
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Dossier validé avec succés'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      redirect_to [:admin, @reversion_veuve_salarie]
    end
  end
  ##############

  def soumettre
    if @reversion_veuve_salarie.creation?
      @reversion_veuve_salarie.est_soumis!
      @reversion_veuve_salarie.date_soumission = DateTime.now
      @reversion_veuve_salarie.traite_par = current_user
      @reversion_veuve_salarie.traite_le = DateTime.now
      @reversion_veuve_salarie.motif = nil
      @reversion_veuve_salarie.save
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'La demande est soumise'
    else
      redirect_to [:admin, @reversion_veuve_salarie]
    end

  end

  def instruire
    if @reversion_veuve_salarie.soumis?
      @reversion_veuve_salarie.est_instruit!
      @reversion_veuve_salarie.instruit_par = current_user
      @reversion_veuve_salarie.instruit_le = DateTime.now
      @reversion_veuve_salarie.motif = nil
      @reversion_veuve_salarie.save
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Demande Instruite'
    else
      redirect_to [:admin, @reversion_veuve_salarie]
    end
  end

  def carriere_valide
    @reversion_veuve_salarie.carriere_valide!
    @reversion_veuve_salarie.soumission_carriere_par = current_user
    @reversion_veuve_salarie.date_soumission_carriere = DateTime.now
    @reversion_veuve_salarie.motif = nil
    @reversion_veuve_salarie.save
    flash[:notice] = 'Carrière soumis pour validation'
    redirect_to [:admin, @reversion_veuve_salarie]
  end

  def valider_cotisation
    if @reversion_veuve_salarie.cotisation_valide?
      redirect_to [:admin, @reversion_veuve_salarie]
    else
      @reversion_veuve_salarie.est_carriere_valide!
      @reversion_veuve_salarie.validation_carriere_par = current_user
      @reversion_veuve_salarie.date_validation_carriere = DateTime.now
      @reversion_veuve_salarie.motif = nil
      @reversion_veuve_salarie.save
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Carrière validée avec succés'

    end
  end

  def valider_recapitulatif
    if @reversion_veuve_salarie.cotisation_valide?
      @reversion_veuve_salarie.est_recap_soumis!
      @reversion_veuve_salarie.soumission_validation_par = current_user
      @reversion_veuve_salarie.traite_par = current_user
      @reversion_veuve_salarie.date_soumission_validation = DateTime.now
      @reversion_veuve_salarie.motif = nil
      @reversion_veuve_salarie.save
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Recap soumis pour validation'
    else
      redirect_to [:admin, @reversion_veuve_salarie]
    end
  end

  def recap_valide
    if @reversion_veuve_salarie.cotisation_valide?
      redirect_to [:admin, @reversion_veuve_salarie]
    else
      @reversion_veuve_salarie.est_recap_valide!
      @reversion_veuve_salarie.soumission_validation_par = current_user
      @reversion_veuve_salarie.traite_par = current_user
      @reversion_veuve_salarie.date_soumission_validation = DateTime.now
      @reversion_veuve_salarie.motif = nil
      @reversion_veuve_salarie.save
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Recap soumis pour validation'
    end
  end

  def liquidation_valide
    if @reversion_veuve_salarie.recap_soumis?
      @reversion_veuve_salarie.est_recap_valide!
      @reversion_veuve_salarie.validation_liquidation_par = current_user
      @reversion_veuve_salarie.traite_par = current_user
      @reversion_veuve_salarie.date_validation_liquidation = DateTime.now
      @reversion_veuve_salarie.motif = nil
      @reversion_veuve_salarie.save
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Recap validée avec succés'
    else
      redirect_to [:admin, @reversion_veuve_salarie]
    end
  end

  def dossier_valide
    if @reversion_veuve_salarie.liquidation_valide?
      puts "========> dossier_valide"
      @reversion_veuve_salarie.est_dossier_valide!
      @reversion_veuve_salarie.valider_par = current_user
      @reversion_veuve_salarie.valider_le = DateTime.now
      @reversion_veuve_salarie.traite_le = DateTime.now
      @reversion_veuve_salarie.traite_par = current_user
      @reversion_veuve_salarie.motif = nil
      @reversion_veuve_salarie.save
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Dossier validé avec succés'
      else
        redirect_to [:admin, @reversion_veuve_salarie]
      end
  end

  def retourner_process
    dossier_reversions= @reversion_veuve_salarie.dossier_reversion_salaries
    if @reversion_veuve_salarie.soumis?
      @reversion_veuve_salarie.update(traite_par: nil,
                                  traite_le: nil)
      @reversion_veuve_salarie.retour_creation!
      unless dossier_reversions.nil?
        dossier_reversions.each do |reversion|
          reversion.creation!
        end
      end
    else
      if @reversion_veuve_salarie.instruit?
        @reversion_veuve_salarie.update(instruit_par: nil,
                                    instruit_le: nil)
        @reversion_veuve_salarie.retour_soumis!
      else
        if @reversion_veuve_salarie.carriere_soumis?
          @reversion_veuve_salarie.retour_instruit!
          @reversion_veuve_salarie.retourner_all_carrieres(@reversion_veuve_salarie.carrieres_prestation)
          @reversion_veuve_salarie.update(traite_par: nil,
                                      traite_le: nil)
        else
          if @reversion_veuve_salarie.cotisation_valide?
            @reversion_veuve_salarie.retour_carriere!
            unless dossier_reversions.nil?
              dossier_reversions.each do |reversion|
                reversion.soumis!
              end
            end
            @reversion_veuve_salarie.update(affecter_allocataire: nil,
                                            traite_par: nil,
                                            traite_le: nil)
          else
            if @reversion_veuve_salarie.recap_soumis?
              @reversion_veuve_salarie.retour_cotisation!
                unless dossier_reversions.nil?
                  dossier_reversions.each do |reversion|
                    reversion.soumis!
                  end
                end
              @reversion_veuve_salarie.update(traite_par: nil, traite_le: nil)
            else
              if @reversion_veuve_salarie.liquidation_valide?
                @reversion_veuve_salarie.retour_recap!
                unless dossier_reversions.nil?
                  dossier_reversions.each do |reversion|
                    reversion.recap_soumis!
                  end
                end
                @reversion_veuve_salarie.update(traite_par: nil,
                                            traite_le: nil)
              end
            end
          end
        end
      end
    end
    if @reversion_veuve_salarie.update(reversion_veuve_salarie_rejet_params.merge(traite_par: current_user, traite_le: DateTime.now))
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Deamande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end


  def dossier_rejet
    if @reversion_veuve_salarie.liquidation_valide?
      @reversion_veuve_salarie.est_dossier_rejete!
      @reversion_veuve_salarie.traite_le = DateTime.now
      @reversion_veuve_salarie.traite_par = current_user
      @reversion_veuve_salarie.motif = nil
      @reversion_veuve_salarie.save
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @reversion_veuve_salarie]
    end
  end



  # region : affecter une demande à un/des gestionnaire salarie
  def affecter_salarie
    #affecter une demande à un gestionnaire allocataire
    @reversion_veuve_salarie.update(reversion_veuve_salarie_affecter_salarie_params.merge(affectation_salarie_date: DateTime.now))
    redirect_to [:admin, @reversion_veuve_salarie], notice: 'Demande Affectée.'
  end

  def affecter_salarie_all
    if params["gestionnaires_ids"].nil?
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :en_attente
    else
      reversion_veuve_salarie = BaseReversionSalary.en_attente_cotisation
      #gestionnaires_id = params["gestionnaires_ids"].split(",")

      unless gestionnaires_id.nil?
        reversion_veuve_salarie.each do |reversion_veuve_salarie|
          gestionnaires_id = params["gestionnaires_ids"].split(",")
          gestionnaires_id.delete(reversion_veuve_salarie.ajoute_par.id)
          reversion_veuve_salarie.affectation_salarie = gestionnaires_id.sample
          reversion_veuve_salarie.affectation_salarie_date = DateTime.now
          reversion_veuve_salarie.carriere_valide = true
          reversion_veuve_salarie.save
        end
      end
      redirect_to admin_reversion_veuve_salaries_path, notice: 'Affectation effectuée avec succés'
    end
  end

  def show_facture
   # @demande_liquidation = LiquidationRetraite.find(params[:id] || params[:liquidation_retraite_id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Récépissé demande de liquidation No. #{@reversion_veuve_salarie.id}",
               page_size: 'A4',
               template: "admin/base_reversion_salaries/show_facture.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end



  #endregion


  # region : affecter une demande à un/des gestionnaire allocataire

  def affecter_allocataire
    #affecter une demande à un gestionnaire allocataire
    if @reversion_veuve_salarie.update(reversion_veuve_salarie_affecter_allocataire_params.merge(affectation_allocataire_date: DateTime.now))
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Demande Affectée.'
    end
  end



  #endregion

  # region : valider carriere
    def valider_all_carrieres
      if @reversion_veuve_salarie.instruit?
        carrieres_prestation = @reversion_veuve_salarie.carrieres_prestation
        unless carrieres_prestation.nil?
          carrieres_prestation.each do |carriere|
            carriere.valide! if carriere.en_attente?
          end
        end
        redirect_to [:admin, @reversion_veuve_salarie], notice: 'Tous les points carrières validés avec succés!'
      else
        redirect_to [:admin, @reversion_veuve_salarie]
      end
    end
  
    def valider_ligne_carriere
      carriere_prestation = Carriere.find(params[:carriere_id])
      carriere_prestation.valide!
      redirect_to [:admin, @reversion_veuve_salarie]
    end

    def rejeter_ligne_carriere1
      carriere_prestation = Carriere.find(params[:carriere_id])
      carriere_prestation.rejete!
      redirect_to [:admin, @reversion_veuve_salarie]
    end

    def rejeter_ligne_carriere
      carriere_prestation = Carriere.find(params[:carriere_id])
      if carriere_prestation.update(rejet_ligne_carriere_params.merge(etat: :rejete))
        redirect_to [:admin, @reversion_veuve_salarie], notice: 'ligne de carriere rejetée.'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @reversion_veuve_salarie]
      end
    end




  # endregion


  #base reversion

  def add_base_reversion1
    @reversion_veuve = DossierReversionSalary.update(reversion_veuve_params)
    @reversion_veuve.ajoute_par = current_user
    @reversion_veuve.ajouter_le = DateTime.now
    @reversion_veuve.etat=:soumis
    respond_to do |format|
      if @reversion_veuve.save!
        format.html { redirect_to [:admin, @reversion_veuve_salarie], notice: 'Reversion veuve was successfully created.' }
        format.json { render :show, status: :created, location: @reversion_veuve_salarie }
      else
        format.html { render :new }
        format.json { render json: @reversion_veuve_salarie.errors, status: :unprocessable_entity }
      end
    end
  end

  def soumettre_dossier_reversion
    @dossier_reversion_salaries = DossierReversionSalary.find(params[:base_reversion_id])
    if @dossier_reversion_salaries.update(dossier_reversion_salarie_params.merge(date_soumis: DateTime.now, traite_par: current_user, etat: :soumis))
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Reversion veuve was successfully created.' 
    end
  end


  def create_reversion_orphelin(enfants)
    unless enfants.nil?
      enfants.each do |enfant|
        demandeur =DossierReversionSalary.new
        enf = Enfant.find(enfant)
        demandeur.enfant_id=enfant
        demandeur.conjoint_id=nil
        demandeur.nom = enf.nom
        demandeur.prenom = enf.prenom
        demandeur.date_naissance = enf.date_naissance
        demandeur.numero_affiliation = @reversion_veuve_salarie.numero_affiliation
        demandeur.base_reversion_salary_id = @reversion_veuve_salarie.id
        demandeur.etat = :creation
        demandeur.type_ayant_droit = :orphelin
        demandeur.ajoute_par = current_user
        demandeur.ajouter_le = DateTime.now
        demandeur.save
      end
    end

  end


  def create_reversion_veuve(conjoints)
    puts "==Conjoints", conjoints.inspect
    unless conjoints.nil?
      conjoints.each do |conjoint|
        demandeur = DossierReversionSalary.new
        conj = Conjoint.find(conjoint)
        demandeur.enfant_id=nil
        demandeur.conjoint_id=conjoint
        demandeur.nom = conj.nom
        demandeur.prenom = conj.prenom
        demandeur.date_naissance = conj.date_naissance
        demandeur.date_mariage = conj.date_mariage
        demandeur.numero_affiliation = @reversion_veuve_salarie.numero_affiliation
        demandeur.base_reversion_salary_id = @reversion_veuve_salarie.id
        demandeur.etat = :creation
        demandeur.type_ayant_droit = :veuve
        demandeur.ajoute_par = current_user
        demandeur.ajouter_le = DateTime.now
        demandeur.save
      end
    end

  end

  def ajouter_carriere
    @carriere = Carriere.new(carriere_params)
    @carriere.numero_affiliation = @reversion_veuve_salarie.numero_affiliation
    @carriere.etat = :en_attente
    @carriere.salaire = @carriere.salaire1 + @carriere.salaire2

    if @carriere.save
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Carriere ajoutée.'
    else
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Erreur sur la création.'
    end
  end


  def activer_dossier_incomplet
    if @reversion_veuve_salarie.update(base_reversion_salary_dossier_incomplet)
      redirect_to [:admin, @reversion_veuve_salarie], notice: 'Modification effectuée avec succés.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      redirect_to [:admin, @reversion_veuve_salarie]
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_reversion_veuve_salary
    @reversion_veuve_salarie = BaseReversionSalary.find(params[:id]|| params[:base_reversion_salary_id])
  end

  def set_demandeur
    @demandeur = DemandeurReversion.find(params[:id] || params[:demandeur_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_reversion_veuve_salary_params
    params.require(:base_reversion_salary).permit(:numero_affiliation, :prenom, :nom,
                                                  :date_naissance, :date_deces, :date_cessation_activite, :enfants_id, :conjoints_id, :nombre_enfant_eligible, :nombre_epouses_eligible)
  end

  def admin_exceptional_reversion_veuve_salary_params
    params.require(:base_reversion_salary).permit(:prenom, :nom, :date_naissance, :date_deces, :date_cessation_activite)
  end

  def reversion_veuve_salarie_rejet_params
    params.require(:base_reversion_salary).permit(:motif)
  end

  def reversion_veuve_salarie_affecter_allocataire_params
    params.require(:base_reversion_salary).permit(:affectation_allocataire, :commentaire_affectation_allocataire)
  end

  def reversion_veuve_salarie_affecter_salarie_params
    params.require(:base_reversion_salary).permit(:affectation_salarie, :commentaire_affectation_salaire)
  end
  def dossier_reversion_salarie_params
    params.require(:dossier_reversion_salary).permit(:prenom, :nom, :date_naissance, :lieu_naissance, :adresse,
                                                    :adresse_reception_allocation, :mode_paiement,
                                                    :compte_bancaire_nom_banque, :compte_bancaire_code_banque,
                                                    :compte_bancaire_code_guichet, :compte_bancaire_numero_compte,
                                                    :type_ayant_droit, :conjoint_id, :enfant_id, :nom_tuteur, :prenom_tuteur, :phone, :email, :nombre_epouses_eligible, :nombre_enfant_eligible)
  end

  def carriere_params
    params.require(:carriere).permit(:date_entree, :date_sortie, :type_regime_id, :salaire, :ref_employeur, :exercice, :points, :salaire1, :salaire2, :motif)
  end

  def rejet_ligne_carriere_params
    params.require(:carriere).permit(:motif_rejet)
  end

  def retourner_en_creaation
    ayany_droits=@reversion_veuve_salarie.dossier_reversion_salaries
  end

  def commentaire_soumission_params
    params.require(:base_reversion_salary).permit(:commentaire_soumission)
  end

  def commentaire_instruction_params
    params.require(:base_reversion_salary).permit(:commentaire_instruction)
  end

  def commentaire_carriere_params
    params.require(:base_reversion_salary).permit(:commentaire_carriere)
  end

  def commentaire_validation_carriere_params
    params.require(:base_reversion_salary).permit(:commentaire_validation_carriere)
  end

  def commentaire_tableau_params
    params.require(:base_reversion_salary).permit(:commentaire_tableau)
  end

  def commentaire_validation_tableau_params
    params.require(:base_reversion_salary).permit(:commentaire_validation_tableau)
  end

  def commentaire_validation_params
    params.require(:base_reversion_salary).permit(:commentaire_validation)
  end
  def base_reversion_salary_dossier_incomplet
    params.require(:base_reversion_salary).permit(:not_completed, :motif_not_completed)
  end

end
