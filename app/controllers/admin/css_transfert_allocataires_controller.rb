class Admin::CssTransfertAllocatairesController < ApplicationController
  before_action :set_css_transfert_allocataire, only: %i[ show edit update destroy change_statut ]

  # GET /css_transfert_allocataires or /css_transfert_allocataires.json
  def index
    @q = CssTransfertAllocataire.all.ransack(params[:q])
    @css_transfert_allocataires = @q.result.order('created_at desc')
    @css_transfert_allocataires = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  # GET /css_transfert_allocataires/1 or /css_transfert_allocataires/1.json
  def show
    @salary = Psrm::Participant.find_by(matric: @css_transfert_allocataire.numero_affiliation)
    @q = EcheanceCaisseDossier.where(num_affiliation: @css_transfert_allocataire.numero_affiliation, employeur_actuel: @css_transfert_allocataire.employeur_source_id).ransack(params[:q])
    @echeance_dossiers = @q.result.order('created_at DESC').page(params[:page]).per(10)
    @q_des = EcheanceCaisseDossier.where(num_affiliation: @css_transfert_allocataire.numero_affiliation, employeur_actuel: @css_transfert_allocataire.employeur_destination_id).ransack(params[:q])
    @echeance_destination_dossiers = @q_des.result.order('created_at DESC').page(params[:page]).per(10)
  end

  # GET /css_transfert_allocataires/new
  def new
    @css_transfert_allocataire = CssTransfertAllocataire.new
  end

  # GET /css_transfert_allocataires/1/edit
  def edit
  end

  # POST /css_transfert_allocataires or /css_transfert_allocataires.json
  def create
    @css_transfert_allocataire = CssTransfertAllocataire.new(css_transfert_allocataire_params)
    @css_transfert_allocataire.ajoute_par = current_user
    @css_transfert_allocataire.workflow_state = :creation

    respond_to do |format|
      if @css_transfert_allocataire.save
        format.html { redirect_to admin_css_transfert_allocataire_path(@css_transfert_allocataire), notice: "Css transfert allocataire a été créé avec succès." }
        format.json { render :show, status: :created, location: @css_transfert_allocataire }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @css_transfert_allocataire.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /css_transfert_allocataires/1 or /css_transfert_allocataires/1.json
  def update
    respond_to do |format|
      if @css_transfert_allocataire.update(css_transfert_allocataire_params)
        format.html { redirect_to admin_css_transfert_allocataire_path(@css_transfert_allocataire), notice: "Css transfert allocataire a été modifié avec succès." }
        format.json { render :show, status: :ok, location: @css_transfert_allocataire }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @css_transfert_allocataire.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /css_transfert_allocataires/1 or /css_transfert_allocataires/1.json
  def destroy
    @css_transfert_allocataire.destroy

    respond_to do |format|
      format.html { redirect_to admin_css_transfert_allocataires_url, notice: "Css transfert allocataire a été supprimé avec succès." }
      format.json { head :no_content }
    end
  end

  def change_statut
    statut = params[:statut]

    if @css_transfert_allocataire.current_state.events.keys.exclude?(statut.to_sym)
      redirect_to admin_css_transfert_allocataire_path(@css_transfert_allocataire), alert: "Evenement #{statut} non autorisé"
      return
    end

    begin
      @css_transfert_allocataire.send("#{statut}!", current_user)
    rescue Workflow::TransitionHalted => e
      redirect_to admin_css_transfert_allocataire_path(@css_transfert_allocataire), alert: e.message
      return
    end
    if params[:css_transfert_allocataire]
      @css_transfert_allocataire.update(css_transfert_allocataire_params)
    end
    redirect_to admin_css_transfert_allocataire_path(@css_transfert_allocataire), notice: 'Statut changé'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_css_transfert_allocataire
    @css_transfert_allocataire = CssTransfertAllocataire.find(params[:id] || params[:css_transfert_allocataire_id])
  end

  # Only allow a list of trusted parameters through.
  def css_transfert_allocataire_params
    params.require(:css_transfert_allocataire).permit(:numero_affiliation, :employeur_source_id, :employeur_destination_id, :date_transfert, :agence_source_id, :agence_destination_id, :commentaire, :motif_retour, :date_embauche)
  end
end
