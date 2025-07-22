class Admin::DossierPrestationAvisTiersController < ApplicationController
  before_action :set_dossier_prestation_avis_tier, only: %i[ show edit update destroy soumettre valider retourner valider_paiement ]
  before_action :set_dossier_prestation, only: %i[ index new  edit update destroy create show soumettre valider retourner valider_paiement ]

  # GET /dossier_prestation_avis_tiers or /dossier_prestation_avis_tiers.json
  def index
    @dossier_prestation_avis_tiers = @dossier_prestation.dossier_prestation_avis_tiers
  end

  # GET /dossier_prestation_avis_tiers/1 or /dossier_prestation_avis_tiers/1.json
  def show
  end

  # GET /dossier_prestation_avis_tiers/new
  def new
    @dossier_prestation_avis_tier = DossierPrestationAvisTier.new
  end

  # GET /dossier_prestation_avis_tiers/1/edit
  def edit
  end

  # POST /dossier_prestation_avis_tiers or /dossier_prestation_avis_tiers.json
  def create
    @dossier_prestation_avis_tier = DossierPrestationAvisTier.new(dossier_prestation_avis_tier_params)
    @dossier_prestation_avis_tier.ajoute_par = current_user
    @dossier_prestation_avis_tier.etat = :creation
    @dossier_prestation_avis_tier.dossier_prestation = @dossier_prestation

    respond_to do |format|
      if @dossier_prestation_avis_tier.save
        format.html { redirect_to admin_dossier_prestation_dossier_prestation_avis_tier_path(@dossier_prestation, @dossier_prestation_avis_tier), notice: "Avis à tier créé avec succès!." }
        format.json { render :show, status: :created, location: @dossier_prestation_avis_tier }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dossier_prestation_avis_tier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dossier_prestation_avis_tiers/1 or /dossier_prestation_avis_tiers/1.json
  def update
    respond_to do |format|
      if @dossier_prestation_avis_tier.update(dossier_prestation_avis_tier_params)
        format.html { redirect_to admin_dossier_prestation_dossier_prestation_avis_tier_path(@dossier_prestation, @dossier_prestation_avis_tier), notice: "Avis à tier modifié avec succès." }
        format.json { render :show, status: :ok, location: @dossier_prestation_avis_tier }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dossier_prestation_avis_tier.errors, status: :unprocessable_entity }
      end
    end
  end

  def soumettre
    if @dossier_prestation_avis_tier.creation?
      @dossier_prestation_avis_tier.etat = :soumis
      @dossier_prestation_avis_tier.soumis_par = current_user
      @dossier_prestation_avis_tier.date_soumission = DateTime.now
      @dossier_prestation_avis_tier.retourne_par = nil
      @dossier_prestation_avis_tier.date_retour = nil
      @dossier_prestation_avis_tier.motif_retour = nil
      if @dossier_prestation_avis_tier.save
        redirect_to [:admin, @dossier_prestation, @dossier_prestation_avis_tier], notice: 'Avis à tiers soumis avec succès'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @dossier_prestation, @dossier_prestation_avis_tier]
      end
    end
  end

  def valider
    if @dossier_prestation_avis_tier.soumis?
      @dossier_prestation_avis_tier.etat = :valide
      @dossier_prestation_avis_tier.valide_par = current_user
      @dossier_prestation_avis_tier.date_validation = DateTime.now
      if @dossier_prestation_avis_tier.save
        redirect_to [:admin, @dossier_prestation, @dossier_prestation_avis_tier], notice: 'Avis à tiers validé avec succès'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @dossier_prestation, @dossier_prestation_avis_tier]
      end
    end
  end

  def retourner
    if @dossier_prestation_avis_tier.soumis?
      @dossier_prestation_avis_tier.etat = :creation
      @dossier_prestation_avis_tier.retourne_par = current_user
      @dossier_prestation_avis_tier.date_retour = DateTime.now
      if @dossier_prestation_avis_tier.update(dossier_prestation_avis_tier_params)
        redirect_to [:admin, @dossier_prestation, @dossier_prestation_avis_tier], notice: 'Avis à tiers validé avec succès'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @dossier_prestation, @dossier_prestation_avis_tier]
      end
    end
  end

  # DELETE /dossier_prestation_avis_tiers/1 or /dossier_prestation_avis_tiers/1.json
  def destroy
    @dossier_prestation_avis_tier.destroy

    respond_to do |format|
      format.html { redirect_to admin_dossier_prestation_dossier_prestation_avis_tiers_path(@dossier_prestation), notice: "Avis à tier supprimé avec succès." }
      format.json { head :no_content }
    end
  end

  def valider_paiement
    ValiderPaiementDossierPrestationAvisTierJob.perform_now(@dossier_prestation_avis_tier, current_user)

    flash[:notice] = "Génération de l'ordre de paiement en cours ..."

    redirect_to [:admin, @dossier_prestation, @dossier_prestation_avis_tier]
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dossier_prestation_avis_tier
    @dossier_prestation_avis_tier = DossierPrestationAvisTier.find(params[:id] || params[:dossier_prestation_avis_tier_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_dossier_prestation
    @dossier_prestation = DossierPrestation.find(params[:dossier_prestation_id])
  end

  # Only allow a list of trusted parameters through.
  def dossier_prestation_avis_tier_params
    params.require(:dossier_prestation_avis_tier).permit(:montant_echeance, :montant_avis, :type_avis, :nature_avis, :trimestre, :annee, :volet_pre, :volet_post, :numero_liquidation, :date_liquidation, :enfant_id, :conjoint_id, :motif, :motif_retour)
  end
end
