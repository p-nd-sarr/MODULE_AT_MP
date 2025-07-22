class Admin::CarrieresController < Admin::ApplicationController
  def index
    @matricule = params[:matricule]
    @allocataire = Allocataire.find_by(numero_allocataire: @matricule)

    if @allocataire.nil?
      redirect_to admin_allocataires_path, alert: "L'allocataire n'existe pas"
      return
    end

    @carrieres = Psrm::Carriere.where(matric: @matricule).includes(:employeur, :participant).order('date_debut_periode_cotisation DESC')
    @total_points = @carrieres.map(&:calcul_points).sum
    exercices = @carrieres.map(&:exercice)
    @annee_debut = exercices.min
    @annee_fin = exercices.max
  end

  def employeur
    @employeur_id = params[:employeur_id]
    @entreprise = Psrm::Employeur.find_by(fhnum: @employeur_id)

    @carrieres = Psrm::Carriere.where(fhnum: @employeur_id).includes(:participant).order('date_debut_periode_cotisation DESC').page(params[:page]).per(100)

    @carrieres_all = Psrm::Carriere.where(fhnum: @employeur_id)
    exercices = @carrieres_all.map(&:exercice)
    @annee_debut = exercices.min
    @annee_fin = exercices.max
  end

  def show
    @carriere = Carriere.find(params[:carriere_id] || params[:id] )
  end

end
