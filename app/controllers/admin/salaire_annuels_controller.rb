class Admin::SalaireAnnuelsController < ApplicationController
  before_action :set_admin_salaire_annuel, only: [:show, :edit, :update, :destroy]

  # GET /admin/salaire_annuels
  # GET /admin/salaire_annuels.json
  def index
    @admin_salaire_annuels = Admin::SalaireAnnuel.all
  end

  # GET /admin/salaire_annuels/1
  # GET /admin/salaire_annuels/1.json
  def show
    #show
  end

  # GET /admin/salaire_annuels/new
  def new
    @admin_salaire_annuel = Admin::SalaireAnnuel.new
  end

  # GET /admin/salaire_annuels/1/edit
  def edit
    #edit
  end

  # POST /admin/salaire_annuels
  # POST /admin/salaire_annuels.json
  def create
    @admin_salaire_annuel = Admin::SalaireAnnuel.new(admin_salaire_annuel_params)
    @admin_salaire_annuel.date_effet = @admin_salaire_annuel.date_effet.strftime('%m/%d/%Y')
    @admin_salaire_annuel.date_reval = @admin_salaire_annuel.date_reval.strftime('%m/%d/%Y')

    respond_to do |format|
      if @admin_salaire_annuel.save
        format.html { redirect_to @admin_salaire_annuel, notice: 'Salaire annuel was successfully created.' }
        format.json { render :show, status: :created, location: @admin_salaire_annuel }
      else
        format.html { render :new }
        format.json { render json: @admin_salaire_annuel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/salaire_annuels/1
  # PATCH/PUT /admin/salaire_annuels/1.json
  def update
    respond_to do |format|
      if @admin_salaire_annuel.update(admin_salaire_annuel_params)
        format.html { redirect_to @admin_salaire_annuel, notice: 'Salaire annuel was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_salaire_annuel }
      else
        format.html { render :edit }
        format.json { render json: @admin_salaire_annuel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/salaire_annuels/1
  # DELETE /admin/salaire_annuels/1.json
  def destroy
    @admin_salaire_annuel.destroy
    respond_to do |format|
      format.html { redirect_to admin_salaire_annuels_url, notice: 'Salaire annuel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_salaire_annuel
      @admin_salaire_annuel = Admin::SalaireAnnuel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_salaire_annuel_params
      params.require(:admin_salaire_annuel).permit(:annee, :coefficient, :date_effet, :date_reval, :plancher, :plafond)
    end
end
