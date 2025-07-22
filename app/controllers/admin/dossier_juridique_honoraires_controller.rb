class Admin::DossierJuridiqueHonorairesController < ApplicationController
  before_action :set_dossier_juridique_honoraire, only: [:show, :edit, :update, :destroy]

  # GET dossier_juridique_honoraires
  # GET dossier_juridique_honoraires.json
  def index
    @dossier_juridique_honoraires = DossierJuridiqueHonoraire.all
  end

  # GET dossier_juridique_honoraires/1
  # GET dossier_juridique_honoraires/1.json
  def show
  end

  # GET dossier_juridique_honoraires/new
  def new
    @dossier_juridique_honoraire = DossierJuridiqueHonoraire.new
  end

  # GET dossier_juridique_honoraires/1/edit
  def edit
  end

  # POST dossier_juridique_honoraires
  # POST dossier_juridique_honoraires.json
  def create
    @dossier_juridique_honoraire = DossierJuridiqueHonoraire.new(dossier_juridique_honoraire_params)
    @dossier_juridique_honoraire.ajoute_par = current_user

    if @dossier_juridique_honoraire.save
      redirect_to admin_dossier_juridique_path(@dossier_juridique_honoraire.dossier_juridique_id), notice: 'honoraire ajouté avec succès.'
    else
      flash[:error] = 'Erreur : ', @dossier_juridique_honoraire.errors.full_messages
      redirect_to admin_dossier_juridique_path(@dossier_juridique_honoraire.dossier_juridique_id)
    end
  end

  # PATCH/PUT dossier_juridique_honoraires/1
  # PATCH/PUT dossier_juridique_honoraires/1.json
  def update
    if params.has_key?(:avocats_huissier_id)
      @dossier_juridique_honoraire.nom_complet_juge = ''
    else
      @dossier_juridique_honoraire.avocats_huissier_id = nil
    end

    if @dossier_juridique_honoraire.update(dossier_juridique_honoraire_params)
      redirect_to admin_dossier_juridique_path(@dossier_juridique_honoraire.dossier_juridique_id), notice: 'honoraire modifié avec succès.'
    else
      flash[:error] = 'Erreur : ', @dossier_juridique_honoraire.errors.full_messages
      redirect_to admin_dossier_juridique_path(@dossier_juridique_honoraire.dossier_juridique_id)
    end
  end

  # DELETE dossier_juridique_honoraires/1
  # DELETE dossier_juridique_honoraires/1.json
  def destroy
    @dossier_juridique_honoraire.destroy
    respond_to do |format|
      format.html { redirect_to admin_dossier_juridique_path(@dossier_juridique_honoraire.dossier_juridique_id), notice: 'honoraire supprimé avec succès.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dossier_juridique_honoraire
    @dossier_juridique_honoraire = DossierJuridiqueHonoraire.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dossier_juridique_honoraire_params
    params.require(:dossier_juridique_honoraire).permit(:date_eff, :nom_complet_juge, :montant, :avocats_huissier_id, :dossier_juridique_id, :document_justificatif)
  end
end
