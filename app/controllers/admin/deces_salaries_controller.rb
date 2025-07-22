class Admin::DecesSalariesController < ApplicationController
  before_action :set_admin_deces_salary, only: [:show, :edit, :update, :destroy]

  # GET /admin/deces_salaries
  # GET /admin/deces_salaries.json
  def index
    @q = DecesSalarie.all.ransack(params[:q])
    @admin_deces_salaries = @q.result.order('prenom asc')
    @admin_deces_salaries = @q.result.order('prenom asc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  # GET /admin/deces_salaries/1
  # GET /admin/deces_salaries/1.json
  def show
  end

  # GET /admin/deces_salaries/new
  def new
    @admin_deces_salary = DecesSalarie.new
  end

  # GET /admin/deces_salaries/1/edit
  def edit
  end

  # POST /admin/deces_salaries
  # POST /admin/deces_salaries.json
  def create
    @admin_deces_salary = DecesSalarie.new(admin_deces_salary_params)

    respond_to do |format|
      if @admin_deces_salary.save
        format.html { redirect_to admin_deces_salaries_path, notice: 'Deces salarie was successfully created.' }
        format.json { render :show, status: :created, location: @admin_deces_salary }
      else
        format.html { render :new }
        format.json { render json: @admin_deces_salary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/deces_salaries/1
  # PATCH/PUT /admin/deces_salaries/1.json
  def update
    respond_to do |format|
      if @admin_deces_salary.update(admin_deces_salary_params)
        format.html { redirect_to admin_deces_salaries_path, notice: 'Deces salarie was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_deces_salary }
      else
        format.html { render :edit }
        format.json { render json: @admin_deces_salary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/deces_salaries/1
  # DELETE /admin/deces_salaries/1.json
  def destroy
    @admin_deces_salary.destroy
    respond_to do |format|
      format.html { redirect_to admin_deces_salaries_url, notice: 'Deces salarie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_deces_salary
      @admin_deces_salary = DecesSalarie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_deces_salary_params
      params.require(:deces_salarie).permit(:numero_affiliation, :prenom, :nom, :date_deces, :numero_piece, :certificat_deces)
    end
end
