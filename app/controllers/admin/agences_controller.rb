class Admin::AgencesController < ApplicationController
  before_action :set_admin_agence, only: [:show, :edit, :update, :destroy]

  # GET /admin/agences
  # GET /admin/agences.json
  def index
    @admin_agences = Admin::Agence.all.order(:description_ebs)
  end

  # GET /admin/agences/1
  # GET /admin/agences/1.json
  def show
    #show
  end

  # GET /admin/agences/new
  def new
    @admin_agence = Admin::Agence.new
  end

  # GET /admin/agences/1/edit
  def edit
    #edit
  end

  # POST /admin/agences
  # POST /admin/agences.json
  def create
    @admin_agence = Admin::Agence.new(admin_agence_params)

    respond_to do |format|
      if @admin_agence.save
        format.html { redirect_to @admin_agence, notice: 'Agence was successfully created.' }
        format.json { render :show, status: :created, location: @admin_agence }
      else
        format.html { render :new }
        format.json { render json: @admin_agence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/agences/1
  # PATCH/PUT /admin/agences/1.json
  def update
    respond_to do |format|
      if @admin_agence.update(admin_agence_params)
        format.html { redirect_to @admin_agence, notice: 'Agence was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_agence }
      else
        format.html { render :edit }
        format.json { render json: @admin_agence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/agences/1
  # DELETE /admin/agences/1.json
  def destroy
    @admin_agence.destroy
    respond_to do |format|
      format.html { redirect_to admin_agences_url, notice: 'Agence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def single_agence
    @admin_agence = Admin::Agence.find_by(code_psrm: params[:code_agence])
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_admin_agence
    @admin_agence = Admin::Agence.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_agence_params
    params.require(:admin_agence).permit(
        :type_agence, :code, :description_ebs, :code_prest, :description_prest, :code_psrm, :description_psrm, :code_site
      )
    end
end
