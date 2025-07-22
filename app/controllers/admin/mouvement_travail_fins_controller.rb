class Admin::MouvementTravailFinsController < ApplicationController
  before_action :set_admin_mouvement_travail_fin, only: [:show, :edit, :update, :destroy]

  # GET /admin/mouvement_travail_fins
  # GET /admin/mouvement_travail_fins.json
  def index
    @admin_mouvement_travail_fins = Admin::MouvementTravailFin.all
  end

  # GET /admin/mouvement_travail_fins/1
  # GET /admin/mouvement_travail_fins/1.json
  def show
    #show
  end

  # GET /admin/mouvement_travail_fins/new
  def new
    @admin_mouvement_travail_fin = Admin::MouvementTravailFin.new
  end

  # GET /admin/mouvement_travail_fins/1/edit
  def edit
    #edit
  end

  # POST /admin/mouvement_travail_fins
  # POST /admin/mouvement_travail_fins.json
  def create
    @admin_mouvement_travail_fin = Admin::MouvementTravailFin.new(admin_mouvement_travail_fin_params)

    respond_to do |format|
      if @admin_mouvement_travail_fin.save
        format.html { redirect_to @admin_mouvement_travail_fin, notice: 'Mouvement travail fin was successfully created.' }
        format.json { render :show, status: :created, location: @admin_mouvement_travail_fin }
      else
        format.html { render :new }
        format.json { render json: @admin_mouvement_travail_fin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/mouvement_travail_fins/1
  # PATCH/PUT /admin/mouvement_travail_fins/1.json
  def update
    respond_to do |format|
      if @admin_mouvement_travail_fin.update(admin_mouvement_travail_fin_params)
        format.html { redirect_to @admin_mouvement_travail_fin, notice: 'Mouvement travail fin was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_mouvement_travail_fin }
      else
        format.html { render :edit }
        format.json { render json: @admin_mouvement_travail_fin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/mouvement_travail_fins/1
  # DELETE /admin/mouvement_travail_fins/1.json
  def destroy
    @admin_mouvement_travail_fin.destroy
    respond_to do |format|
      format.html { redirect_to admin_mouvement_travail_fins_url, notice: 'Mouvement travail fin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_mouvement_travail_fin
      @admin_mouvement_travail_fin = Admin::MouvementTravailFin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_mouvement_travail_fin_params
      params.require(:admin_mouvement_travail_fin).permit(:code, :description)
    end
end
