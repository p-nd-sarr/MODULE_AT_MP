class Salarie::EnfantsController < Salarie::ApplicationController
  before_action :set_enfant, only: [:edit, :update, :destroy, :show]
  before_action :can_be_edited?, only: [:edit, :destroy, :update]

  # GET /salarie/enfants
  # GET /salarie/enfants.json
  def index
    @q = current_user.enfants.ransack(params[:q])
    @enfants = @q.result.order('nom, prenom').page(params[:page]).per(100)
  end

  def show
    #show
  end

  # GET /salarie/enfants/new
  def new
    @enfant = Enfant.new
    @salarie = current_user
  end

  # GET /salarie/enfants/1/edit
  def edit
    @salarie = current_user
    #edit
  end

  # POST /salarie/enfants
  # POST /salarie/enfants.json
  def create
    @enfant = Enfant.new(enfant_params)
    @enfant.user = current_user
    @enfant.numero_affiliation = current_user.numero_salarie
    @enfant.ajoute_par = current_user
    @salarie = current_user
 

    if @enfant.save
      redirect_to [:salarie, @enfant], notice: 'Enfant was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /salarie/enfants/1
  # PATCH/PUT /salarie/enfants/1.json
  def update
    if @enfant.update(enfant_params)
      redirect_to [:salarie, @enfant], notice: 'Enfant was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /salarie/enfants/1
  # DELETE /salarie/enfants/1.json
  def destroy
    @enfant.destroy
    redirect_to salarie_enfants_path, notice: 'Enfant was successfully destroyed.'
  end

  private

  def can_be_edited?
    unless @enfant.can_be_edited?
      flash[:error] = 'Vous ne pouvez pas modifier un supprimer un enfant déjà validé'
      redirect_back(fallback_location: salarie_enfants_path)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_enfant
    @enfant = current_user.enfants.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def enfant_params
    params.require(:enfant).permit(:prenom, :nom, :date_naissance, :nom_salarie, :prenom_salarie, :sexe, :code_etat_civil, :numero_registre,
                                :full_name_conjoint, :extrait_naissance, :numero_affiliation, :nom_mere, :prenom_mere, :nom_pere, :date_delivrance_piece,
                                :prenom_pere, :origine_enfant, :type_piece, :numero_piece, :conjoint_id, :nom_mere_naturel, :prenom_mere_naturel, :nin_generer, :lieu_naissance, :date_transcription)
  end
end
