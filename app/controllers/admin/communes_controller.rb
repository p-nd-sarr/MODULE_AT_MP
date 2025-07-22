class Admin::CommunesController < ApplicationController
  before_action :set_admin_commune, only: [:show, :edit, :update, :destroy]

  # GET /admin/communes
  # GET /admin/communes.json
  def index
    @admin_communes = Admin::Commune.all
  end

  # GET /admin/communes/1
  # GET /admin/communes/1.json
  def show
    #show
  end

  # GET /admin/communes/new
  def new
    @admin_commune = Admin::Commune.new
  end

  # GET /admin/communes/1/edit
  def edit
    #edit
  end

  # POST /admin/communes
  # POST /admin/communes.json
  def create
    @admin_commune = Admin::Commune.new(admin_commune_params)

    respond_to do |format|
      if @admin_commune.save
        format.html { redirect_to @admin_commune, notice: 'Commune was successfully created.' }
        format.json { render :show, status: :created, location: @admin_commune }
      else
        format.html { render :new }
        format.json { render json: @admin_commune.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/communes/1
  # PATCH/PUT /admin/communes/1.json
  def update
    respond_to do |format|
      if @admin_commune.update(admin_commune_params)
        format.html { redirect_to @admin_commune, notice: 'Commune was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_commune }
      else
        format.html { render :edit }
        format.json { render json: @admin_commune.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/communes/1
  # DELETE /admin/communes/1.json
  def destroy
    @admin_commune.destroy
    respond_to do |format|
      format.html { redirect_to admin_communes_url, notice: 'Commune was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_commune
      @admin_commune = Admin::Commune.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_commune_params
      params.require(:admin_commune).permit(:admin_ville_id, :code, :designation)
    end
end
