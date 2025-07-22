class Admin::ActivitePrincipalesController < Admin::ApplicationController
  before_action :only_admin!
  before_action :set_admin_activite_principale, only: [:show, :edit, :update, :destroy]

  # GET /admin/activite_principales
  # GET /admin/activite_principales.json
  def index
    @admin_activite_principales = Admin::ActivitePrincipale.all
  end

  # GET /admin/activite_principales/1
  # GET /admin/activite_principales/1.json
  def show
    #show
  end

  # GET /admin/activite_principales/new
  def new
    @admin_activite_principale = Admin::ActivitePrincipale.new
  end

  # GET /admin/activite_principales/1/edit
  def edit
    #edit
  end

  # POST /admin/activite_principales
  # POST /admin/activite_principales.json
  def create
    @admin_activite_principale = Admin::ActivitePrincipale.new(admin_activite_principale_params)

    respond_to do |format|
      if @admin_activite_principale.save
        format.html { redirect_to @admin_activite_principale, notice: 'Activite principale was successfully created.' }
        format.json { render :show, status: :created, location: @admin_activite_principale }
      else
        format.html { render :new }
        format.json { render json: @admin_activite_principale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/activite_principales/1
  # PATCH/PUT /admin/activite_principales/1.json
  def update
    respond_to do |format|
      if @admin_activite_principale.update(admin_activite_principale_params)
        format.html { redirect_to @admin_activite_principale, notice: 'Activite principale was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_activite_principale }
      else
        format.html { render :edit }
        format.json { render json: @admin_activite_principale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/activite_principales/1
  # DELETE /admin/activite_principales/1.json
  def destroy
    @admin_activite_principale.destroy
    respond_to do |format|
      format.html { redirect_to admin_activite_principales_url, notice: 'Activite principale was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_activite_principale
      @admin_activite_principale = Admin::ActivitePrincipale.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_activite_principale_params
      params.require(:admin_activite_principale).permit(:admin_secteur_activite_id, :description)
    end
end
