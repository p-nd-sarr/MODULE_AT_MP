class Allocataire::HomeController < Allocataire::ApplicationController
  def index
    @allocataire = current_user.allocataire
    @conjoints = current_user.conjoints
    @enfants = current_user.enfants
    #@demande_liquidation = current_participant.liquidatation_retraites
    unless current_participant.nil?
      @carrieres = current_participant.carrieres.includes(:employeur).order('date_debut_periode_cotisation DESC')
      @total_points = @carrieres.map(&:calcul_points).sum
      exercices = @carrieres.map(&:exercice)
      @annee_debut = exercices.min
      @annee_fin = exercices.max
    end
  end
  def recap_points
    @allocataire = current_user.allocataire
  end
end
