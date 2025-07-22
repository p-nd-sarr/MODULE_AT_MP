class Admin::AvocatsHuissiersController < ApplicationController
  before_action :set_avocats_huissier, only: [:show, :edit, :update, :destroy]

  # GET /avocats_huissiers
  # GET /avocats_huissiers.json
  def index
    @avocats_huissiers = AvocatsHuissier.all
  end

  # GET /avocats_huissiers/1
  # GET /avocats_huissiers/1.json
  def show
  end

  # GET /avocats_huissiers/new
  def new
    @avocats_huissier = AvocatsHuissier.new
  end

  # GET /avocats_huissiers/1/edit
  def edit
  end

  # POST /avocats_huissiers
  # POST /avocats_huissiers.json
  def create
    @avocats_huissier = AvocatsHuissier.new(avocats_huissier_params)

    if @avocats_huissier.save
      redirect_to admin_dossier_juridique_path(@avocats_huissier.dossier_juridique_id), notice: 'Intervenant ajouté avec succès.'
    else
      flash[:error] = 'Erreur : ', @avocats_huissier.errors.full_messages
      redirect_to admin_dossier_juridique_path(@avocats_huissier.dossier_juridique_id)
    end
  end

  # PATCH/PUT /avocats_huissiers/1
  # PATCH/PUT /avocats_huissiers/1.json
  def update
    if @avocats_huissier.update(avocats_huissier_params)
      redirect_to admin_dossier_juridique_path(@avocats_huissier.dossier_juridique_id), notice: 'Intervenant modifié avec succès.'
    else
      flash[:error] = 'Erreur : ', @avocats_huissier.errors.full_messages
      redirect_to admin_dossier_juridique_path(@avocats_huissier.dossier_juridique_id)
    end
  end

  # DELETE /avocats_huissiers/1
  # DELETE /avocats_huissiers/1.json
  def destroy
    @avocats_huissier.destroy
    respond_to do |format|
      format.html { redirect_to admin_dossier_juridique_path(@avocats_huissier.dossier_juridique_id), notice: 'Intervenant supprimé avec succès.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_avocats_huissier
    @avocats_huissier = AvocatsHuissier.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def avocats_huissier_params
    params.require(:avocats_huissier).permit(:nom, :prenom, :adresse, :tel, :email, :nin, :type_intervenant, :dossier_juridique_id)

  end
end
