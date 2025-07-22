class Admin::VillesController < ApplicationController
  before_action :set_admin_ville, only: [:show, :edit, :update, :destroy]

  # GET /admin/villes
  # GET /admin/villes.json
  def index
    @admin_villes = Admin::Ville.all
  end

  # GET /admin/villes/1
  # GET /admin/villes/1.json
  def show
    #show
  end

  # GET /admin/villes/new
  def new
    @admin_ville = Admin::Ville.new
  end

  # GET /admin/villes/1/edit
  def edit
    #edit
  end

  # POST /admin/villes
  # POST /admin/villes.json
  def create
    @admin_ville = Admin::Ville.new(admin_ville_params)

    respond_to do |format|
      if @admin_ville.save
        format.html { redirect_to @admin_ville, notice: 'Ville was successfully created.' }
        format.json { render :show, status: :created, location: @admin_ville }
      else
        format.html { render :new }
        format.json { render json: @admin_ville.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/villes/1
  # PATCH/PUT /admin/villes/1.json
  def update
    respond_to do |format|
      if @admin_ville.update(admin_ville_params)
        format.html { redirect_to @admin_ville, notice: 'Ville was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_ville }
      else
        format.html { render :edit }
        format.json { render json: @admin_ville.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/villes/1
  # DELETE /admin/villes/1.json
  def destroy
    @admin_ville.destroy
    respond_to do |format|
      format.html { redirect_to admin_villes_url, notice: 'Ville was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_ville
      @admin_ville = Admin::Ville.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_ville_params
      params.require(:admin_ville).permit(:admin_departement_id, :code, :designation)
    end
end
