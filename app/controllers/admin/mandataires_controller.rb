class Admin::MandatairesController < ApplicationController

  before_action :set_mandataire, only: [:show, :edit, :update, :destroy]
  before_action :set_employeurs, only: [:new, :edit, :update]

  def index
    @mandataires = Admin::Mandataire.all.order('created_at DESC')
  end

  def show
    #show
  end

  def new
    @mandataire = Admin::Mandataire.new
  end

  def create
    @mandataire = Admin::Mandataire.new(admin_mandataire_params)

    respond_to do |format|
      if @mandataire.save
        format.html { redirect_to admin_mandataires_url, notice: 'Mandataire was successfully created.' }
        format.json { render :show, status: :created, location: @mandataire }
      else
        format.html { render :new }
        format.json { render json: @mandataire.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    #edit
  end

  def destroy
    @mandataire.destroy
    respond_to do |format|
      format.html { redirect_to admin_mandataires_url, notice: 'Mandatary was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def update
    respond_to do |format|

      if @mandataire.update(admin_mandataire_params)
        format.html { redirect_to admin_mandataire_path(@mandataire), notice: 'Mandatary was successfully updated.' }
        format.json { render :show, status: :ok, location: @mandataire }
      else
        format.html { render :edit }
        format.json { render json: @mandataire.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_mandataire
    @mandataire = Admin::Mandataire.find(params[:id])
  end

  private

  def set_employeurs
    @employeurs = Psrm::Employeur.all
  end

  def admin_mandataire_params
    params.require(:admin_mandataire).permit(:nom, :prenom, :numero_employeur, :nin, :telephone, :sexe, :email)
  end

end


