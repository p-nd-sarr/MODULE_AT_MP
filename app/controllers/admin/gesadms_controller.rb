class Admin::GesadmsController < ApplicationController
  before_action :set_admin_gesadm, only: [:show, :edit, :update, :destroy]

  # GET /admin/gesadms
  # GET /admin/gesadms.json
  def index
    #@admin_gesadms = Admin::Gesadm.all
    @q = Admin::Gesadm.ransack(params[:q])
    @admin_gesadms = @q.result.page(params[:page]).per(100)
  end

  # GET /admin/gesadms/1
  # GET /admin/gesadms/1.json
  def show
  end

  # GET /admin/gesadms/new
  def new
    @admin_gesadm = Admin::Gesadm.new
  end

  # GET /admin/gesadms/1/edit
  def edit
  end

  # POST /admin/gesadms
  # POST /admin/gesadms.json
  def create
    @admin_gesadm = Admin::Gesadm.new(admin_gesadm_params)

    respond_to do |format|
      if @admin_gesadm.save
        format.html { redirect_to @admin_gesadm, notice: 'Gesadm was successfully created.' }
        format.json { render :show, status: :created, location: @admin_gesadm }
      else
        format.html { render :new }
        format.json { render json: @admin_gesadm.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/gesadms/1
  # PATCH/PUT /admin/gesadms/1.json
  def update
    respond_to do |format|
      if @admin_gesadm.update(admin_gesadm_params)
        format.html { redirect_to @admin_gesadm, notice: 'Gesadm was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_gesadm }
      else
        format.html { render :edit }
        format.json { render json: @admin_gesadm.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/gesadms/1
  # DELETE /admin/gesadms/1.json
  def destroy
    @admin_gesadm.destroy
    respond_to do |format|
      format.html { redirect_to admin_gesadms_url, notice: 'Gesadm was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_gesadm
      @admin_gesadm = Admin::Gesadm.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_gesadm_params
      params.require(:admin_gesadm).permit(:MATRICULE, :PRENOM, :NOM, :NAISSLIEU, :SALAIRE,:SALAIRE, :COTISAT, :RESTE, :NAISSMM, :NAISSAA, :SEXE, :NATION, :EMPLOI,
                                            :PECMM, :PECAA, :SITUAT, :JJPOS, :CDQVNB,:CDQWNB, :CDDXNB,:CDEETAB, :CDECARTE, :CDBLNB,:CDBKNB )
    end
        
end
