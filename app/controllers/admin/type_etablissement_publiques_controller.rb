class Admin::TypeEtablissementPubliquesController < ApplicationController
  before_action :set_admin_type_etablissement_publique, only: [:show, :edit, :update, :destroy]

  # GET /admin/type_etablissement_publiques
  # GET /admin/type_etablissement_publiques.json
  def index
    @admin_type_etablissement_publiques = Admin::TypeEtablissementPublique.all
  end

  # GET /admin/type_etablissement_publiques/1
  # GET /admin/type_etablissement_publiques/1.json
  def show
    #show
  end

  # GET /admin/type_etablissement_publiques/new
  def new
    @admin_type_etablissement_publique = Admin::TypeEtablissementPublique.new
  end

  # GET /admin/type_etablissement_publiques/1/edit
  def edit
    #edit
  end

  # POST /admin/type_etablissement_publiques
  # POST /admin/type_etablissement_publiques.json
  def create
    @admin_type_etablissement_publique = Admin::TypeEtablissementPublique.new(admin_type_etablissement_publique_params)

    respond_to do |format|
      if @admin_type_etablissement_publique.save
        format.html { redirect_to @admin_type_etablissement_publique, notice: 'Type etablissement publique was successfully created.' }
        format.json { render :show, status: :created, location: @admin_type_etablissement_publique }
      else
        format.html { render :new }
        format.json { render json: @admin_type_etablissement_publique.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/type_etablissement_publiques/1
  # PATCH/PUT /admin/type_etablissement_publiques/1.json
  def update
    respond_to do |format|
      if @admin_type_etablissement_publique.update(admin_type_etablissement_publique_params)
        format.html { redirect_to @admin_type_etablissement_publique, notice: 'Type etablissement publique was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_type_etablissement_publique }
      else
        format.html { render :edit }
        format.json { render json: @admin_type_etablissement_publique.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/type_etablissement_publiques/1
  # DELETE /admin/type_etablissement_publiques/1.json
  def destroy
    @admin_type_etablissement_publique.destroy
    respond_to do |format|
      format.html { redirect_to admin_type_etablissement_publiques_url, notice: 'Type etablissement publique was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_type_etablissement_publique
      @admin_type_etablissement_publique = Admin::TypeEtablissementPublique.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_type_etablissement_publique_params
      params.require(:admin_type_etablissement_publique).permit(:code, :description)
    end
end
