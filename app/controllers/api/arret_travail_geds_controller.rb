module Api
  class ArretTravailGedsController < Api::ApplicationController
    before_action :set_arret_travail_ged, only: [:show, :update, :destroy]

    # GET /api/arret_travail_geds
    def index
      @arret_travail_geds = ArretTravailGed.all
      render json: @arret_travail_geds
    end

    # GET /api/arret_travail_geds/1
    def show
      render json: @arret_travail_ged
    end

    # POST /api/arret_travail_geds
    def create
      @arret_travail_ged = ArretTravailGed.new(arret_travail_ged_params)
      @arret_travail_ged.etat = 'instruction'
      @arret_travail_ged.status_ged = 'en_creation'

      if @arret_travail_ged.save
        render json: @arret_travail_ged, status: :created, location: api_arret_travail_ged_url(@arret_travail_ged)
      else
        render json: { errors: @arret_travail_ged.errors }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/arret_travail_geds/1
    def update
      if @arret_travail_ged.update(arret_travail_ged_params)
        render json: @arret_travail_ged
      else
        render json: { errors: @arret_travail_ged.errors }, status: :unprocessable_entity
      end
    end

    # DELETE /api/arret_travail_geds/1
    def destroy
      @arret_travail_ged.destroy
      head :no_content
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_arret_travail_ged
        @arret_travail_ged = ArretTravailGed.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def arret_travail_ged_params
        params.require(:arret_travail_ged).permit(
          :raison_sociale_employeur, :numero_employeur, :adresse_employeur, :email_employeur, 
          :telephone_employeur, :activite_principale_entreprise, :numero_affiliation, :type_de_piece, 
          :nin_salarie, :prenom_salarie, :nom_salarie, :sexe, :date_de_naissance_salarie, 
          :nationalite_salarie, :adresse_domiciliaire_salarie, :telephone_salarie, 
          :qualification_professionnelle_salarie, :date_embauche_salarie, :type_de_contrat_travail_salarie, 
          :nature_du_travail_au_moment_accident, :infirmite_anterieure_accident, :situation_matrimoniale_salarie,
          :taux_infirmite_anterieure_accident, :numero_rente_infirmite_anterieure_accident, 
          :date_accident, :nombre_hr_entre_accident_et_prise_travail, :lieu_accident, 
          :accident_mortel, :debut_arret_travail, :agent_materiel, :cause_circonstances_acccident, 
          :avec_constat, :detail_constat, :raison_absence_constat, :avec_temoin, :nom_temoin, 
          :adresse_temoin, :personne_avisee, :nom_personne_avisee, :adresse_personne_avisee, 
          :personne_avisee_quand, :personne_avisee_par_qui, :accident_cause_par_tiers, 
          :prenom_tiers, :nom_tiers, :adresse_tiers, :prenom_civilement_responsable, 
          :nom_civilement_responsable, :adresse_civilement_responsable, :raison_sociale_assureur, 
          :nom_assureur, :adresse_assureur, :numero_police_assurance, :salaire_verse_en_totalite_en_at, 
          :declarant, :prenom_declarant, :nom_declarant, :adresse_declarant, :telephone_declarant, 
          :lieu_declaration, :qualite_declarant, :date_declaration, :est_journalier, :is_subrogation, 
          :admin_agence_id, :date_reception, :etat, :status_ged, :id_item, :lien_ged, :est_mp,
          :nature_accident, :incapacite_permanente, :consequence_accident_travail, :type_declaration
        )
      end
  end
end