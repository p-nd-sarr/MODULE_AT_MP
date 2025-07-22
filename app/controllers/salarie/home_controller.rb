class Salarie::HomeController < Salarie::ApplicationController
  def index
    @salarie = current_user
    @carrieres = current_participant.carrieres.includes(:employeur).order('date_debut_periode_cotisation DESC')

    @total_points = @carrieres.map(&:calcul_points).sum
    exercices = @carrieres.map(&:exercice)
    @annee_debut = exercices.min
    @annee_fin = exercices.max
  end

  def show
    @salarie = current_user
    
  end
end