class Admin::ProfessionsController < ApplicationController
  before_action :only_admin!
  before_action :set_admin_profession, only: [:show, :edit, :update, :destroy]

  # GET /admin/professions
  # GET /admin/professions.json
  def index
    @admin_professions = Admin::Profession.all
  end

  # GET /admin/professions/1
  # GET /admin/professions/1.json
  def show
    #show
  end

  # GET /admin/professions/new
  def new
    @admin_profession = Admin::Profession.new
  end

  # GET /admin/professions/1/edit
  def edit
    #edit
  end

  # POST /admin/professions
  # POST /admin/professions.json
  def create
    @admin_profession = Admin::Profession.new(admin_profession_params)

    respond_to do |format|
      if @admin_profession.save
        format.html { redirect_to @admin_profession, notice: 'Profession was successfully created.' }
        format.json { render :show, status: :created, location: @admin_profession }
      else
        format.html { render :new }
        format.json { render json: @admin_profession.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/professions/1
  # PATCH/PUT /admin/professions/1.json
  def update
    respond_to do |format|
      if @admin_profession.update(admin_profession_params)
        format.html { redirect_to @admin_profession, notice: 'Profession was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_profession }
      else
        format.html { render :edit }
        format.json { render json: @admin_profession.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/professions/1
  # DELETE /admin/professions/1.json
  def destroy
    @admin_profession.destroy
    respond_to do |format|
      format.html { redirect_to admin_professions_url, notice: 'Profession was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_profession
      @admin_profession = Admin::Profession.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_profession_params
      params.require(:admin_profession).permit(:code, :description)
    end
end
