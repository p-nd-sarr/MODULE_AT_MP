class Admin::ComptaNaturePrestationsController < ApplicationController
  before_action :set_admin_compta_nature_prestation, only: [:show, :edit, :update, :destroy]

  # GET /admin/compta_nature_prestations
  # GET /admin/compta_nature_prestations.json
  def index
    @admin_compta_nature_prestations = Admin::ComptaNaturePrestation.all
  end

  # GET /admin/compta_nature_prestations/1
  # GET /admin/compta_nature_prestations/1.json
  def show
    #show
  end

  # GET /admin/compta_nature_prestations/new
  def new
    @admin_compta_nature_prestation = Admin::ComptaNaturePrestation.new
  end

  # GET /admin/compta_nature_prestations/1/edit
  def edit
    #edit
  end

  # POST /admin/compta_nature_prestations
  # POST /admin/compta_nature_prestations.json
  def create
    @admin_compta_nature_prestation = Admin::ComptaNaturePrestation.new(admin_compta_nature_prestation_params)

    respond_to do |format|
      if @admin_compta_nature_prestation.save
        format.html { redirect_to @admin_compta_nature_prestation, notice: 'Compta nature prestation was successfully created.' }
        format.json { render :show, status: :created, location: @admin_compta_nature_prestation }
      else
        format.html { render :new }
        format.json { render json: @admin_compta_nature_prestation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/compta_nature_prestations/1
  # PATCH/PUT /admin/compta_nature_prestations/1.json
  def update
    respond_to do |format|
      if @admin_compta_nature_prestation.update(admin_compta_nature_prestation_params)
        format.html { redirect_to @admin_compta_nature_prestation, notice: 'Compta nature prestation was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_compta_nature_prestation }
      else
        format.html { render :edit }
        format.json { render json: @admin_compta_nature_prestation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/compta_nature_prestations/1
  # DELETE /admin/compta_nature_prestations/1.json
  def destroy
    @admin_compta_nature_prestation.destroy
    respond_to do |format|
      format.html { redirect_to admin_compta_nature_prestations_url, notice: 'Compta nature prestation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_compta_nature_prestation
      @admin_compta_nature_prestation = Admin::ComptaNaturePrestation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_compta_nature_prestation_params
      params.require(:admin_compta_nature_prestation).permit(:code, :libelle, :entite, :branche)
    end
end
