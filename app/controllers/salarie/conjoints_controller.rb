class Salarie::ConjointsController < Salarie::ApplicationController
  before_action :set_conjoint, only: [:show, :edit, :update, :destroy]
  before_action :can_be_edited?, only: [:edit, :destroy, :update]

  # GET /salarie/conjoints
  # GET /salarie/conjoints.json
  def index
    @q = current_user.conjoints.ransack(params[:q])
    @conjoints = @q.result.order('nom, prenom').page(params[:page]).per(100)
    
  end

  # GET /salarie/conjoints/1
  # GET /salarie/conjoints/1.json
  def show
    #show
  end

  # GET /salarie/conjoints/new
  def new
    @conjoint = Conjoint.new
    @salarie = current_user
  end

  # GET /salarie/conjoints/1/edit
  def edit
    @salarie = current_user
    #edit
  end

  # POST /salarie/conjoints
  # POST /salarie/conjoints.json
  def create
    @conjoint = Conjoint.new(conjoint_params)
    @conjoint.user = current_user
    @conjoint.numero_affiliation = current_user.numero_salarie
    @conjoint.ajoute_par = current_user

    if @conjoint.save
      redirect_to [:salarie, @conjoint], notice: 'Conjoint was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /salarie/conjoints/1
  # PATCH/PUT /salarie/conjoints/1.json
  def update
    if @conjoint.update(conjoint_params)
      redirect_to [:salarie, @conjoint], notice: 'Conjoint was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /salarie/conjoints/1
  # DELETE /salarie/conjoints/1.json
  def destroy
    @conjoint.destroy
    redirect_to salarie_conjoints_url, notice: 'Conjoint was successfully destroyed.'
  end

  private

  def can_be_edited?
    unless @conjoint.can_be_edited?
      flash[:error] = 'Vous ne pouvez pas modifier un supprimer un conjoint déjà validé'
      redirect_back(fallback_location: salarie_conjoints_path)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_conjoint
    @conjoint = current_user.conjoints.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def conjoint_params
    params.require(:conjoint).permit(:user_id, :prenom, :nom, :date_naissance, :date_mariage, :date_etablissement_mariage, :date_jugement_suppletif, :nombre_femmes, :nin, :code_etat_civil,
                  :extrait_naissance, :certificat_mariage, :certificat_deces, :certificat_divorce, :numero_affiliation, :est_enceinte, :numero_registre,
                  :est_salarie, :numero_salarie, :type_piece, :numero_piece, :piece_identite, :sex,
                  :date_delivrance_piece, :date_expiration_piece, :matric_conjoint, :nin_generer,
                  :prenom_salarie, :nom_salarie, :regime_matrimoniale, :etat_conjoint, :etat_civil, :date_delivrance_piece_salarie,
                  :rang_conjoint, :date_naissance_salarie, :date_divorce, :date_deces, :date_transcription, :nombre_femmes, :numero_jugement_mariage)
  end
end
