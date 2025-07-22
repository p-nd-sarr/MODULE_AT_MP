class Admin::EtablissementsController < ApplicationController
  before_action :set_admin_etablissement, only: [:show, :edit, :update, :destroy]

  # GET /admin/etablissements
  # GET /admin/etablissements.json
  def index
    @admin_etablissements = Admin::Etablissement.all
  end

  # GET /admin/etablissements/1
  # GET /admin/etablissements/1.json
  def show
  end

  # GET /admin/etablissements/new
  def new
    @admin_etablissement = Admin::Etablissement.new
  end

  # GET /admin/etablissements/1/edit
  def edit
  end

  # POST /admin/etablissements
  # POST /admin/etablissements.json
  def create
    @admin_etablissement = Admin::Etablissement.new(admin_etablissement_params)

    respond_to do |format|
      if @admin_etablissement.save
        format.html { redirect_to admin_etablissements_path, notice: 'Etablissement was successfully created.' }
        format.json { render :index, status: :created, location: @admin_etablissement }
      else
        format.html { render :new }
        format.json { render json: @admin_etablissement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/etablissements/1
  # PATCH/PUT /admin/etablissements/1.json
  def update
    respond_to do |format|
      if @admin_etablissement.update(admin_etablissement_params)
        format.html { redirect_to admin_etablissements_path, notice: 'Etablissement was successfully updated.' }
        format.json { render :index, status: :ok, location: @admin_etablissement }
      else
        format.html { render :edit }
        format.json { render json: @admin_etablissement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/etablissements/1
  # DELETE /admin/etablissements/1.json
  def destroy
    @admin_etablissement.destroy
    respond_to do |format|
      format.html { redirect_to admin_etablissements_url, notice: 'Etablissement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_etablissement
      @admin_etablissement = Admin::Etablissement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_etablissement_params
      params.require(:admin_etablissement).permit(:name, :code)
    end
end
