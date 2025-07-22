class Admin::SalariesController < ApplicationController
  before_action :set_salary, only: [:show, :edit, :update]

  def index
    @q = Psrm::Participant.ransack(params[:q])
    @salaries = @q.result.includes(:psrm_employeur).page(params[:page]).per(100)
  end

  def edit
  end

  def update
    respond_to do |format|
      if @salarie.update(salary_params)
        format.html { redirect_to admin_salarie_path(@salarie), notice: 'Le salarié a été modifié avec sucès.' }
        format.json { render :show, status: :ok, location: @salarie }
      else
        format.html { render :edit }
        format.json { render json: @salarie.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    if @salarie and params[:format] != 'json'
      @carrieres = @salarie.carrieres.order('date_debut_periode_cotisation DESC')
      # @declaration_carrieres = @salarie.declaration_carrieres.order('date_debut_periode_cotisation DESC')
      @total_points = @carrieres.map(&:calcul_points).sum #+ @declaration_carrieres.map(&:calcul_points).sum
      exercices = @carrieres.map(&:exercice) #+ @declaration_carrieres.map(&:exercice)
      @annee_debut = exercices.min
      @annee_fin = exercices.max
      @hired_date = @salarie.date_debut_contrat || @carrieres.minimum('date_debut_contrat')
      @q = @salarie.salary_modification_historiques.ransack(params[:q])
      @historique_modifications = @q.result.page(params[:page]).per(5)
    end
  end

  def show_cni
    @salarie = Psrm::Participant.find_by(numero_piece: params[:cni])
  end

  private

  def set_salary
    @matricule = params[:matricule]
    @salarie = Psrm::Participant.find_by(matric: @matricule)
  end

  def salary_params
    params.require(:psrm_participant).permit(:nom, :prenom, :date_naissance, :addr, :phone, :profession, :numero_piece, :genre)
  end
end
