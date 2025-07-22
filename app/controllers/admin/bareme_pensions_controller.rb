class Admin::BaremePensionsController < ApplicationController
  before_action :set_admin_bareme_pension, only: [:show, :edit, :update, :destroy]

  # GET /admin/bareme_pensions
  # GET /admin/bareme_pensions.json
  def index
    @admin_bareme_pensions = Admin::BaremePension.all.includes(:admin_type_regime).order('date_debut_validite DESC, admin_type_regime_id DESC')
  end

  # GET /admin/bareme_pensions/1
  # GET /admin/bareme_pensions/1.json
  def show
    #show
  end

  # GET /admin/bareme_pensions/new
  def new
    @admin_bareme_pension = Admin::BaremePension.new
  end

  # GET /admin/bareme_pensions/1/edit
  def edit
    #edit
  end

  # POST /admin/bareme_pensions
  # POST /admin/bareme_pensions.json
  def create
    @admin_bareme_pension = Admin::BaremePension.new(admin_bareme_pension_params)

    respond_to do |format|
      if @admin_bareme_pension.save
        format.html { redirect_to @admin_bareme_pension, notice: 'Bareme pension was successfully created.' }
        format.json { render :show, status: :created, location: @admin_bareme_pension }
      else
        format.html { render :new }
        format.json { render json: @admin_bareme_pension.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/bareme_pensions/1
  # PATCH/PUT /admin/bareme_pensions/1.json
  def update
    respond_to do |format|
      if @admin_bareme_pension.update(admin_bareme_pension_params)
        format.html { redirect_to @admin_bareme_pension, notice: 'Bareme pension was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_bareme_pension }
      else
        format.html { render :edit }
        format.json { render json: @admin_bareme_pension.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/bareme_pensions/1
  # DELETE /admin/bareme_pensions/1.json
  def destroy
    @admin_bareme_pension.destroy
    respond_to do |format|
      format.html { redirect_to admin_bareme_pensions_url, notice: 'Bareme pension was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_bareme_pension
      @admin_bareme_pension = Admin::BaremePension.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_bareme_pension_params
      params.require(:admin_bareme_pension).permit(:admin_type_regime_id, :date_debut_validite, :date_fin_validite, :valeur_point_annuelle, :valeur_point_trimestrielle, :valeur_point_bimestrielle, :valeur_point_mensuelle)
    end
end
