module Api
  class DossierPrestationGedsController < Api::ApplicationController
    before_action :set_dossier_prestation_ged, only: [:show, :update, :destroy]

    # GET /api/dossier_prestation_geds
    def index
      @dossier_prestation_geds = DossierPrestationGed.all
      render json: @dossier_prestation_geds
    end

    # GET /api/dossier_prestation_geds/1
    def show
      render json: @dossier_prestation_ged
    end

    # POST /api/dossier_prestation_geds
    def create
      @dossier_prestation_ged = DossierPrestationGed.new(dossier_prestation_ged_params)
      @dossier_prestation_ged.status_ged = :en_creation

      if @dossier_prestation_ged.save
        render json: @dossier_prestation_ged, status: :created, location: api_dossier_prestation_ged_url(@dossier_prestation_ged)
      else
        render json: @dossier_prestation_ged.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/dossier_prestation_geds/1
    def update
      if @dossier_prestation_ged.update(dossier_prestation_ged_params)
        render json: @dossier_prestation_ged
      else
        render json: @dossier_prestation_ged.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/dossier_prestation_geds/1
    def destroy
      @dossier_prestation_ged.destroy
      head :no_content
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_dossier_prestation_ged
        @dossier_prestation_ged = DossierPrestationGed.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def dossier_prestation_ged_params
        params.require(:dossier_prestation_ged).permit(
          :num_affiliation, :sexe_salarie, :prenom, :nom, :lieu_naissance, 
          :adresse_domicile, :date_naissance, :nin, :nationalite,
          :employeur_actuel, :date_embauche, :admin_agence_id, :num_dossier, :date_reception, 
          :id_item, :lien_ged, :status_ged, :telephone 
        )
      end
  end
end