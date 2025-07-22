class Admin::CitiesController < ApplicationController
  before_action :only_admin!
  before_action :set_admin_city, only: [:show, :edit, :update, :destroy]

  # GET /admin/countries
  # GET /admin/countries.json
  def index
    @admin_cities = Admin::City.all
    @pays = Admin::Country.all
  end

  # GET /admin/countries/1
  # GET /admin/countries/1.json
  def show
    @pays = Admin::Country.all
  end

  # GET /admin/countries/new
  def new
    @admin_city = Admin::City.new
    @pays = Admin::Country.all
  end

  # GET /admin/countries/1/edit
  def edit
    @pays = Admin::Country.all
  end

  # POST /admin/countries
  # POST /admin/countries.json
  def create
    @admin_city = Admin::City.new(admin_city_params)

    respond_to do |format|
      if @admin_city.save
        format.html { redirect_to @admin_city, notice: 'City was successfully created.' }
        format.json { render :show, status: :created, location: @admin_city }
      else
        format.html { render :new }
        format.json { render json: @admin_city.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/countries/1
  # PATCH/PUT /admin/countries/1.json
  def update
    respond_to do |format|
      if @admin_city.update(admin_city_params)
        format.html { redirect_to @admin_city, notice: 'City was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_cities }
      else
        format.html { render :edit }
        format.json { render json: @admin_city.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/countries/1
  # DELETE /admin/countries/1.json
  def destroy
    @admin_city.destroy
    respond_to do |format|
      format.html { redirect_to admin_cities_url, notice: 'City was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_admin_city
    @admin_city = Admin::City.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_city_params
    params.require(:admin_city).permit(:description, :admin_country_id)
  end
end
