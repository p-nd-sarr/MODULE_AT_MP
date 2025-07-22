class Admin::TypeRegimesController < ApplicationController
  before_action :set_admin_type_regime, only: [:show, :edit, :update, :destroy]

  # GET /admin/type_regimes
  # GET /admin/type_regimes.json
  def index
    @admin_type_regimes = Admin::TypeRegime.all
  end

  # GET /admin/type_regimes/1
  # GET /admin/type_regimes/1.json
  def show
    #show
  end

  # GET /admin/type_regimes/new
  def new
    @admin_type_regime = Admin::TypeRegime.new
  end

  # GET /admin/type_regimes/1/edit
  def edit
    #edit
  end

  # POST /admin/type_regimes
  # POST /admin/type_regimes.json
  def create
    @admin_type_regime = Admin::TypeRegime.new(admin_type_regime_params)

    respond_to do |format|
      if @admin_type_regime.save
        format.html { redirect_to @admin_type_regime, notice: 'Type regime was successfully created.' }
        format.json { render :show, status: :created, location: @admin_type_regime }
      else
        format.html { render :new }
        format.json { render json: @admin_type_regime.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/type_regimes/1
  # PATCH/PUT /admin/type_regimes/1.json
  def update
    respond_to do |format|
      if @admin_type_regime.update(admin_type_regime_params)
        format.html { redirect_to @admin_type_regime, notice: 'Type regime was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_type_regime }
      else
        format.html { render :edit }
        format.json { render json: @admin_type_regime.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/type_regimes/1
  # DELETE /admin/type_regimes/1.json
  def destroy
    @admin_type_regime.destroy
    respond_to do |format|
      format.html { redirect_to admin_type_regimes_url, notice: 'Type regime was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_type_regime
      @admin_type_regime = Admin::TypeRegime.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_type_regime_params
      params.require(:admin_type_regime).permit(:code, :description)
    end
end
