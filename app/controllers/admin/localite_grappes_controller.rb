class Admin::LocaliteGrappesController < ApplicationController
  before_action :set_admin_localite_grappe, only: [:show, :edit, :update, :destroy]

  # GET /admin/localite_grappes
  # GET /admin/localite_grappes.json
  def index
    @q = Admin::LocaliteGrappe.all.ransack(params[:q])
    #@allocataires = @q.result.page(params[:page]).order('nom, prenom, numero_allocataire').per(100)
    @admin_localite_grappes = @q.result.page(params[:page]).order('localite').per(100)
  end

  # GET /admin/localite_grappes/1
  # GET /admin/localite_grappes/1.json
  def show
    #show
  end

  # GET /admin/localite_grappes/new
  def new
    @admin_localite_grappe = Admin::LocaliteGrappe.new
  end

  # GET /admin/localite_grappes/1/edit
  def edit
    #edit
  end

  # POST /admin/localite_grappes
  # POST /admin/localite_grappes.json
  def create
    @admin_localite_grappe = Admin::LocaliteGrappe.new(admin_localite_grappe_params)

    respond_to do |format|
      if @admin_localite_grappe.save
        format.html { redirect_to @admin_localite_grappe, notice: 'Localite grappe was successfully created.' }
        format.json { render :show, status: :created, location: @admin_localite_grappe }
      else
        format.html { render :new }
        format.json { render json: @admin_localite_grappe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/localite_grappes/1
  # PATCH/PUT /admin/localite_grappes/1.json
  def update
    respond_to do |format|
      if @admin_localite_grappe.update(admin_localite_grappe_params)
        format.html { redirect_to @admin_localite_grappe, notice: 'Localite grappe was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_localite_grappe }
      else
        format.html { render :edit }
        format.json { render json: @admin_localite_grappe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/localite_grappes/1
  # DELETE /admin/localite_grappes/1.json
  def destroy
    @admin_localite_grappe.destroy
    respond_to do |format|
      format.html { redirect_to admin_localite_grappes_url, notice: 'Localite grappe was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_localite_grappe
      @admin_localite_grappe = Admin::LocaliteGrappe.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_localite_grappe_params
      params.require(:admin_localite_grappe).permit(:code_pays, :code_localite, :localite)
    end
end
