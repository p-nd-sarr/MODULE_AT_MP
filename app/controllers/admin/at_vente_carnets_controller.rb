class Admin::AtVenteCarnetsController < ApplicationController
  before_action :set_at_vente_carnet, only: %i[ show edit update destroy ]

  # GET /at_vente_carnets or /at_vente_carnets.json
  def index
    @q = AtVenteCarnet.en_agence(current_user.admin_agence.id).ransack(params[:q])
    @at_vente_carnets = @q.result.order('created_at desc').page(params[:page]).per(100)

  end

  # GET /at_vente_carnets/1 or /at_vente_carnets/1.json
  def show
    @employeur = Psrm::Employeur.find_by_fhnum(@at_vente_carnet.num_employeur)
  end

  # GET /at_vente_carnets/new
  def new
    @at_vente_carnet = AtVenteCarnet.new
  end

  # GET /at_vente_carnets/1/edit
  def edit
  end

  # POST /at_vente_carnets or /at_vente_carnets.json
  def create
    @at_vente_carnet = AtVenteCarnet.new(at_vente_carnet_params)
    @at_vente_carnet.numero_carnet = params[:numero_carnet]
    @at_vente_carnet.ajoute_par = current_user
    @at_vente_carnet.admin_agence = current_user.agence

    respond_to do |format|
      if @at_vente_carnet.save
        format.html { redirect_to [:admin, @at_vente_carnet], notice: "At vente de carnet créée avec succès." }
        format.json { render :show, status: :created, location: @at_vente_carnet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @at_vente_carnet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /at_vente_carnets/1 or /at_vente_carnets/1.json
  def update
    @at_vente_carnet.numero_carnet = params[:numero_carnet]
    respond_to do |format|
      if @at_vente_carnet.update(at_vente_carnet_params)
        format.html { redirect_to admin_at_vente_carnet_path(@at_vente_carnet), notice: "At vente de carnet modifiée avec succès." }
        format.json { render :show, status: :ok, location: @at_vente_carnet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @at_vente_carnet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /at_vente_carnets/1 or /at_vente_carnets/1.json
  def destroy
    @at_vente_carnet.destroy

    respond_to do |format|
      format.html { redirect_to admin_at_vente_carnets_path, notice: "At vente de carnet supprimée avec succès." }
      format.json { head :no_content }
    end
  end

  def employeur_carnet
    employer_params = params[:numero_employeur]
    carnet_params = params[:numero_carnet]
    @carnets = AtVenteCarnet.where(num_employeur: employer_params)
    @carnet = @carnets.select { |c| c.numero_carnet.include?(carnet_params) }.first
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_at_vente_carnet
    @at_vente_carnet = AtVenteCarnet.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def at_vente_carnet_params
    params.require(:at_vente_carnet).permit(:date_delivrance, :num_recu, :num_employeur, :numero_carnet, :num_carnets)
  end
end
