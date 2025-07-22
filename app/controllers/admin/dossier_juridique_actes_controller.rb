class Admin::DossierJuridiqueActesController < ApplicationController
  before_action :set_dossier_juridique_acte, only: [:show, :edit, :update, :destroy]

  # GET dossier_juridique_actes
  # GET dossier_juridique_actes.json
  def index
    @dossier_juridique_actes = DossierJuridiqueActe.all
  end

  # GET dossier_juridique_actes/1
  # GET dossier_juridique_actes/1.json
  def show
  end

  # GET dossier_juridique_actes/new
  def new
    @dossier_juridique_acte = DossierJuridiqueActe.new
  end

  # GET dossier_juridique_actes/1/edit
  def edit
  end

  # POST dossier_juridique_actes
  # POST dossier_juridique_actes.json
  def create
    @dossier_juridique_acte = DossierJuridiqueActe.new(dossier_juridique_acte_params)
    @dossier_juridique_acte.ajoute_par = current_user

    if @dossier_juridique_acte.save
      redirect_to admin_dossier_juridique_path(@dossier_juridique_acte.dossier_juridique_id), notice: 'Acte ajouté avec succès.'
    else
      flash[:error] = 'Erreur : ', @dossier_juridique_acte.errors.full_messages
      redirect_to admin_dossier_juridique_path(@dossier_juridique_acte.dossier_juridique_id)
    end
  end

  # PATCH/PUT dossier_juridique_actes/1
  # PATCH/PUT dossier_juridique_actes/1.json
  def update
    unless params.has_key?(:pv_audience)
      @dossier_juridique_acte.pv_audience.purge
    end
    unless params.has_key?(:pv_assignation)
      @dossier_juridique_acte.pv_assignation.purge
    end
    unless params.has_key?(:pv_decision)
      @dossier_juridique_acte.pv_decision.purge
    end
    if @dossier_juridique_acte.update(dossier_juridique_acte_params)
      redirect_to admin_dossier_juridique_path(@dossier_juridique_acte.dossier_juridique_id), notice: 'Acte modifié avec succès.'
    else
      flash[:error] = 'Erreur : ', @dossier_juridique_acte.errors.full_messages
      redirect_to admin_dossier_juridique_path(@dossier_juridique_acte.dossier_juridique_id)
    end
  end

  # DELETE dossier_juridique_actes/1
  # DELETE dossier_juridique_actes/1.json
  def destroy
    @dossier_juridique_acte.destroy
    respond_to do |format|
      format.html { redirect_to admin_dossier_juridique_path(@dossier_juridique_acte.dossier_juridique_id), notice: 'Acte supprimé avec succès.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dossier_juridique_acte
    @dossier_juridique_acte = DossierJuridiqueActe.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dossier_juridique_acte_params
    params.require(:dossier_juridique_acte).permit(:type_act, :comment, :date_act, :dossier_juridique_id, :pv_audience, :pv_assignation, :pv_decision)

  end
end
