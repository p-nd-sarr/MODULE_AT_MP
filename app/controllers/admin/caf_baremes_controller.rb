class Admin::CafBaremesController < ApplicationController
  before_action :set_admin_bareme, only: [:show, :edit, :update, :destroy]

  # GET /admin/baremes
  # GET /admin/baremes.json
  def index
    @admin_baremes = Admin::CafBareme.all.order('date_debut_validite DESC')
  end

  # GET /admin/baremes/1
  # GET /admin/baremes/1.json
  def show
    #show
  end

  # GET /admin/baremes/new
  def new
    @admin_bareme = Admin::CafBareme.new
  end

  # GET /admin/baremes/1/edit
  def edit
    #edit
  end

  # POST /admin/baremes
  # POST /admin/baremes.json
  def create
    @admin_bareme = Admin::CafBareme.new(admin_bareme_params)

    respond_to do |format|
      if @admin_bareme.save
        format.html { redirect_to admin_caf_baremes_url, notice: 'Bareme was successfully created.' }
        format.json { render :show, status: :created, location: @admin_bareme }
      else
        format.html { render :new }
        format.json { render json: @admin_bareme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/baremes/1
  # PATCH/PUT /admin/baremes/1.json
  def update
    respond_to do |format|
      if @admin_bareme.update(admin_bareme_params)
        format.html { redirect_to admin_caf_bareme_path(@admin_bareme), notice: 'Bareme was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_bareme }
      else
        format.html { render :edit }
        format.json { render json: @admin_bareme.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/baremes/1
  # DELETE /admin/baremes/1.json
  def destroy
    @admin_bareme.destroy
    respond_to do |format|
      format.html { redirect_to admin_caf_baremes_url, notice: 'Bareme was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_admin_bareme
    @admin_bareme = Admin::CafBareme.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_bareme_params
    params.require(:admin_caf_bareme).permit( :periode, :montant_indemnites,
                                         :date_debut_validite, :date_fin_validite)
  end
end
