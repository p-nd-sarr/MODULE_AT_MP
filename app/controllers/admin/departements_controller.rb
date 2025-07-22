class Admin::DepartementsController < ApplicationController
  before_action :set_admin_departement, only: [:show, :edit, :update, :destroy]

  # GET /admin/departements
  # GET /admin/departements.json
  def index
    @admin_departements = Admin::Departement.all
  end

  # GET /admin/departements/1
  # GET /admin/departements/1.json
  def show
    #show
  end

  # GET /admin/departements/new
  def new
    @admin_departement = Admin::Departement.new
  end

  # GET /admin/departements/1/edit
  def edit
    #edit
  end

  # POST /admin/departements
  # POST /admin/departements.json
  def create
    @admin_departement = Admin::Departement.new(admin_departement_params)

    respond_to do |format|
      if @admin_departement.save
        format.html { redirect_to @admin_departement, notice: 'Departement was successfully created.' }
        format.json { render :show, status: :created, location: @admin_departement }
      else
        format.html { render :new }
        format.json { render json: @admin_departement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/departements/1
  # PATCH/PUT /admin/departements/1.json
  def update
    respond_to do |format|
      if @admin_departement.update(admin_departement_params)
        format.html { redirect_to @admin_departement, notice: 'Departement was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_departement }
      else
        format.html { render :edit }
        format.json { render json: @admin_departement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/departements/1
  # DELETE /admin/departements/1.json
  def destroy
    @admin_departement.destroy
    respond_to do |format|
      format.html { redirect_to admin_departements_url, notice: 'Departement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_departement
      @admin_departement = Admin::Departement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_departement_params
      params.require(:admin_departement).permit(:region_id, :designation, :code)
    end
end
