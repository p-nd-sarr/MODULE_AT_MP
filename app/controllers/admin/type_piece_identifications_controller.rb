class Admin::TypePieceIdentificationsController < ApplicationController
  before_action :set_admin_type_piece_identification, only: [:show, :edit, :update, :destroy]

  # GET /admin/type_piece_identifications
  # GET /admin/type_piece_identifications.json
  def index
    @admin_type_piece_identifications = Admin::TypePieceIdentification.all
  end

  # GET /admin/type_piece_identifications/1
  # GET /admin/type_piece_identifications/1.json
  def show
    #show
  end

  # GET /admin/type_piece_identifications/new
  def new
    @admin_type_piece_identification = Admin::TypePieceIdentification.new
  end

  # GET /admin/type_piece_identifications/1/edit
  def edit
    #edit
  end

  # POST /admin/type_piece_identifications
  # POST /admin/type_piece_identifications.json
  def create
    @admin_type_piece_identification = Admin::TypePieceIdentification.new(admin_type_piece_identification_params)

    respond_to do |format|
      if @admin_type_piece_identification.save
        format.html { redirect_to @admin_type_piece_identification, notice: 'Type piece identification was successfully created.' }
        format.json { render :show, status: :created, location: @admin_type_piece_identification }
      else
        format.html { render :new }
        format.json { render json: @admin_type_piece_identification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/type_piece_identifications/1
  # PATCH/PUT /admin/type_piece_identifications/1.json
  def update
    respond_to do |format|
      if @admin_type_piece_identification.update(admin_type_piece_identification_params)
        format.html { redirect_to @admin_type_piece_identification, notice: 'Type piece identification was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_type_piece_identification }
      else
        format.html { render :edit }
        format.json { render json: @admin_type_piece_identification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/type_piece_identifications/1
  # DELETE /admin/type_piece_identifications/1.json
  def destroy
    @admin_type_piece_identification.destroy
    respond_to do |format|
      format.html { redirect_to admin_type_piece_identifications_url, notice: 'Type piece identification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_type_piece_identification
      @admin_type_piece_identification = Admin::TypePieceIdentification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_type_piece_identification_params
      params.require(:admin_type_piece_identification).permit(:code, :description)
    end
end
