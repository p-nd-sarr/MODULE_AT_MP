class Admin::AscendantsSalariesController < ApplicationController
  before_action :set_ascendants_salary, only: [:show, :edit, :update, :destroy]

  # GET /ascendants_salaries
  # GET /ascendants_salaries.json
  def index
    @ascendants_salaries = AscendantsSalarie.all
  end

  # GET /ascendants_salaries/1
  # GET /ascendants_salaries/1.json
  def show
    #show
  end

  # GET /ascendants_salaries/new
  def new
    @ascendants_salary = AscendantsSalarie.new
  end

  # GET /ascendants_salaries/1/edit
  def edit
    #edit
  end

  # POST /ascendants_salaries
  # POST /ascendants_salaries.json
  def create
    @ascendants_salary = AscendantsSalarie.new(ascendants_salary_params)
    @ascendants_salary.user_id = current_user

    if @ascendants_salary.save
      redirect_to [:admin, @ascendants_salary], notice: 'Ascendants salarie was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /ascendants_salaries/1
  # PATCH/PUT /ascendants_salaries/1.json
  def update
      if @ascendants_salary.update(ascendants_salary_params)
        redirect_to [:admin, @ascendants_salary], notice: 'Ascendants salarie was successfully created.'
      else
        render :edit
      end
  end

  # DELETE /ascendants_salaries/1
  # DELETE /ascendants_salaries/1.json
  def destroy
    @ascendants_salary.destroy
    respond_to do |format|
      format.html { redirect_to admin_ascendants_salaries_url, notice: 'Ascendants salarie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def listascendant
     @ascendants_salaries = if params[:numero_affiliation]
                              AscendantsSalarie.where(numero_affiliation: params[:numero_affiliation])
                            end
      render json: @ascendants_salaries
    puts "DATA:",@ascendants_salaries.inspect
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ascendants_salary
      @ascendants_salary = AscendantsSalarie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ascendants_salary_params
      params.require(:ascendants_salarie).permit(:user_id, :numero_affiliation, :nom_salarie, :prenom_salarie,
                                               :nom_mere, :prenom_mere, :date_naissance_mere, :numero_piece_mere, :type_piece_mere, :piece_mere,
                                               :nom_pere, :prenom_pere, :date_naissance_pere, :numero_piece_pere, :type_piece_pere, :piece_pere, :date_naissance_salarie
                                               )
    end
end
