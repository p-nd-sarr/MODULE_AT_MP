class Admin::TypeStatutJuridiquesController < ApplicationController
  before_action :set_admin_type_statut_juridique, only: [:show, :edit, :update, :destroy]

  # GET /admin/type_statut_juridiques
  # GET /admin/type_statut_juridiques.json
  def index
    @admin_type_statut_juridiques = Admin::TypeStatutJuridique.all
  end

  # GET /admin/type_statut_juridiques/1
  # GET /admin/type_statut_juridiques/1.json
  def show
    #show
  end

  # GET /admin/type_statut_juridiques/new
  def new
    @admin_type_statut_juridique = Admin::TypeStatutJuridique.new
  end

  # GET /admin/type_statut_juridiques/1/edit
  def edit
    #edit
  end

  # POST /admin/type_statut_juridiques
  # POST /admin/type_statut_juridiques.json
  def create
    @admin_type_statut_juridique = Admin::TypeStatutJuridique.new(admin_type_statut_juridique_params)

    respond_to do |format|
      if @admin_type_statut_juridique.save
        format.html { redirect_to @admin_type_statut_juridique, notice: 'Type statut juridique was successfully created.' }
        format.json { render :show, status: :created, location: @admin_type_statut_juridique }
      else
        format.html { render :new }
        format.json { render json: @admin_type_statut_juridique.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/type_statut_juridiques/1
  # PATCH/PUT /admin/type_statut_juridiques/1.json
  def update
    respond_to do |format|
      if @admin_type_statut_juridique.update(admin_type_statut_juridique_params)
        format.html { redirect_to @admin_type_statut_juridique, notice: 'Type statut juridique was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_type_statut_juridique }
      else
        format.html { render :edit }
        format.json { render json: @admin_type_statut_juridique.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/type_statut_juridiques/1
  # DELETE /admin/type_statut_juridiques/1.json
  def destroy
    @admin_type_statut_juridique.destroy
    respond_to do |format|
      format.html { redirect_to admin_type_statut_juridiques_url, notice: 'Type statut juridique was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_type_statut_juridique
      @admin_type_statut_juridique = Admin::TypeStatutJuridique.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_type_statut_juridique_params
      params.require(:admin_type_statut_juridique).permit(:code, :description)
    end
end
