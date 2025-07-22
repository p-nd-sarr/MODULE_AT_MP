class Admin::AssociationAllocatairesController < ApplicationController
  before_action :set_admin_association_allocataire, only: [:show, :edit, :update, :destroy]

  # GET /admin/association_allocataires
  # GET /admin/association_allocataires.json
  def index
    @admin_association_allocataires = Admin::AssociationAllocataire.all
  end

  # GET /admin/association_allocataires/1
  # GET /admin/association_allocataires/1.json
  def show
  end

  # GET /admin/association_allocataires/new
  def new
    @admin_association_allocataire = Admin::AssociationAllocataire.new
  end

  # GET /admin/association_allocataires/1/edit
  def edit
  end

  # POST /admin/association_allocataires
  # POST /admin/association_allocataires.json
  def create
    @admin_association_allocataire = Admin::AssociationAllocataire.new(admin_association_allocataire_params)

    respond_to do |format|
      if @admin_association_allocataire.save
        format.html { redirect_to @admin_association_allocataire, notice: 'Association allocataire was successfully created.' }
        format.json { render :show, status: :created, location: @admin_association_allocataire }
      else
        format.html { render :new }
        format.json { render json: @admin_association_allocataire.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/association_allocataires/1
  # PATCH/PUT /admin/association_allocataires/1.json
  def update
    respond_to do |format|
      if @admin_association_allocataire.update(admin_association_allocataire_params)
        format.html { redirect_to @admin_association_allocataire, notice: 'Association allocataire was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_association_allocataire }
      else
        format.html { render :edit }
        format.json { render json: @admin_association_allocataire.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/association_allocataires/1
  # DELETE /admin/association_allocataires/1.json
  def destroy
    @admin_association_allocataire.destroy
    respond_to do |format|
      format.html { redirect_to admin_association_allocataires_url, notice: 'Association allocataire was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_association_allocataire
      @admin_association_allocataire = Admin::AssociationAllocataire.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_association_allocataire_params
      params.require(:admin_association_allocataire).permit(:name)
    end
end
