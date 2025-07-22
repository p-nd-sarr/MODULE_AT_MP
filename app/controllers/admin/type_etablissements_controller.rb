class Admin::TypeEtablissementsController < ApplicationController
  before_action :set_admin_type_etablissement, only: [:show, :edit, :update, :destroy]

  # GET /admin/type_etablissements
  # GET /admin/type_etablissements.json
  def index
    @admin_type_etablissements = Admin::TypeEtablissement.all
  end

  # GET /admin/type_etablissements/1
  # GET /admin/type_etablissements/1.json
  def show
    #show
  end

  # GET /admin/type_etablissements/new
  def new
    @admin_type_etablissement = Admin::TypeEtablissement.new
  end

  # GET /admin/type_etablissements/1/edit
  def edit
    #edit
  end

  # POST /admin/type_etablissements
  # POST /admin/type_etablissements.json
  def create
    @admin_type_etablissement = Admin::TypeEtablissement.new(admin_type_etablissement_params)

    respond_to do |format|
      if @admin_type_etablissement.save
        format.html { redirect_to @admin_type_etablissement, notice: 'Type etablissement was successfully created.' }
        format.json { render :show, status: :created, location: @admin_type_etablissement }
      else
        format.html { render :new }
        format.json { render json: @admin_type_etablissement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/type_etablissements/1
  # PATCH/PUT /admin/type_etablissements/1.json
  def update
    respond_to do |format|
      if @admin_type_etablissement.update(admin_type_etablissement_params)
        format.html { redirect_to @admin_type_etablissement, notice: 'Type etablissement was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_type_etablissement }
      else
        format.html { render :edit }
        format.json { render json: @admin_type_etablissement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/type_etablissements/1
  # DELETE /admin/type_etablissements/1.json
  def destroy
    @admin_type_etablissement.destroy
    respond_to do |format|
      format.html { redirect_to admin_type_etablissements_url, notice: 'Type etablissement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_type_etablissement
      @admin_type_etablissement = Admin::TypeEtablissement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_type_etablissement_params
      params.require(:admin_type_etablissement).permit(:code, :description)
    end
end
