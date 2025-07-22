class Admin::BanqueAgencesController < ApplicationController
  before_action :set_admin_banque_agence, only: [:show, :edit, :update, :destroy]

  # GET /admin/banque_agences
  # GET /admin/banque_agences.json
  def index
    @admin_banque_agences = Admin::BanqueAgence.all
  end

  # GET /admin/banque_agences/1
  # GET /admin/banque_agences/1.json
  def show
    #show
  end

  # GET /admin/banque_agences/new
  def new
    @admin_banque_agence = Admin::BanqueAgence.new
  end

  # GET /admin/banque_agences/1/edit
  def edit
    #edit
  end

  # POST /admin/banque_agences
  # POST /admin/banque_agences.json
  def create
    @admin_banque_agence = Admin::BanqueAgence.new(admin_banque_agence_params)

    respond_to do |format|
      if @admin_banque_agence.save
        format.html { redirect_to @admin_banque_agence, notice: 'Banque agence was successfully created.' }
        format.json { render :show, status: :created, location: @admin_banque_agence }
      else
        format.html { render :new }
        format.json { render json: @admin_banque_agence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/banque_agences/1
  # PATCH/PUT /admin/banque_agences/1.json
  def update
    respond_to do |format|
      if @admin_banque_agence.update(admin_banque_agence_params)
        format.html { redirect_to @admin_banque_agence, notice: 'Banque agence was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_banque_agence }
      else
        format.html { render :edit }
        format.json { render json: @admin_banque_agence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/banque_agences/1
  # DELETE /admin/banque_agences/1.json
  def destroy
    @admin_banque_agence.destroy
    respond_to do |format|
      format.html { redirect_to admin_banque_agences_url, notice: 'Banque agence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_banque_agence
      @admin_banque_agence = Admin::BanqueAgence.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_banque_agence_params
      params.require(:admin_banque_agence).permit(:admin_banque_id, :nom, :code, :bank_branch_id)
    end
end
