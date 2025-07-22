class Admin::BanquesController < ApplicationController
  before_action :set_admin_banque, only: [:show, :edit, :update, :destroy]

  # GET /admin/banques
  # GET /admin/banques.json
  def index
    @admin_banques = Admin::Banque.all
  end

  # GET /admin/banques/1
  # GET /admin/banques/1.json
  def show
    #show
  end

  # GET /admin/banques/new
  def new
    @admin_banque = Admin::Banque.new
  end

  # GET /admin/banques/1/edit
  def edit
    #edit
  end

  # POST /admin/banques
  # POST /admin/banques.json
  def create
    @admin_banque = Admin::Banque.new(admin_banque_params)

    respond_to do |format|
      if @admin_banque.save
        format.html { redirect_to @admin_banque, notice: 'Banque was successfully created.' }
        format.json { render :show, status: :created, location: @admin_banque }
      else
        format.html { render :new }
        format.json { render json: @admin_banque.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/banques/1
  # PATCH/PUT /admin/banques/1.json
  def update
    respond_to do |format|
      if @admin_banque.update(admin_banque_params)
        format.html { redirect_to @admin_banque, notice: 'Banque was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_banque }
      else
        format.html { render :edit }
        format.json { render json: @admin_banque.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/banques/1
  # DELETE /admin/banques/1.json
  def destroy
    @admin_banque.destroy
    respond_to do |format|
      format.html { redirect_to admin_banques_url, notice: 'Banque was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_banque
      @admin_banque = Admin::Banque.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_banque_params
      params.require(:admin_banque).permit(:code, :nom, :actif, :code_swift, :bank_id)
    end
end
