class Admin::AtCarnetsController < Admin::ApplicationController
  before_action :set_at_carnet, only: [:show, :edit, :update, :destroy]
   before_action :set_arret_travail, only: [:destroy, :update, :edit,  :show]

  # GET /at_carnets
  # GET /at_carnets.json
  def index
    @at_carnets = AtCarnet.all
  end

  # GET /at_carnets/1
  # GET /at_carnets/1.json
  def show
  end

  # GET /at_carnets/new
  def new
    @at_carnet = AtCarnet.new
  end

  # GET /at_carnets/1/edit
  def edit
  end

  # POST /at_carnets
  # POST /at_carnets.json
  def create
    @at_carnet = AtCarnet.new(at_carnet_params)

    respond_to do |format|
      if @at_carnet.save
        format.html { redirect_to @at_carnet, notice: 'At carnet was successfully created.' }
        format.json { render :show, status: :created, location: @at_carnet }
      else
        format.html { render :new }
        format.json { render json: @at_carnet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /at_carnets/1
  # PATCH/PUT /at_carnets/1.json
  def update
    respond_to do |format|
      if @at_carnet.update(at_carnet_params)
        format.html { redirect_to [:admin, @arret_travail], notice: 'Carnet was successfully updated.' }
        format.json { render :show, status: :ok, location: @at_carnet }
      else
        format.html { render :edit }
        format.json { render json: @at_carnet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /at_carnets/1
  # DELETE /at_carnets/1.json
  def destroy
    @at_carnet.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @arret_travail], notice: 'Carnet a été  supprimé avec succés.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_at_carnet
      @at_carnet = AtCarnet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def at_carnet_params
      params.require(:at_carnet).permit(:numero_carnet, :arret_travail_id, :numero_employeur, :date_achat)
    end

     def set_arret_travail
    @arret_travail = ArretTravail.find(@at_carnet.arret_travail_id)
  end
end
