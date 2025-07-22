class Admin::JourOuvrableAnnuelsController < ApplicationController
  before_action :set_admin_jour_ouvrable_annuel, only: [:show, :edit, :update, :destroy]

  # GET /admin/jour_ouvrable_annuels
  # GET /admin/jour_ouvrable_annuels.json
  def index
    @admin_jour_ouvrable_annuels = Admin::JourOuvrableAnnuel.all
  end

  # GET /admin/jour_ouvrable_annuels/1
  # GET /admin/jour_ouvrable_annuels/1.json
  def show
    #show
  end

  # GET /admin/jour_ouvrable_annuels/new
  def new
    @admin_jour_ouvrable_annuel = Admin::JourOuvrableAnnuel.new
  end

  # GET /admin/jour_ouvrable_annuels/1/edit
  def edit
    #edit
  end

  # POST /admin/jour_ouvrable_annuels
  # POST /admin/jour_ouvrable_annuels.json
  def create
    @admin_jour_ouvrable_annuel = Admin::JourOuvrableAnnuel.new(admin_jour_ouvrable_annuel_params)

    respond_to do |format|
      if @admin_jour_ouvrable_annuel.save
        format.html { redirect_to @admin_jour_ouvrable_annuel, notice: 'Jour ouvrable annuel was successfully created.' }
        format.json { render :show, status: :created, location: @admin_jour_ouvrable_annuel }
      else
        format.html { render :new }
        format.json { render json: @admin_jour_ouvrable_annuel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/jour_ouvrable_annuels/1
  # PATCH/PUT /admin/jour_ouvrable_annuels/1.json
  def update
    respond_to do |format|
      if @admin_jour_ouvrable_annuel.update(admin_jour_ouvrable_annuel_params)
        format.html { redirect_to @admin_jour_ouvrable_annuel, notice: 'Jour ouvrable annuel was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_jour_ouvrable_annuel }
      else
        format.html { render :edit }
        format.json { render json: @admin_jour_ouvrable_annuel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/jour_ouvrable_annuels/1
  # DELETE /admin/jour_ouvrable_annuels/1.json
  def destroy
    @admin_jour_ouvrable_annuel.destroy
    respond_to do |format|
      format.html { redirect_to admin_jour_ouvrable_annuels_url, notice: 'Jour ouvrable annuel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_jour_ouvrable_annuel
      @admin_jour_ouvrable_annuel = Admin::JourOuvrableAnnuel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_jour_ouvrable_annuel_params
      params.require(:admin_jour_ouvrable_annuel).permit(:mois, :mois_en_chiffre, :nombre_jour_ouvrable, :annee)
    end
end
