class Salarie::CarrieresController < Salarie::ApplicationController
  def index
    @carrieres = current_participant.carrieres.includes(:employeur).order('date_debut_periode_cotisation DESC')

    @total_points = @carrieres.map(&:calcul_points).sum
    exercices = @carrieres.map(&:exercice)
    @annee_debut = exercices.min
    @annee_fin = exercices.max
  end
end
