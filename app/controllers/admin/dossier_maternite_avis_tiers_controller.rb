class Admin::DossierMaterniteAvisTiersController < ApplicationController
    before_action :set_dossier_maternite_avis_tier, only: %i[ show edit update destroy soumettre valider retourner valider_paiement ]
    before_action :set_dossier_maternite, only: %i[ index new  edit update destroy create show soumettre valider retourner valider_paiement ]
  
    # GET /dossier_maternite_avis_tiers or /dossier_maternite_avis_tiers.json
    def index
      @dossier_maternite_avis_tiers = @dossier_maternite.dossier_maternite_avis_tiers
    end
  
    # GET /dossier_maternite_avis_tiers/1 or /dossier_maternite_avis_tiers/1.json
    def show
    end
  
    # GET /dossier_maternite_avis_tiers/new
    def new
      unless current_user.gestionnaire_compte_allocataire?
        respond_to do |format|
          format.html { redirect_to admin_dossier_maternite_path(@dossier_maternite), 
            notice: "Seul un gestionnaire de compte allocataire peut créer un avis à tiers" } 
        end
        return
      end
      @dossier_maternite_avis_tier = DossierMaterniteAvisTier.new
    end
  
    # GET /dossier_maternite_avis_tiers/1/edit
    def edit
    end
  
    # POST /dossier_maternite_avis_tiers or /dossier_maternite_avis_tiers.json
    def create
      @dossier_maternite_avis_tier = DossierMaterniteAvisTier.new(dossier_maternite_avis_tier_params)
      @dossier_maternite_avis_tier.ajoute_par = current_user
      @dossier_maternite_avis_tier.etat = :creation
      @dossier_maternite_avis_tier.status = :non_paye
      @dossier_maternite_avis_tier.dossier_maternite = @dossier_maternite
  
      respond_to do |format|
        if @dossier_maternite_avis_tier.save
          format.html { redirect_to admin_dossier_maternite_dossier_maternite_avis_tier_path(@dossier_maternite, @dossier_maternite_avis_tier), notice: "Avis à tiers créé avec succès!." }
          format.json { render :show, status: :created, location: @dossier_maternite_avis_tier }
        else
          flash[:error] = @dossier_maternite_avis_tier.errors.full_messages.join(", ")
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @dossier_maternite_avis_tier.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /dossier_maternite_avis_tiers/1 or /dossier_maternite_avis_tiers/1.json
    def update
      respond_to do |format|
        if @dossier_maternite_avis_tier.update(dossier_maternite_avis_tier_params)
          format.html { redirect_to admin_dossier_maternite_dossier_maternite_avis_tier_path(@dossier_maternite, @dossier_maternite_avis_tier), notice: "Avis à tiers modifié avec succès." }
          format.json { render :show, status: :ok, location: @dossier_maternite_avis_tier }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @dossier_maternite_avis_tier.errors, status: :unprocessable_entity }
        end
      end
    end
  
    def soumettre
      if @dossier_maternite_avis_tier.creation?
        @dossier_maternite_avis_tier.etat = :soumis
        @dossier_maternite_avis_tier.soumis_par = current_user
        @dossier_maternite_avis_tier.date_soumission = DateTime.now
        @dossier_maternite_avis_tier.retourne_par = nil
        @dossier_maternite_avis_tier.date_retour = nil
        @dossier_maternite_avis_tier.motif_retour = nil
        if @dossier_maternite_avis_tier.save
          redirect_to [:admin, @dossier_maternite, @dossier_maternite_avis_tier], notice: 'Avis à tiers soumis avec succès'
        else
          flash[:error] = 'Une erreur est survenue lors du traitement'
          redirect_to [:admin, @dossier_maternite, @dossier_maternite_avis_tier]
        end
      end
    end
  
    def valider
      if @dossier_maternite_avis_tier.soumis?
        @dossier_maternite_avis_tier.etat = :valide
        @dossier_maternite_avis_tier.valide_par = current_user
        @dossier_maternite_avis_tier.date_validation = DateTime.now
        @dossier_maternite_avis_tier.retourne_par = nil
        @dossier_maternite_avis_tier.date_retour = nil
        @dossier_maternite_avis_tier.motif_retour = nil
        if @dossier_maternite_avis_tier.save
          redirect_to [:admin, @dossier_maternite, @dossier_maternite_avis_tier], notice: 'Avis à tiers validé avec succès'
        else
          flash[:error] = 'Une erreur est survenue lors du traitement'
          redirect_to [:admin, @dossier_maternite, @dossier_maternite_avis_tier]
        end
      end
    end

    # if @dossier_maternite_avis_tier.soumis? and current_user.chef_agence?
    #   @dossier_maternite_avis_tier.etat = :creation
    # elsif @dossier_maternite_avis_tier.attente_paiement? and current_user.comptable?
    #   @dossier_maternite_avis_tier.etat = :soumis
    # end
  
    # def retourner
    #   if @dossier_maternite_avis_tier.soumis?
    #     @dossier_maternite_avis_tier.etat = :creation
    #     @dossier_maternite_avis_tier.retourne_par = current_user
    #     @dossier_maternite_avis_tier.date_retour = DateTime.now
    #     if @dossier_maternite_avis_tier.update(dossier_maternite_avis_tier_params)
    #       redirect_to [:admin, @dossier_maternite, @dossier_maternite_avis_tier], notice: 'Avis à tiers validé avec succès'
    #     else
    #       flash[:error] = 'Une erreur est survenue lors du traitement'
    #       redirect_to [:admin, @dossier_maternite, @dossier_maternite_avis_tier]
    #     end
    #   end
    # end
    def retourner
      if @dossier_maternite_avis_tier.soumis? && current_user.chef_agence?
        retourner_avis(:creation)
      elsif @dossier_maternite_avis_tier.attente_paiement? && current_user.comptable?
        retourner_avis(:soumis)
      # else
      #     flash[:error] = 'Une erreur est survenue lors du traitement'
      #     redirect_to [:admin, @dossier_maternite, @dossier_maternite_avis_tier]
      end
    end
  
    # DELETE /dossier_maternite_avis_tiers/1 or /dossier_maternite_avis_tiers/1.json
    def destroy
      @dossier_maternite_avis_tier.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_dossier_maternite_dossier_maternite_avis_tiers_path(@dossier_maternite), notice: "Avis à tiers supprimé avec succès." }
        format.json { head :no_content }
      end
    end
  
    def valider_paiement
      ValiderPaiementDossierMaterniteAvisTiersJob.perform_now(@dossier_maternite_avis_tier, current_user)
  
      flash[:notice] = "Génération de l'ordre de paiement en cours ..."
  
      redirect_to [:admin, @dossier_maternite, @dossier_maternite_avis_tier]
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_dossier_maternite_avis_tier
      @dossier_maternite_avis_tier = DossierMaterniteAvisTier.find(params[:id] || params[:dossier_maternite_avis_tier_id])
    end
  
    # Use callbacks to share common setup or constraints between actions.
    def set_dossier_maternite
      @dossier_maternite = DossierMaternite.find(params[:dossier_maternite_id])
    end
  
    # Only allow a list of trusted parameters through.
    def dossier_maternite_avis_tier_params
      params.require(:dossier_maternite_avis_tier).permit(:montant_tranche, :montant_avis, :type_avis, :tranche_paiement, :motif_retour, :status, :motif_avis, :type_motif, :sal_ref_a_considere, :nbre_jours_a_indemnise, :commentaire)
    end

    def retourner_avis(etat)
      @dossier_maternite_avis_tier.etat = etat
      @dossier_maternite_avis_tier.retourne_par = current_user
      @dossier_maternite_avis_tier.date_retour = DateTime.now
      if @dossier_maternite_avis_tier.update(dossier_maternite_avis_tier_params)
        redirect_to [:admin, @dossier_maternite, @dossier_maternite_avis_tier], notice: 'Avis à tiers retourné avec succès'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @dossier_maternite, @dossier_maternite_avis_tier]
      end
    end
  end
  