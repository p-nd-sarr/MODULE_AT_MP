class Admin::DecesEnfantsController < ApplicationController
  before_action :set_admin_deces_enfant, only: [:show, :edit, :update, :destroy]

  # GET /admin/deces_enfants
  # GET /admin/deces_enfants.json
  def index
    @q = DecesEnfant.all.ransack(params[:q])
    @admin_deces_enfants = @q.result.order('prenom asc').page(params[:page]).per(100)
  end

  # GET /admin/deces_enfants/1
  # GET /admin/deces_enfants/1.json
  def show
  end

  # GET /admin/deces_enfants/new
  def new
    @admin_deces_enfant = DecesEnfant.new
  end

  # GET /admin/deces_enfants/1/edit
  def edit
  end

  # POST /admin/deces_enfants
  # POST /admin/deces_enfants.json
  def create
    @admin_deces_enfant = DecesEnfant.new(admin_deces_enfant_params)
    if @admin_deces_enfant.save
      redirect_to admin_deces_enfants_path, notice: "Le décés de l'enfant est enregistré."
    else
      render :new
    end
  end

  # PATCH/PUT /admin/deces_enfants/1
  # PATCH/PUT /admin/deces_enfants/1.json
  def update
    respond_to do |format|
      if @admin_deces_enfant.update(admin_deces_enfant_params)
        format.html { redirect_to admin_deces_enfants_path, notice: 'Deces enfant was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_deces_enfant }
      else
        format.html { render :edit }
        format.json { render json: admin_deces_enfants_path.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/deces_enfants/1
  # DELETE /admin/deces_enfants/1.json
  def destroy
    @admin_deces_enfant.destroy
    respond_to do |format|
      format.html { redirect_to admin_deces_enfants_url, notice: 'Deces enfant was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_deces_enfant
      @admin_deces_enfant = DecesEnfant.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_deces_enfant_params
      params.require(:deces_enfant).permit(:numero_affiliation, :prenom, :nom, :date_naissance, :date_deces, :prenom_salarie, :nom_salarie, :type_piece, :numero_piece, :enfant_id, :justificatif_deces)
    end
end
