class Admin::TypeEmployeursController < Admin::ApplicationController
  before_action :only_admin!
  before_action :set_admin_type_employeur, only: [:show, :edit, :update, :destroy]

  # GET /admin/type_employeurs
  # GET /admin/type_employeurs.json
  def index
    @admin_type_employeurs = Admin::TypeEmployeur.all
  end

  # GET /admin/type_employeurs/1
  # GET /admin/type_employeurs/1.json
  def show
    #show
  end

  # GET /admin/type_employeurs/new
  def new
    @admin_type_employeur = Admin::TypeEmployeur.new
  end

  # GET /admin/type_employeurs/1/edit
  def edit
    #edit
  end

  # POST /admin/type_employeurs
  # POST /admin/type_employeurs.json
  def create
    @admin_type_employeur = Admin::TypeEmployeur.new(admin_type_employeur_params)

    respond_to do |format|
      if @admin_type_employeur.save
        format.html { redirect_to @admin_type_employeur, notice: 'Type employeur was successfully created.' }
        format.json { render :show, status: :created, location: @admin_type_employeur }
      else
        format.html { render :new }
        format.json { render json: @admin_type_employeur.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/type_employeurs/1
  # PATCH/PUT /admin/type_employeurs/1.json
  def update
    respond_to do |format|
      if @admin_type_employeur.update(admin_type_employeur_params)
        format.html { redirect_to @admin_type_employeur, notice: 'Type employeur was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_type_employeur }
      else
        format.html { render :edit }
        format.json { render json: @admin_type_employeur.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/type_employeurs/1
  # DELETE /admin/type_employeurs/1.json
  def destroy
    @admin_type_employeur.destroy
    respond_to do |format|
      format.html { redirect_to admin_type_employeurs_url, notice: 'Type employeur was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_type_employeur
      @admin_type_employeur = Admin::TypeEmployeur.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_type_employeur_params
      params.require(:admin_type_employeur).permit(:code, :description)
    end
end
