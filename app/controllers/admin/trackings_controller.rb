class Admin::TrackingsController < Admin::ApplicationController
  before_action :set_tracking, only: [:show, :edit, :update, :destroy]

  # GET /trackings
  # GET /trackings.json
  def index
    @trackings = Tracking.all.page(params[:page]).per(100).order('created_at DESC')
  end

  # GET /trackings/1
  # GET /trackings/1.json
  def show
    #show
  end

  # GET /trackings/new
  def new
    @tracking = Tracking.new
  end

  # GET /trackings/1/edit
  def edit
    #edit
  end

  # POST /trackings
  # POST /trackings.json
  def create
    @tracking = Tracking.new(tracking_params)

    respond_to do |format|
      if @tracking.save
        format.html { redirect_to @tracking, notice: 'Tracking was successfully created.' }
        format.json { render :show, status: :created, location: @tracking }
      else
        format.html { render :new }
        format.json { render json: @tracking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trackings/1
  # PATCH/PUT /trackings/1.json
  def update
    respond_to do |format|
      if @tracking.update(tracking_params)
        format.html { redirect_to @tracking, notice: 'Tracking was successfully updated.' }
        format.json { render :show, status: :ok, location: @tracking }
      else
        format.html { render :edit }
        format.json { render json: @tracking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trackings/1
  # DELETE /trackings/1.json
  def destroy
    @tracking.destroy
    respond_to do |format|
      format.html { redirect_to trackings_url, notice: 'Tracking was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tracking
      @tracking = Tracking.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tracking_params
      params.require(:tracking).permit(:user_id, :type_requete, :path, :path_source, :ip, :controller, :action, :contenu)
    end
end
