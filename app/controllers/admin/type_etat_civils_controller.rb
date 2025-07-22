class Admin::TypeEtatCivilsController < ApplicationController
  before_action :set_admin_type_etat_civil, only: [:show, :edit, :update, :destroy]

  # GET /admin/type_etat_civils
  # GET /admin/type_etat_civils.json
  def index
    @admin_type_etat_civils = Admin::TypeEtatCivil.all
  end

  # GET /admin/type_etat_civils/1
  # GET /admin/type_etat_civils/1.json
  def show
    #show
  end

  # GET /admin/type_etat_civils/new
  def new
    @admin_type_etat_civil = Admin::TypeEtatCivil.new
  end

  # GET /admin/type_etat_civils/1/edit
  def edit
    #edit
  end

  # POST /admin/type_etat_civils
  # POST /admin/type_etat_civils.json
  def create
    @admin_type_etat_civil = Admin::TypeEtatCivil.new(admin_type_etat_civil_params)

    respond_to do |format|
      if @admin_type_etat_civil.save
        format.html { redirect_to @admin_type_etat_civil, notice: 'Type etat civil was successfully created.' }
        format.json { render :show, status: :created, location: @admin_type_etat_civil }
      else
        format.html { render :new }
        format.json { render json: @admin_type_etat_civil.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/type_etat_civils/1
  # PATCH/PUT /admin/type_etat_civils/1.json
  def update
    respond_to do |format|
      if @admin_type_etat_civil.update(admin_type_etat_civil_params)
        format.html { redirect_to @admin_type_etat_civil, notice: 'Type etat civil was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_type_etat_civil }
      else
        format.html { render :edit }
        format.json { render json: @admin_type_etat_civil.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/type_etat_civils/1
  # DELETE /admin/type_etat_civils/1.json
  def destroy
    @admin_type_etat_civil.destroy
    respond_to do |format|
      format.html { redirect_to admin_type_etat_civils_url, notice: 'Type etat civil was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_type_etat_civil
      @admin_type_etat_civil = Admin::TypeEtatCivil.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_type_etat_civil_params
      params.require(:admin_type_etat_civil).permit(:code, :description)
    end
end
