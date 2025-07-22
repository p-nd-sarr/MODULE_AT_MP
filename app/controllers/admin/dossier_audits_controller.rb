class Admin::DossierAuditsController < ApplicationController

  before_action :set_dossier_audit, only: [:show, :edit, :update, :destroy, :change_statut, :annuler_affectation_dossier, :affecter_dossier, :activities, :create_activity, :update_activity, :delete_activity, :activity_details, :create_recommandation, :delete_recommandation, :update_recommandation, :change_activity_statut, :get_activity_ready, :generate_audit_report]
  before_action :set_activity, only: [:update_activity, :delete_activity, :activity_details, :create_recommandation, :update_recommandation, :change_activity_statut, :get_activity_ready]
  before_action :set_recommandation, only: [:delete_recommandation, :update_recommandation]
  before_action :can_be_ready, only: [:get_activity_ready]

  # GET dossier_audits
  # GET dossier_audits.json
  def index
    @q = DossierAudit.where(admin_agence_id: current_user.agence.id).ransack(params[:q])
    @dossier_audits = @q.result.order('created_at desc')
    @dossier_audits = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  # GET dossier_audits/1
  # GET dossier_audits/1.json
  def show
    @agents = User.users_for_type('auditeur').en_agence(current_user.agence_id).page(params[:page]).per(10)
  end

  # GET dossier_audits/new
  def new
    @dossier_audit = DossierAudit.new
  end

  # GET dossier_audits/1/edit
  def edit
  end

  # POST /dossier_audits
  # POST /dossier_audits.json
  def create
    @dossier_audit = DossierAudit.new(dossier_audit_params)
    @dossier_audit.ajoute_par = current_user
    @dossier_audit.agence = current_user.admin_agence
    @dossier_audit.workflow_state = :creation

    respond_to do |format|
      if @dossier_audit.save
        format.html { redirect_to admin_dossier_audit_path(@dossier_audit), notice: 'Dossier audit créé avec sucès.' }
        format.json { render :show, status: :created, location: @dossier_juridique }
      else
        format.html { render :new }
        format.json { render json: @dossier_audit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dossier_audits/1
  # PATCH/PUT /dossier_audits/1.json
  def update
    respond_to do |format|
      if @dossier_audit.update(dossier_audit_params)
        format.html { redirect_to admin_dossier_audit_path(@dossier_audit), notice: 'Dossier audit modifié avec sucès.' }
        format.json { render :show, status: :ok, location: @dossier_audit }
      else
        format.html { render :edit }
        format.json { render json: @dossier_audit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dossier_audits/1
  # DELETE /dossier_audits/1.json
  def destroy
    @dossier_audit.destroy
    respond_to do |format|
      format.html { redirect_to admin_dossier_audits_path, notice: 'Dossier audit supprimé avec sucès.' }
      format.json { head :no_content }
    end
  end

  def en_attente_validation
    if current_user.chef_service_audit? or current_user.chef_service_controle_interne?
      @q = DossierAudit.en_attente_validation_chef_service.where(admin_agence_id: current_user.agence.id).ransack(params[:q])
    elsif current_user.directeur_audit?
      @q = DossierAudit.en_attente_validation_directeur.where(admin_agence_id: current_user.agence.id).ransack(params[:q])
    end
    @dossier_audits = @q.result.order('created_at desc').page(params[:page]).per(100)
  end

  def affecter_dossier
    @agent = User.find(params[:agent_id])
    @dossier_audit.set_as_agent_chosen(@agent.id)
    redirect_to admin_dossier_audit_path(@dossier_audit), notice: 'Agent affecté au dossier avec succès.'
  end

  def annuler_affectation_dossier
    @agent = User.find(params[:agent_id])
    @dossier_audit.is_not_agent_chosen_anymore(@agent.id)
    redirect_to admin_dossier_audit_path(@dossier_audit), notice: 'Agent retiré de la liste des ressources du dossier.'
  end

  def change_statut
    statut = params[:statut]

    if @dossier_audit.current_state.events.keys.exclude?(statut.to_sym)
      redirect_to admin_dossier_audit_path(@dossier_audit), alert: "Evenement #{statut} non autorisé"
      return
    end

    begin
      @dossier_audit.send("#{statut}!", current_user)
    rescue Workflow::TransitionHalted => e
      redirect_to admin_dossier_audit_path(@dossier_audit), alert: e.message
      return
    end
    if params[:dossier_audit]
      @dossier_audit.update(dossier_audit_params)
    end
    redirect_to admin_dossier_audit_path(@dossier_audit), notice: 'Statut changé'
  end

  def change_activity_statut
    statut = params[:statut]
    if @activity.current_state.events.keys.exclude?(statut.to_sym)
      redirect_to admin_dossier_audit_activity_details_path(@dossier_audit, @activity), alert: "Evenement #{statut} non autorisé"
      return
    end

    begin
      @activity.send("#{statut}!", current_user)
    rescue Workflow::TransitionHalted => e
      redirect_to admin_dossier_audit_activity_details_path(@dossier_audit, @activity), alert: e.message
      return
    end
    if params[:dossier_audit_activity]
      @activity.update(activities_params)
    end
    redirect_to admin_dossier_audit_activity_details_path(@dossier_audit, @activity), notice: 'Statut changé'
  end

  def activities
    @activity = DossierAuditActivity.new
    params[:q] ||= {}
    if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day
    end
    @q = @dossier_audit.dossier_audit_activities.order('created_at desc').ransack(params[:q])
    @activities = @q.result.page(params[:page]).per(20)
  end

  def get_activity_ready
    @dossier_audit.make_activity_ready(@activity.id)
    redirect_to admin_dossier_audit_activity_details_path(@dossier_audit, @activity)
  end

  def activites_en_attente_validation
    if current_user.chef_service_audit? or current_user.chef_service_controle_interne?
      @q = DossierAuditActivity.joins(:dossier_audit).where(dossier_audits: { admin_agence_id: current_user.agence.id }).en_attente_validation_chef_service.ransack(params[:q])
    end
    @activities = @q.result.order('created_at desc').page(params[:page]).per(10)
  end

  def activity_details
    @q = @activity.activity_recommandations.order('created_at desc').ransack(params[:q])
    @activity_recs = @q.result.page(params[:page]).per(10)
    @activity_rec = ActivityRecommandation.new
    @validators = User.validators_for_audit
  end

  def create_activity
    @activity = DossierAuditActivity.new(activities_params)
    @activity.ajoute_par = current_user
    @activity.dossier_audits_id = @dossier_audit.id
    @activity.workflow_state = :creation

    if @activity.save
      redirect_to admin_dossier_audit_activities_path(@dossier_audit), notice: "Activité enregistrée avec succès"
    else
      error_message = @activity.errors.full_messages
      flash[:error] = "Une erreur est survenue lors de la création", error_message
      redirect_to admin_dossier_audit_activities_path(@dossier_audit)
    end
  end

  def update_activity
    if @activity.update(activities_params)
      redirect_to admin_dossier_audit_activity_details_path(@dossier_audit, @activity), notice: "Activité modifié avec succès"
    else
      error_message = @activity.errors.full_messages
      flash[:error] = "Une erreur est survenue lors de la modification", error_message
      redirect_to admin_dossier_audit_activity_details_path(@dossier_audit, @activity)
    end
  end

  def delete_activity
    if @activity.destroy
      redirect_to admin_dossier_audit_activities_path(@dossier_audit), notice: "Activité supprimée avec succès"
    end
  end

  def create_recommandation
    @activity_recommandation = ActivityRecommandation.new(activity_recommandation_params)
    @activity_recommandation.ajoute_par = current_user
    @activity_recommandation.dossier_audit_activities_id = @activity.id
    @activity_recommandation.dossier_audits_id = @dossier_audit.id

    if @activity_recommandation.save
      redirect_to admin_dossier_audit_activity_details_path(@dossier_audit, @activity), notice: "Recommandation enregistrée avec succès"
    else
      error_message = @activity_recommandation.errors.full_messages
      flash[:error] = "Une erreur est survenue lors de la création", error_message
      redirect_to admin_dossier_audit_activity_details_path(@dossier_audit, @activity)
    end
  end

  def update_recommandation
    @activity_rec.date_response = Date.today
    @activity_rec.response_par = current_user

    if @activity_rec.update(activity_recommandation_params)
      redirect_to admin_dossier_audits_recommandations_en_attente_path, notice: "Recommandation modifiée avec succès"
    else
      error_message = @activity_rec.errors.full_messages
      flash[:error] = "Une erreur est survenue lors de la modification", error_message
      redirect_to admin_dossier_audits_recommandations_en_attente_path
    end
  end

  def delete_recommandation
    if @activity_rec.destroy
      redirect_to admin_dossier_audit_activity_details_path(@dossier_audit, @activity_rec.dossier_audit_activity), notice: "Activité supprimée avec succès"
    end
  end

  def recommandations_en_attente
    @q = ActivityRecommandation.where(affecte_a_id: current_user.id).order('created_at desc').ransack(params[:q])
    @activity_recs = @q.result.page(params[:page]).per(10)
  end

  def generate_audit_report
    @agents = @dossier_audit.dossier_audit_affectations
    @activities = @dossier_audit.dossier_audit_activities
    @activity_rec = @dossier_audit.activity_recommandations
    respond_to do |format|
      format.html
      format.pdf do
        generated_pdf = render_to_string pdf: "RAPPORT D'AUDIT",
                                         page_size: 'A4',
                                         template: "admin/dossier_audits/generate_audit_report.html.erb",
                                         layout: "pdf.html",
                                         orientation: "Landscape",
                                         lowquality: true,
                                         zoom: 1,
                                         pi: 75
        pdf = CombinePDF.new
        pdf << CombinePDF.parse(generated_pdf)
        pdf_first_page = pdf.pages[0]
        mediabox = pdf_first_page[:CropBox] || pdf_first_page[:MediaBox]
        title_page = CombinePDF.create_page mediabox
        full_name = 'Lettre de mission'
        title_page.textbox full_name, font_color: [0.8, 0, 0], font_size: :fit_text, box_color: [1, 0.8, 0.8], opacity: 1
        pdf << title_page
        @dossier_audit.documents.each do |att|
          if att.document.attached?
            lm = att.document.download
            pdf << CombinePDF.parse(lm)
          end
        end
        title_page = CombinePDF.create_page mediabox
        full_name = 'Les pieces jointes des recommandations'
        title_page.textbox full_name, font_color: [0.8, 0, 0], font_size: :fit_text, box_color: [1, 0.8, 0.8], opacity: 1
        pdf << title_page
        @activity_rec.each do |activity_rec|
          if activity_rec.response_file.attached?
            rf = activity_rec.response_file.download
            pdf << CombinePDF.parse(rf)
          end
        end
        send_data pdf.to_pdf, filename: "rapport_audit.pdf", type: "application/pdf"
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dossier_audit
    @dossier_audit = DossierAudit.find(params[:id] || params[:dossier_audit_id])
  end

  def set_activity
    @activity = DossierAuditActivity.find(params[:activity_id])
  end

  def set_recommandation
    @activity_rec = ActivityRecommandation.find(params[:activity_rec_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dossier_audit_params
    params.require(:dossier_audit).permit(:description, :motif, :objectifs, :etendu_controle, :techniques_controle, :date_debut, :programme_travail, :motif_rejet)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activities_params
    params.require(:dossier_audit_activity).permit(:description, :incident, :evaluation_incident, :plan_actions, :motif_rejet)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_recommandation_params
    params.require(:activity_recommandation).permit(:recommandation, :affecte_a_id, :recommandation, :direction_response, :response_file)
  end

  def can_be_ready
    if @activity.activity_recommandations.exists?(direction_response: nil)
      flash[:error] = "Toutes les recommandations doivent avoir une réponse de la direction concernée !."
      redirect_to admin_dossier_audit_activity_details_path(@dossier_audit, @activity)
    end
  end
end
