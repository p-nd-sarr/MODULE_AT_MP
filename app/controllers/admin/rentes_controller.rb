class Admin::RentesController < ApplicationController
  before_action :set_admin_rente, only: [:show, :edit, :update, :destroy]

  # GET /admin/rentes
  # GET /admin/rentes.json
  def index
    @admin_rentes = Admin::Rente.all
  end

  # GET /admin/rentes/1
  # GET /admin/rentes/1.json
  def show
    #show
  end

  # GET /admin/rentes/new
  def new
    @admin_rente = Admin::Rente.new
  end

  # GET /admin/rentes/1/edit
  def edit
    #edit
  end

  # POST /admin/rentes
  # POST /admin/rentes.json
  def create
    @admin_rente = Admin::Rente.new(admin_rente_params)

    respond_to do |format|
      if @admin_rente.save
        format.html { redirect_to @admin_rente, notice: 'Rente was successfully created.' }
        format.json { render :show, status: :created, location: @admin_rente }
      else
        format.html { render :new }
        format.json { render json: @admin_rente.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/rentes/1
  # PATCH/PUT /admin/rentes/1.json
  def update
    respond_to do |format|
      if @admin_rente.update(admin_rente_params)
        format.html { redirect_to @admin_rente, notice: 'Rente was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_rente }
      else
        format.html { render :edit }
        format.json { render json: @admin_rente.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/rentes/1
  # DELETE /admin/rentes/1.json
  def destroy
    @admin_rente.destroy
    respond_to do |format|
      format.html { redirect_to admin_rentes_url, notice: 'Rente was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_rente
      @admin_rente = Admin::Rente.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_rente_params
      params.require(:admin_rente).permit(:age, :prix)
    end
end
