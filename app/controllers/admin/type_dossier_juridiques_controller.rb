class Admin::TypeDossierJuridiquesController < ApplicationController
  before_action :set_admin_type_dossier_juridique, only: [:show, :edit, :update, :destroy]

  # GET /admin/type_dossier_juridiques
  # GET /admin/type_dossier_juridiques.json
  def index
    @admin_type_dossier_juridiques = Admin::TypeDossierJuridique.all
  end

  # GET /admin/type_dossier_juridiques/1
  # GET /admin/type_dossier_juridiques/1.json
  def show
  end

  # GET /admin/type_dossier_juridiques/new
  def new
    @admin_type_dossier_juridique = Admin::TypeDossierJuridique.new
  end

  # GET /admin/type_dossier_juridiques/1/edit
  def edit
  end

  # POST /admin/type_dossier_juridiques
  # POST /admin/type_dossier_juridiques.json
  def create
    @admin_type_dossier_juridique = Admin::TypeDossierJuridique.new(admin_type_dossier_juridique_params)

    respond_to do |format|
      if @admin_type_dossier_juridique.save
        format.html { redirect_to @admin_type_dossier_juridique, notice: 'Type dossier juridique a été créé avec succès.' }
        format.json { render :show, status: :created, location: @admin_type_dossier_juridique }
      else
        format.html { render :new }
        format.json { render json: @admin_type_dossier_juridique.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/type_dossier_juridiques/1
  # PATCH/PUT /admin/type_dossier_juridiques/1.json
  def update
    respond_to do |format|
      if @admin_type_dossier_juridique.update(admin_type_dossier_juridique_params)
        format.html { redirect_to @admin_type_dossier_juridique, notice: 'Type dossier juridique a été modifié avec succès.' }
        format.json { render :show, status: :ok, location: @admin_type_dossier_juridique }
      else
        format.html { render :edit }
        format.json { render json: @admin_type_dossier_juridique.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/type_dossier_juridiques/1
  # DELETE /admin/type_dossier_juridiques/1.json
  def destroy
    @admin_type_dossier_juridique.destroy
    respond_to do |format|
      format.html { redirect_to admin_type_dossier_juridiques_url, notice: 'Type dossier a été supprimé avec succès.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_admin_type_dossier_juridique
    @admin_type_dossier_juridique = Admin::TypeDossierJuridique.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_type_dossier_juridique_params
    params.require(:admin_type_dossier_juridique).permit(:title, :description)
  end
end
