class Admin::BaremeImpotsController < Admin::ApplicationController
  before_action :set_bareme_impot, only: [:show, :edit, :update, :destroy]

  # GET /admin/baremes
  # GET /admin/baremes.json
  def index
    @bareme_impots = BaremeImpot.all.order(:revenu_brut).page(params[:page]).per(150)
  end

  # GET /admin/baremes/1
  # GET /admin/baremes/1.json
  def show
    #show
  end

  # GET /admin/baremes/new
  def new
    @bareme_impot = BaremeImpot.new
  end

  # GET /admin/baremes/1/edit
  def edit
    #edit
  end

  # POST /admin/baremes
  # POST /admin/baremes.json
  def create
    @bareme_impot = BaremeImpot.new(bareme_impot_params)

    respond_to do |format|
      if @bareme_impot.save
        format.html { redirect_to bareme_impots_url, notice: 'Bareme was successfully created.' }
        format.json { render :show, status: :created, location: @bareme_impot }
      else
        format.html { render :new }
        format.json { render json: @bareme_impot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/baremes/1
  # PATCH/PUT /admin/baremes/1.json
  def update
    respond_to do |format|
      if @bareme_impot.update(bareme_impot_params)
        format.html { redirect_to bareme_impots_url, notice: 'Bareme was successfully updated.' }
        format.json { render :show, status: :ok, location: @bareme_impot }
      else
        format.html { render :edit }
        format.json { render json: @bareme_impot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/baremes/1
  # DELETE /admin/baremes/1.json
  def destroy
    @bareme_impot.destroy
    respond_to do |format|
      format.html { redirect_to bareme_impots_url, notice: 'Bareme was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bareme_impot
      @bareme_impot = BaremeImpot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bareme_impot_params
      params.require(:bareme_impot).permit(:revenu_brut, :trimf, :un,:un_cinq, :deux, :deux_cinq,
                                           :trois, :trois_cinq, :quatre, :quatre_cinq, :cinq)
    end
end
