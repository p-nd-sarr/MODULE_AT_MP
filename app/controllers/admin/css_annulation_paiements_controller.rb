class Admin::CssAnnulationPaiementsController < ApplicationController
  before_action :set_css_annulation_paiement, only: %i[ show edit update destroy marquer_impaye rendre_impaye ]

  # GET /css_annulation_paiements or /css_annulation_paiements.json
  def index
    @q = OrdrePaiement.css.payes_encours.ransack(params[:q])
    @css_annulation_paiements = @q.result.order('created_at desc')
    @css_annulation_paiements = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  # GET /css_annulation_paiements/1 or /css_annulation_paiements/1.json
  def show
  end

  # GET /css_annulation_paiements/new
  def new
    @css_annulation_paiement = CssAnnulationPaiement.new
  end

  # GET /css_annulation_paiements/1/edit
  def edit
  end

  # POST /css_annulation_paiements or /css_annulation_paiements.json
  def create
    @css_annulation_paiement = CssAnnulationPaiement.new(css_annulation_paiement_params)

    respond_to do |format|
      if @css_annulation_paiement.save
        format.html { redirect_to css_annulation_paiement_url(@css_annulation_paiement), notice: "Css annulation paiement was successfully created." }
        format.json { render :show, status: :created, location: @css_annulation_paiement }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @css_annulation_paiement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /css_annulation_paiements/1 or /css_annulation_paiements/1.json
  def update
    respond_to do |format|
      if @css_annulation_paiement.update(css_annulation_paiement_params)
        format.html { redirect_to css_annulation_paiement_url(@css_annulation_paiement), notice: "Css annulation paiement was successfully updated." }
        format.json { render :show, status: :ok, location: @css_annulation_paiement }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @css_annulation_paiement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /css_annulation_paiements/1 or /css_annulation_paiements/1.json
  def destroy
    @css_annulation_paiement.destroy

    respond_to do |format|
      format.html { redirect_to css_annulation_paiements_url, notice: "Css annulation paiement was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def en_attente_validation_impayes
    @q = OrdrePaiement.css.marques_impayes.ransack(params[:q])
    @css_annulation_paiements = @q.result.order('created_at desc')
    @css_annulation_paiements = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def marquer_impaye
    motif = css_annulation_paiement_params[:motif_impaye]
    @css_annulation_paiement.marquer_impaye(current_user, motif)
    redirect_to admin_css_annulation_paiement_path(@css_annulation_paiement), notice: 'ordre de paiement est marqué impayé avec succés.'
  end

  def rendre_impaye
    @css_annulation_paiement.rendre_impaye(current_user)
    redirect_to en_attente_validation_impayes_admin_css_annulation_paiements_path, notice: 'ordre de paiement est rendu impayé avec succés.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_css_annulation_paiement
    @css_annulation_paiement = OrdrePaiement.find(params[:id] || params[:css_annulation_paiement_id])
  end

  # Only allow a list of trusted parameters through.
  def css_annulation_paiement_params
    params.require(:ordre_paiement).permit(:motif_impaye)
  end
end
