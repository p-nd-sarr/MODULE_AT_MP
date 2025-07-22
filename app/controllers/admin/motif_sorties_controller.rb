class Admin::MotifSortiesController < ApplicationController
  before_action :set_admin_motif_sortie, only: [:show, :edit, :update, :destroy]

  # GET /admin/motif_sorties
  # GET /admin/motif_sorties.json
  def index
    @admin_motif_sorties = Admin::MotifSortie.all
  end

  # GET /admin/motif_sorties/1
  # GET /admin/motif_sorties/1.json
  def show
    #show
  end

  # GET /admin/motif_sorties/new
  def new
    @admin_motif_sortie = Admin::MotifSortie.new
  end

  # GET /admin/motif_sorties/1/edit
  def edit
    #edit
  end

  # POST /admin/motif_sorties
  # POST /admin/motif_sorties.json
  def create
    @admin_motif_sortie = Admin::MotifSortie.new(admin_motif_sortie_params)

    respond_to do |format|
      if @admin_motif_sortie.save
        format.html { redirect_to @admin_motif_sortie, notice: 'Motif sortie was successfully created.' }
        format.json { render :show, status: :created, location: @admin_motif_sortie }
      else
        format.html { render :new }
        format.json { render json: @admin_motif_sortie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/motif_sorties/1
  # PATCH/PUT /admin/motif_sorties/1.json
  def update
    respond_to do |format|
      if @admin_motif_sortie.update(admin_motif_sortie_params)
        format.html { redirect_to @admin_motif_sortie, notice: 'Motif sortie was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_motif_sortie }
      else
        format.html { render :edit }
        format.json { render json: @admin_motif_sortie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/motif_sorties/1
  # DELETE /admin/motif_sorties/1.json
  def destroy
    @admin_motif_sortie.destroy
    respond_to do |format|
      format.html { redirect_to admin_motif_sorties_url, notice: 'Motif sortie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_motif_sortie
      @admin_motif_sortie = Admin::MotifSortie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_motif_sortie_params
      params.require(:admin_motif_sortie).permit(:code, :description)
    end
end
