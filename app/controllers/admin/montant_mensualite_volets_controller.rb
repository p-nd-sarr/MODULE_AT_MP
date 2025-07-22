class Admin::MontantMensualiteVoletsController < ApplicationController
  before_action :only_admin!
  before_action :set_montant_mensualite_volet, only: [:show, :edit, :update, :destroy]

  # GET /montant_mensualite_volets
  # GET /montant_mensualite_volets.json
  def index
    @montant_mensualite_volets = Admin::MontantMensualiteVolet.all
  end

  # GET /montant_mensualite_volets/1
  # GET /montant_mensualite_volets/1.json
  def show
    #show
  end

  # GET /montant_mensualite_volets/new
  def new
    @montant_mensualite_volet = Admin::MontantMensualiteVolet.new
  end

  # GET /montant_mensualite_volets/1/edit
  def edit
    #edit
  end

  # POST /montant_mensualite_volets
  # POST /montant_mensualite_volets.json
  def create
    @montant_mensualite_volet = Admin::MontantMensualiteVolet.new(montant_mensualite_volet_params)

    respond_to do |format|
      if @montant_mensualite_volet.save
        #format.html { redirect_to @montant_mensualite_volet, notice: 'Montant mensualite volet was successfully created.' }
        format.html { redirect_to admin_montant_mensualite_volets_url, notice: 'Montant mensualite volet was successfully created.' }
        format.json { render :show, status: :created, location: @montant_mensualite_volet }
      else
        format.html { render :new }
        format.json { render json: @montant_mensualite_volet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /montant_mensualite_volets/1
  # PATCH/PUT /montant_mensualite_volets/1.json
  def update
    respond_to do |format|
      if @montant_mensualite_volet.update(montant_mensualite_volet_params)
        format.html { redirect_to @montant_mensualite_volet, notice: 'Montant mensualite volet was successfully updated.' }
        format.json { render :show, status: :ok, location: @montant_mensualite_volet }
      else
        format.html { render :edit }
        format.json { render json: @montant_mensualite_volet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /montant_mensualite_volets/1
  # DELETE /montant_mensualite_volets/1.json
  def destroy
    @montant_mensualite_volet.destroy
    respond_to do |format|
      format.html { redirect_to admin_montant_mensualite_volets_url, notice: 'Montant mensualite volet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_montant_mensualite_volet
      @montant_mensualite_volet = Admin::MontantMensualiteVolet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def montant_mensualite_volet_params
      params.require(:admin_montant_mensualite_volet).permit(:num_volet, :montant, :date_changement)
    end
end
