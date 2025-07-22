class Admin::TempsTravailsController < ApplicationController
  before_action :set_admin_temps_travail, only: [:show, :edit, :update, :destroy]

  # GET /admin/temps_travails
  # GET /admin/temps_travails.json
  def index
    @admin_temps_travails = Admin::TempsTravail.all
  end

  # GET /admin/temps_travails/1
  # GET /admin/temps_travails/1.json
  def show
    #show
  end

  # GET /admin/temps_travails/new
  def new
    @admin_temps_travail = Admin::TempsTravail.new
  end

  # GET /admin/temps_travails/1/edit
  def edit
    #edit
  end

  # POST /admin/temps_travails
  # POST /admin/temps_travails.json
  def create
    @admin_temps_travail = Admin::TempsTravail.new(admin_temps_travail_params)

    respond_to do |format|
      if @admin_temps_travail.save
        format.html { redirect_to @admin_temps_travail, notice: 'Temps travail was successfully created.' }
        format.json { render :show, status: :created, location: @admin_temps_travail }
      else
        format.html { render :new }
        format.json { render json: @admin_temps_travail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/temps_travails/1
  # PATCH/PUT /admin/temps_travails/1.json
  def update
    respond_to do |format|
      if @admin_temps_travail.update(admin_temps_travail_params)
        format.html { redirect_to @admin_temps_travail, notice: 'Temps travail was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_temps_travail }
      else
        format.html { render :edit }
        format.json { render json: @admin_temps_travail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/temps_travails/1
  # DELETE /admin/temps_travails/1.json
  def destroy
    @admin_temps_travail.destroy
    respond_to do |format|
      format.html { redirect_to admin_temps_travails_url, notice: 'Temps travail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_temps_travail
      @admin_temps_travail = Admin::TempsTravail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_temps_travail_params
      params.require(:admin_temps_travail).permit(:code, :description)
    end
end
