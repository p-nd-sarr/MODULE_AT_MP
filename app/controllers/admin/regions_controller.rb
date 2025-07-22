class Admin::RegionsController < ApplicationController
  before_action :set_admin_region, only: [:show, :edit, :update, :destroy]

  # GET /admin/regions
  # GET /admin/regions.json
  def index
    @admin_regions = Admin::Region.all
  end

  # GET /admin/regions/1
  # GET /admin/regions/1.json
  def show
    #show
  end

  # GET /admin/regions/new
  def new
    @admin_region = Admin::Region.new
  end

  # GET /admin/regions/1/edit
  def edit
    #edit
  end

  # POST /admin/regions
  # POST /admin/regions.json
  def create
    @admin_region = Admin::Region.new(admin_region_params)

    respond_to do |format|
      if @admin_region.save
        format.html { redirect_to @admin_region, notice: 'Region was successfully created.' }
        format.json { render :show, status: :created, location: @admin_region }
      else
        format.html { render :new }
        format.json { render json: @admin_region.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/regions/1
  # PATCH/PUT /admin/regions/1.json
  def update
    respond_to do |format|
      if @admin_region.update(admin_region_params)
        format.html { redirect_to @admin_region, notice: 'Region was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_region }
      else
        format.html { render :edit }
        format.json { render json: @admin_region.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/regions/1
  # DELETE /admin/regions/1.json
  def destroy
    @admin_region.destroy
    respond_to do |format|
      format.html { redirect_to admin_regions_url, notice: 'Region was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_region
      @admin_region = Admin::Region.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_region_params
      params.require(:admin_region).permit(:designation, :code, :admin_country_id)
    end
end
