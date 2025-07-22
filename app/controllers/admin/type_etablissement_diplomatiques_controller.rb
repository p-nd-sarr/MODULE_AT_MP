class Admin::TypeEtablissementDiplomatiquesController < ApplicationController
  before_action :set_admin_type_etablissement_diplomatique, only: [:show, :edit, :update, :destroy]

  # GET /admin/type_etablissement_diplomatiques
  # GET /admin/type_etablissement_diplomatiques.json
  def index
    @admin_type_etablissement_diplomatiques = Admin::TypeEtablissementDiplomatique.all
  end

  # GET /admin/type_etablissement_diplomatiques/1
  # GET /admin/type_etablissement_diplomatiques/1.json
  def show
    #show
  end

  # GET /admin/type_etablissement_diplomatiques/new
  def new
    @admin_type_etablissement_diplomatique = Admin::TypeEtablissementDiplomatique.new
  end

  # GET /admin/type_etablissement_diplomatiques/1/edit
  def edit
    #edit
  end

  # POST /admin/type_etablissement_diplomatiques
  # POST /admin/type_etablissement_diplomatiques.json
  def create
    @admin_type_etablissement_diplomatique = Admin::TypeEtablissementDiplomatique.new(admin_type_etablissement_diplomatique_params)

    respond_to do |format|
      if @admin_type_etablissement_diplomatique.save
        format.html { redirect_to @admin_type_etablissement_diplomatique, notice: 'Type etablissement diplomatique was successfully created.' }
        format.json { render :show, status: :created, location: @admin_type_etablissement_diplomatique }
      else
        format.html { render :new }
        format.json { render json: @admin_type_etablissement_diplomatique.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/type_etablissement_diplomatiques/1
  # PATCH/PUT /admin/type_etablissement_diplomatiques/1.json
  def update
    respond_to do |format|
      if @admin_type_etablissement_diplomatique.update(admin_type_etablissement_diplomatique_params)
        format.html { redirect_to @admin_type_etablissement_diplomatique, notice: 'Type etablissement diplomatique was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_type_etablissement_diplomatique }
      else
        format.html { render :edit }
        format.json { render json: @admin_type_etablissement_diplomatique.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/type_etablissement_diplomatiques/1
  # DELETE /admin/type_etablissement_diplomatiques/1.json
  def destroy
    @admin_type_etablissement_diplomatique.destroy
    respond_to do |format|
      format.html { redirect_to admin_type_etablissement_diplomatiques_url, notice: 'Type etablissement diplomatique was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_type_etablissement_diplomatique
      @admin_type_etablissement_diplomatique = Admin::TypeEtablissementDiplomatique.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_type_etablissement_diplomatique_params
      params.require(:admin_type_etablissement_diplomatique).permit(:code, :description)
    end
end
