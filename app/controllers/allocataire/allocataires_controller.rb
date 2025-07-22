class Allocataire::AllocatairesController < Allocataire::ApplicationController

  def index
    
    @allocataire = Allocataire.all
  end

  def new
    @allocataire = Allocataire.new
  end

  def show
    
    @allocataire = Allocataire.find(params[:id])
  end

  def create

  end

end