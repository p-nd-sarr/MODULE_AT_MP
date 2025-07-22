class Admin::TypeContratSalariesController < Admin::ApplicationController
  before_action :set_admin_type_contrat_salarie, only: [:show, :edit, :update, :destroy]

  # GET /admin/type_contrat_salaries
  # GET /admin/type_contrat_salaries.json
  def index
    @admin_type_contrat_salaries = Admin::TypeContratSalarie.all
  end

  # GET /admin/type_contrat_salaries/1
  # GET /admin/type_contrat_salaries/1.json
  def show
    #show
  end

  # GET /admin/type_contrat_salaries/new
  def new
    @admin_type_contrat_salarie = Admin::TypeContratSalarie.new
  end

  # GET /admin/type_contrat_salaries/1/edit
  def edit
    #edit
  end

  # POST /admin/type_contrat_salaries
  # POST /admin/type_contrat_salaries.json
  def create
    @admin_type_contrat_salarie = Admin::TypeContratSalarie.new(admin_type_contrat_salarie_params)

    respond_to do |format|
      if @admin_type_contrat_salarie.save
        format.html { redirect_to @admin_type_contrat_salarie, notice: 'Type contrat salarie was successfully created.' }
        format.json { render :show, status: :created, location: @admin_type_contrat_salarie }
      else
        format.html { render :new }
        format.json { render json: @admin_type_contrat_salarie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/type_contrat_salaries/1
  # PATCH/PUT /admin/type_contrat_salaries/1.json
  def update
    respond_to do |format|
      if @admin_type_contrat_salarie.update(admin_type_contrat_salarie_params)
        format.html { redirect_to @admin_type_contrat_salarie, notice: 'Type contrat salarie was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_type_contrat_salarie }
      else
        format.html { render :edit }
        format.json { render json: @admin_type_contrat_salarie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/type_contrat_salaries/1
  # DELETE /admin/type_contrat_salaries/1.json
  def destroy
    @admin_type_contrat_salarie.destroy
    respond_to do |format|
      format.html { redirect_to admin_type_contrat_salaries_url, notice: 'Type contrat salarie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_type_contrat_salarie
      @admin_type_contrat_salarie = Admin::TypeContratSalarie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_type_contrat_salarie_params
      params.require(:admin_type_contrat_salarie).permit(:code, :description)
    end
end
