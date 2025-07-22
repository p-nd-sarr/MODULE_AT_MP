class Admin::MouvementTravailsController < ApplicationController
  before_action :set_admin_mouvement_travail, only: [:show, :edit, :update, :destroy]

  # GET /admin/mouvement_travails
  # GET /admin/mouvement_travails.json
  def index
    @admin_mouvement_travails = Admin::MouvementTravail.all
  end

  # GET /admin/mouvement_travails/1
  # GET /admin/mouvement_travails/1.json
  def show
    #show
  end

  # GET /admin/mouvement_travails/new
  def new
    @admin_mouvement_travail = Admin::MouvementTravail.new
  end

  # GET /admin/mouvement_travails/1/edit
  def edit
    #edit
  end

  # POST /admin/mouvement_travails
  # POST /admin/mouvement_travails.json
  def create
    @admin_mouvement_travail = Admin::MouvementTravail.new(admin_mouvement_travail_params)

    respond_to do |format|
      if @admin_mouvement_travail.save
        format.html { redirect_to @admin_mouvement_travail, notice: 'Mouvement travail was successfully created.' }
        format.json { render :show, status: :created, location: @admin_mouvement_travail }
      else
        format.html { render :new }
        format.json { render json: @admin_mouvement_travail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/mouvement_travails/1
  # PATCH/PUT /admin/mouvement_travails/1.json
  def update
    respond_to do |format|
      if @admin_mouvement_travail.update(admin_mouvement_travail_params)
        format.html { redirect_to @admin_mouvement_travail, notice: 'Mouvement travail was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_mouvement_travail }
      else
        format.html { render :edit }
        format.json { render json: @admin_mouvement_travail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/mouvement_travails/1
  # DELETE /admin/mouvement_travails/1.json
  def destroy
    @admin_mouvement_travail.destroy
    respond_to do |format|
      format.html { redirect_to admin_mouvement_travails_url, notice: 'Mouvement travail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_mouvement_travail
      @admin_mouvement_travail = Admin::MouvementTravail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_mouvement_travail_params
      params.require(:admin_mouvement_travail).permit(:code, :description)
    end
end
