class Admin::RegBeneficiariesController < ApplicationController
  before_action :set_admin_reg_beneficiary, only: [:show, :edit, :update, :destroy]

  # GET /admin/reg_beneficiaries
  # GET /admin/reg_beneficiaries.json
  def index
    @admin_reg_beneficiaries = Admin::RegBeneficiary.all
  end

  # GET /admin/reg_beneficiaries/1
  # GET /admin/reg_beneficiaries/1.json
  def show
  end

  # GET /admin/reg_beneficiaries/new
  def new
    @admin_reg_beneficiary = Admin::RegBeneficiary.new
  end

  # GET /admin/reg_beneficiaries/1/edit
  def edit
  end

  # POST /admin/reg_beneficiaries
  # POST /admin/reg_beneficiaries.json
  def create
    @admin_reg_beneficiary = Admin::RegBeneficiary.new(admin_reg_beneficiary_params)

    respond_to do |format|
      if @admin_reg_beneficiary.save
        format.html { redirect_to @admin_reg_beneficiary, notice: 'Reg beneficiary was successfully created.' }
        format.json { render :show, status: :created, location: @admin_reg_beneficiary }
      else
        format.html { render :new }
        format.json { render json: @admin_reg_beneficiary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/reg_beneficiaries/1
  # PATCH/PUT /admin/reg_beneficiaries/1.json
  def update
    respond_to do |format|
      if @admin_reg_beneficiary.update(admin_reg_beneficiary_params)
        format.html { redirect_to @admin_reg_beneficiary, notice: 'Reg beneficiary was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_reg_beneficiary }
      else
        format.html { render :edit }
        format.json { render json: @admin_reg_beneficiary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/reg_beneficiaries/1
  # DELETE /admin/reg_beneficiaries/1.json
  def destroy
    @admin_reg_beneficiary.destroy
    respond_to do |format|
      format.html { redirect_to admin_reg_beneficiaries_url, notice: 'Reg beneficiary was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_admin_reg_beneficiary
    @admin_reg_beneficiary = Admin::RegBeneficiary.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_reg_beneficiary_params
    params.fetch(:admin_reg_beneficiary, {})
  end
end
