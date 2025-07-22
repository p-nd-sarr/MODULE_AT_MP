class Admin::CssTransfertEmployeursController < ApplicationController
  before_action :set_css_transfert_employeur, only: %i[ show edit update destroy retourner change_statut ]

  # GET /css_transfert_employeurs or /css_transfert_employeurs.json
  def index
    @q = CssTransfertEmployeur.all.ransack(params[:q])
    @css_transfert_employeurs = @q.result.order('created_at desc')
    @css_transfert_employeurs = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  # GET /css_transfert_employeurs/1 or /css_transfert_employeurs/1.json
  def show
  end

  # GET /css_transfert_employeurs/new
  def new
    @css_transfert_employeur = CssTransfertEmployeur.new
  end

  # GET /css_transfert_employeurs/1/edit
  def edit
  end

  # POST /css_transfert_employeurs or /css_transfert_employeurs.json
  def create
    @css_transfert_employeur = CssTransfertEmployeur.new(css_transfert_employeur_params)
    @css_transfert_employeur.ajoute_par = current_user
    @css_transfert_employeur.workflow_state = :creation

    respond_to do |format|
      if @css_transfert_employeur.save
        format.html { redirect_to admin_css_transfert_employeur_path(@css_transfert_employeur), notice: "Css transfert employeur créé avec succès." }
        format.json { render :show, status: :created, location: @css_transfert_employeur }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @css_transfert_employeur.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /css_transfert_employeurs/1 or /css_transfert_employeurs/1.json
  def update
    respond_to do |format|
      if @css_transfert_employeur.update(css_transfert_employeur_params)
        format.html { redirect_to admin_css_transfert_employeur_path(@css_transfert_employeur), notice: "Css transfert employeur modifié avec succès." }
        format.json { render :show, status: :ok, location: @css_transfert_employeur }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @css_transfert_employeur.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /css_transfert_employeurs/1 or /css_transfert_employeurs/1.json
  def destroy
    @css_transfert_employeur.destroy

    respond_to do |format|
      format.html { redirect_to admin_css_transfert_employeurs_url, notice: "Css transfert employeur supprimé avec succès." }
      format.json { head :no_content }
    end
  end

  def change_statut
    statut = params[:statut]

    if @css_transfert_employeur.current_state.events.keys.exclude?(statut.to_sym)
      redirect_to admin_css_transfert_employeur_path(@css_transfert_employeur), alert: "Evenement #{statut} non autorisé"
      return
    end

    begin
      @css_transfert_employeur.send("#{statut}!", current_user)
    rescue Workflow::TransitionHalted => e
      redirect_to admin_css_transfert_employeur_path(@css_transfert_employeur), alert: e.message
      return
    end
    if params[:css_transfert_employeur]
      @css_transfert_employeur.update(css_transfert_employeur_params)
    end
    redirect_to admin_css_transfert_employeur_path(@css_transfert_employeur), notice: 'Statut changé'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_css_transfert_employeur
    @css_transfert_employeur = CssTransfertEmployeur.find(params[:id] || params[:css_transfert_employeur_id])
  end

  # Only allow a list of trusted parameters through.
  def css_transfert_employeur_params
    params.require(:css_transfert_employeur).permit(:employeur_matric, :date_transfert, :agence_source_id, :agence_destination_id, :commentaire, :motif_retour)
  end
end
