class HistoriquesController < ApplicationController
  before_action :set_historique, only: [:show, :edit, :update, :destroy]

  # GET /historiques
  # GET /historiques.json
  def index
    @historiques = Historique.all
  end

  # GET /historiques/1
  # GET /historiques/1.json
  def show
    #show
  end

  # GET /historiques/new
  def new
    @historique = Historique.new
  end

  # GET /historiques/1/edit
  def edit
    #edit
  end

  # POST /historiques
  # POST /historiques.json
  def create
    @historique = Historique.new(historique_params)

    respond_to do |format|
      if @historique.save
        format.html { redirect_to @historique, notice: 'Historique was successfully created.' }
        format.json { render :show, status: :created, location: @historique }
      else
        format.html { render :new }
        format.json { render json: @historique.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /historiques/1
  # PATCH/PUT /historiques/1.json
  def update
    respond_to do |format|
      if @historique.update(historique_params)
        format.html { redirect_to @historique, notice: 'Historique was successfully updated.' }
        format.json { render :show, status: :ok, location: @historique }
      else
        format.html { render :edit }
        format.json { render json: @historique.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /historiques/1
  # DELETE /historiques/1.json
  def destroy
    @historique.destroy
    respond_to do |format|
      format.html { redirect_to historiques_url, notice: 'Historique was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_historique
      @historique = Historique.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def historique_params
      params.require(:historique).permit(:date_valide, :date_soumission, :date_suspension, :date_reversion, :date_extinction, :user, :allocataire)
    end
end
