class Admin::SecteurActivitesController < Admin::ApplicationController
  before_action :only_admin!
  before_action :set_admin_secteur_activite, only: [:show, :edit, :update, :destroy]

  # GET /admin/secteur_activites
  # GET /admin/secteur_activites.json
  def index
    @admin_secteur_activites = Admin::SecteurActivite.all
  end

  # GET /admin/secteur_activites/1
  # GET /admin/secteur_activites/1.json
  def show
    #show
  end

  # GET /admin/secteur_activites/new
  def new
    @admin_secteur_activite = Admin::SecteurActivite.new
  end

  # GET /admin/secteur_activites/1/edit
  def edit
    #edit
  end

  # POST /admin/secteur_activites
  # POST /admin/secteur_activites.json
  def create
    @admin_secteur_activite = Admin::SecteurActivite.new(admin_secteur_activite_params)

    respond_to do |format|
      if @admin_secteur_activite.save
        format.html { redirect_to @admin_secteur_activite, notice: 'Secteur activite was successfully created.' }
        format.json { render :show, status: :created, location: @admin_secteur_activite }
      else
        format.html { render :new }
        format.json { render json: @admin_secteur_activite.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/secteur_activites/1
  # PATCH/PUT /admin/secteur_activites/1.json
  def update
    respond_to do |format|
      if @admin_secteur_activite.update(admin_secteur_activite_params)
        format.html { redirect_to @admin_secteur_activite, notice: 'Secteur activite was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_secteur_activite }
      else
        format.html { render :edit }
        format.json { render json: @admin_secteur_activite.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/secteur_activites/1
  # DELETE /admin/secteur_activites/1.json
  def destroy
    @admin_secteur_activite.destroy
    respond_to do |format|
      format.html { redirect_to admin_secteur_activites_url, notice: 'Secteur activite was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_secteur_activite
      @admin_secteur_activite = Admin::SecteurActivite.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_secteur_activite_params
      params.require(:admin_secteur_activite).permit(:description)
    end
end
