class Admin::IcmModifierInfoPersonnellesController < Admin::ApplicationController
    before_action :set_dossier_maternite,

    def index
        @q = IcmModifierInfoPersonnelle.all
        @icm_modifier_info_personnelles = @q.order('prenom asc')
    end

    def show
        #show
    end
    
    # GET /indemnite_conges_maternites/new
    def new
       @icm_modifier_info_personnelle = IcmModifierInfoPersonnelle.new
    end

    def create
        @icm_modifier_info_personnelle = IcmModifierInfoPersonnelle.new(icm_modifier_info_personnelle_params)
        @icm_modifier_info_personnelle.dossier_maternite_id = @dossier_maternite
        @icm_modifier_info_personnelle.ajoute_par = current_user
        @icm_modifier_info_personnelle.etat = :creation

        respond_to do |format|
            if @icm_modifier_info_personnelle.save
            format.html { redirect_to [:admin, @dossier_maternite, @icm_modifier_info_personnelle], notice: 'ICM was successfully created.' }
            format.json { render :show, status: :created, location: @icm_modifier_info_personnelle }
            else
            format.html { render :new }
            format.json { render json: @icm_modifier_info_personnelle.errors, status: :unprocessable_entity }
            end
        end
    end


    private
        def set_dossier_maternite
            @dossier_maternite = DossierMaternite.find(params[:dossier_maternite_id])
        end

          # Never trust parameters from the scary internet, only allow the white list through.
  def icm_modifier_info_personnelle_params
    params.require(:icm_modifier_info_personnelle).permit(:prenom, :nom, :telephone, :lieu_naissance,
                                                       :date_naissance, :sexe, :nin, :debut_grossesse,:etat,
                                                       :email, :adresse_domicile, :mode_paiement, :type_piece,
                                                        )
                                                      
  end
end