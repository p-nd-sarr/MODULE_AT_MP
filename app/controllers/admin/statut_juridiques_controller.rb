class Admin::StatutJuridiquesController < Admin::ApplicationController
  before_action :only_admin!
  before_action :set_admin_statut_juridique, only: [:show, :edit, :update, :destroy]

  # GET /admin/statut_juridiques
  # GET /admin/statut_juridiques.json
  def index
    @admin_statut_juridiques = Admin::StatutJuridique.all
  end

  # GET /admin/statut_juridiques/1
  # GET /admin/statut_juridiques/1.json
  def show
    #show
  end

  # GET /admin/statut_juridiques/new
  def new
    @admin_statut_juridique = Admin::StatutJuridique.new
  end

  # GET /admin/statut_juridiques/1/edit
  def edit
    #edit
  end

  # POST /admin/statut_juridiques
  # POST /admin/statut_juridiques.json
  def create
    @admin_statut_juridique = Admin::StatutJuridique.new(admin_statut_juridique_params)

    respond_to do |format|
      if @admin_statut_juridique.save
        format.html { redirect_to @admin_statut_juridique, notice: 'Statut juridique was successfully created.' }
        format.json { render :show, status: :created, location: @admin_statut_juridique }
      else
        format.html { render :new }
        format.json { render json: @admin_statut_juridique.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/statut_juridiques/1
  # PATCH/PUT /admin/statut_juridiques/1.json
  def update
    respond_to do |format|
      if @admin_statut_juridique.update(admin_statut_juridique_params)
        format.html { redirect_to @admin_statut_juridique, notice: 'Statut juridique was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_statut_juridique }
      else
        format.html { render :edit }
        format.json { render json: @admin_statut_juridique.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/statut_juridiques/1
  # DELETE /admin/statut_juridiques/1.json
  def destroy
    @admin_statut_juridique.destroy
    respond_to do |format|
      format.html { redirect_to admin_statut_juridiques_url, notice: 'Statut juridique was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_statut_juridique
      @admin_statut_juridique = Admin::StatutJuridique.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_statut_juridique_params
      params.require(:admin_statut_juridique).permit(:code, :description)
    end
end
