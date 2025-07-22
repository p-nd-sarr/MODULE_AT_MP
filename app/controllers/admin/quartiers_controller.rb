class Admin::QuartiersController < ApplicationController
  before_action :set_admin_quartier, only: [:show, :edit, :update, :destroy]

  # GET /admin/quartiers
  # GET /admin/quartiers.json
  def index
    @admin_quartiers = Admin::Quartier.all.page(params[:page]).per(100)
  end

  # GET /admin/quartiers/1
  # GET /admin/quartiers/1.json
  def show
    #show
  end

  # GET /admin/quartiers/new
  def new
    @admin_quartier = Admin::Quartier.new
  end

  # GET /admin/quartiers/1/edit
  def edit
    #edit
  end

  # POST /admin/quartiers
  # POST /admin/quartiers.json
  def create
    @admin_quartier = Admin::Quartier.new(admin_quartier_params)

    respond_to do |format|
      if @admin_quartier.save
        format.html { redirect_to @admin_quartier, notice: 'Quartier was successfully created.' }
        format.json { render :show, status: :created, location: @admin_quartier }
      else
        format.html { render :new }
        format.json { render json: @admin_quartier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/quartiers/1
  # PATCH/PUT /admin/quartiers/1.json
  def update
    respond_to do |format|
      if @admin_quartier.update(admin_quartier_params)
        format.html { redirect_to @admin_quartier, notice: 'Quartier was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_quartier }
      else
        format.html { render :edit }
        format.json { render json: @admin_quartier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/quartiers/1
  # DELETE /admin/quartiers/1.json
  def destroy
    @admin_quartier.destroy
    respond_to do |format|
      format.html { redirect_to admin_quartiers_url, notice: 'Quartier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_quartier
      @admin_quartier = Admin::Quartier.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_quartier_params
      params.require(:admin_quartier).permit(:admin_commune_id, :code, :designation)
    end
end
