class Admin::ConventionCollectivesController < Admin::ApplicationController
  before_action :only_admin!
  before_action :set_admin_convention_collective, only: [:show, :edit, :update, :destroy]

  # GET /admin/convention_collectives
  # GET /admin/convention_collectives.json
  def index
    @admin_convention_collectives = Admin::ConventionCollective.all
  end

  # GET /admin/convention_collectives/1
  # GET /admin/convention_collectives/1.json
  def show
    #show
  end

  # GET /admin/convention_collectives/new
  def new
    @admin_convention_collective = Admin::ConventionCollective.new
  end

  # GET /admin/convention_collectives/1/edit
  def edit
    #edit
  end

  # POST /admin/convention_collectives
  # POST /admin/convention_collectives.json
  def create
    @admin_convention_collective = Admin::ConventionCollective.new(admin_convention_collective_params)

    respond_to do |format|
      if @admin_convention_collective.save
        format.html { redirect_to @admin_convention_collective, notice: 'Convention collective was successfully created.' }
        format.json { render :show, status: :created, location: @admin_convention_collective }
      else
        format.html { render :new }
        format.json { render json: @admin_convention_collective.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/convention_collectives/1
  # PATCH/PUT /admin/convention_collectives/1.json
  def update
    respond_to do |format|
      if @admin_convention_collective.update(admin_convention_collective_params)
        format.html { redirect_to @admin_convention_collective, notice: 'Convention collective was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_convention_collective }
      else
        format.html { render :edit }
        format.json { render json: @admin_convention_collective.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/convention_collectives/1
  # DELETE /admin/convention_collectives/1.json
  def destroy
    @admin_convention_collective.destroy
    respond_to do |format|
      format.html { redirect_to admin_convention_collectives_url, notice: 'Convention collective was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_convention_collective
      @admin_convention_collective = Admin::ConventionCollective.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_convention_collective_params
      params.require(:admin_convention_collective).permit(:code, :description)
    end
end
