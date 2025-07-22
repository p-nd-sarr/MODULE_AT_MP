class Admin::CipsController < ApplicationController
  before_action :set_cip, only: [:show, :edit, :update, :destroy, :show_recipisse]

  # GET /cips
  # GET /cips.json
  def index
    @q = Cip.all.ransack(params[:q])
    @cips = @q.result.order('created_at desc').page(params[:page]).per(100)
  end

  # GET /cips/1
  # GET /cips/1.json
  def show
  end

  # GET /cips/new
  def new
    @cip = Cip.new
  end

  # GET /cips/1/edit
  def edit
  end

  # POST /cips
  # POST /cips.json
  def create
    @cip = Cip.new(cip_params)

    respond_to do |format|
      if @cip.save
        format.html { redirect_to [:admin, @cip], notice: 'Cip was successfully created.' }
        format.json { render :show, status: :created, location: @cip }
      else
        format.html { render :new }
        format.json { render json: @cip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cips/1
  # PATCH/PUT /cips/1.json
  def update
    respond_to do |format|
      if @cip.update(cip_params)
        format.html { redirect_to [:admin, @cip], notice: 'Cip was successfully updated.' }
        format.json { render :show, status: :ok, location: @cip }
      else
        format.html { render :edit }
        format.json { render json: @cip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cips/1
  # DELETE /cips/1.json
  def destroy
    @cip.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @cip], notice: 'Cip was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def show_recipisse
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Récépissé de dépôt de dossier CIP No. #{@cip.id}",
               page_size: 'A4',
               template: 'admin/cips/show_recipisse.html.erb',
               layout: 'pdf.html',
               orientation: 'Landscape',
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def show_cip_info
    @cip = Cip.find(params[:id])
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cip
    @cip = Cip.find(params[:id] || params[:cip_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cip_params
    params.fetch(:cip, {})
      params.require(:cip).permit(:prenom, :nom, :observation, :nin, :demande_type, :ajoute_par_id, :piece_identite)
    end
end
