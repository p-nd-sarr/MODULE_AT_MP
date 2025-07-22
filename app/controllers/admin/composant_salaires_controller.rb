class Admin::ComposantSalairesController < Admin::ApplicationController
    before_action :only_admin!
    before_action :set_composant_salaire, only: [:show, :edit, :update, :destroy]
  
    # GET /admin/composant_salaires
    # GET /admin/composant_salaires.json
    def index
      @admin_composant_salaires = Admin::ComposantSalaire.all
    end
  
    # GET /admin/composant_salaires/1
    # GET /admin/composant_salaires/1.json
    def show
      #show
    end
  
    # GET /admin/composant_salaires/new
    def new
      @admin_composant_salaire = Admin::ComposantSalaire.new
    end
  
    # GET /admin/composant_salaires/1/edit
    def edit
      #edit
    end
  
    # POST /admin/composant_salaires
    # POST /admin/composant_salaires.json
    def create
      @admin_composant_salaire = Admin::ComposantSalaire.new(composant_salaire_params)
  
      if @admin_composant_salaire.save
        redirect_to [@admin_composant_salaire], notice: 'Le composant est créé.'
      else
        render :new
      end
  
    end
  
    # PATCH/PUT /admin/composant_salaires/1
    # PATCH/PUT /admin/composant_salaires/1.json
    def update
      if @admin_composant_salaire.update(composant_salaire_params)
        redirect_to [@admin_composant_salaire], notice: 'Le composant est bien mise à jour.'
      else
        render :edit
      end
    end
  
    # DELETE /admin/composant_salaires/1
    # DELETE /admin/composant_salaires/1.json
    def destroy
      @admin_composant_salaire.destroy
      respond_to do |format|
        format.html { redirect_to [@admin_composant_salaire], notice: 'Composant bien supprimé.' }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_composant_salaire
        @admin_composant_salaire = Admin::ComposantSalaire.find(params[:id] || params[:admin_composant_salaire_id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def composant_salaire_params
        params.require(:admin_composant_salaire).permit(:code, :designation, :prise_en_compte)
      end
  end
  