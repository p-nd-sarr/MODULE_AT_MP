class Admin::BaseReversionsController < Admin::ApplicationController
  before_action :set_allocataire
  before_action :set_base_reversion, only: [:show, :edit, :update, :destroy, :index]
  before_action :can_create?, only: [:new, :create]
  before_action :can_edit?, only: [:edit, :update]

  # GET /base_reversions
  # GET /base_reversions.json
  def index
    render :show
  end

  # GET /base_reversions/1
  # GET /base_reversions/1.json
  def show
    #show
  end

  # GET /base_reversions/new
  def new
    @base_reversion = BaseReversion.new
  end

  # GET /base_reversions/1/edit
  def edit; end

  # POST /base_reversions
  # POST /base_reversions.json
  def create
    @base_reversion = BaseReversion.new(base_reversion_params)
    @base_reversion.numero_allocataire = @allocataire.numero_allocataire
    @base_reversion.traite_par = current_user
    @base_reversion.traite_le = DateTime.now

    respond_to do |format|
      if @base_reversion.save
        format.html { redirect_to admin_allocataire_base_reversions_path(@allocataire), notice: 'Base reversion was successfully created.' }
        format.json { render :show, status: :created, location: @base_reversion }
      else
        format.html { render :new }
        format.json { render json: @base_reversion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /base_reversions/1
  # PATCH/PUT /base_reversions/1.json
  def update
    respond_to do |format|
      if @base_reversion.update(base_reversion_params)
        format.html { redirect_to admin_allocataire_base_reversions_path(@allocataire), notice: 'Base reversion was successfully updated.' }
        format.json { render :show, status: :ok, location: @base_reversion }
      else
        format.html { render :edit }
        format.json { render json: @base_reversion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /base_reversions/1
  # DELETE /base_reversions/1.json
  def destroy
    #@base_reversion.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @allocataire], notice: 'Base reversion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_base_reversion
    @base_reversion = @allocataire.base_reversion
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def base_reversion_params
    params.require(:base_reversion).permit(:numero_allocataire, :date_deces, :commentaire,
                                           :nombre_epouses_eligible, :nombre_enfant_eligible)
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id])
  end

  def can_create?
    unless current_user.gestionnaire_compte_allocataire?
      flash[:error] = 'Seul les gestionnaires de compte allocataire peuvent accéder à cette ressource'
      redirect_back(fallback_location: root_path)
    end
  end

  def can_edit?
    unless current_user.admin?
      flash[:error] = 'Seul les admins peuvent accéder à cette ressource'
      redirect_back(fallback_location: root_path)
    end
  end
end
