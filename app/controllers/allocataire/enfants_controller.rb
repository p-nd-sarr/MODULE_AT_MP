class Allocataire::EnfantsController < Allocataire::ApplicationController
  before_action :set_enfant, only: [:edit, :update, :destroy, :show]
  before_action :can_be_edited?, only: [:edit, :destroy, :update]
  before_action :set_allocataire, only: [:new, :create]

  # GET /salarie/enfants
  # GET /salarie/enfants.json
  def index
    @enfants = current_user.enfants
  end

  def show
    #show
  end

  # GET /salarie/enfants/new
  def new
    @enfant = Enfant.new
    @enfant.numero_affiliation = current_user.numero_salarie
    @enfant.prenom_salarie = @allocataire.prenom
    @enfant.nom_salarie = @allocataire.nom

  end

  # GET /salarie/enfants/1/edit
  def edit
    #edit
  end

  # POST /salarie/enfants
  # POST /salarie/enfants.json
  def create
    @enfant = Enfant.new(enfant_params)
    @enfant.user = current_user
    @enfant.numero_affiliation = current_user.numero_salarie
    @enfant.ajoute_par = current_user

    if @enfant.save!
      redirect_to [:allocataire, @enfant], notice: 'Enfant was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /salarie/enfants/1
  # PATCH/PUT /salarie/enfants/1.json
  def update
    if @enfant.update(enfant_params)
      redirect_to [:allocataire, @enfant], notice: 'Enfant was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /salarie/enfants/1
  # DELETE /salarie/enfants/1.json
  def destroy
    @enfant.destroy
    redirect_to allocataire_enfants_path, notice: 'Enfant was successfully destroyed.'
  end

  # GET /salarie/enfants/Active Deces
  # GET /salarie/conjoints/Active décés
  def active_deces
    @enfant = current_user.enfants.find(params[:id])
    redirect_to new_allocataire_update_grappe_familiale_url(:id=>@enfant.id, :type=>"enfant", :etat=>"deces")
  end

  private

  def can_be_edited?
    unless @enfant.can_be_edited?
      flash[:error] = 'Vous ne pouvez pas modifier un supprimer un enfant déjà validé'
      redirect_back(fallback_location: allocataire_enfants_path)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_enfant
    @enfant = current_user.enfants.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def enfant_params
    params.require(:enfant).permit(:prenom, :nom, :date_naissance, :nom_salarie, :prenom_salarie, :sexe, :code_etat_civil, :numero_registre,
                                   :full_name_conjoint, :extrait_naissance, :numero_affiliation, :nom_mere, :prenom_mere, :nom_pere,
                                   :prenom_pere, :origine_enfant, :type_piece, :numero_piece, :conjoint_id, :nom_mere_naturel, :prenom_mere_naturel, :date_delivrance_piece)
  end
  def set_allocataire
    @allocataire = Allocataire.find_by_numero_allocataire(current_user.numero_salarie)
  end

  
end
