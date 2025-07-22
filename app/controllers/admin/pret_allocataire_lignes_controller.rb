class Admin::PretAllocataireLignesController < Admin::ApplicationController
  before_action :set_allocataire
  before_action :set_pret_allocataire, only: [:show, :edit, :update, :valider]

  def index
    @pret_allocataires = PretAllocataireLigne.where(numero_allocataire: @allocataire.numero_allocataire)
    @pret_en_cours = PretAllocataireLigne.non_rembourses.where(numero_allocataire: @allocataire.numero_allocataire).last
  end

  def edit
    #edit
  end

  def show
    #show
  end

  #region : Workflow Validation REVISION PENSION
  #

  def valider

  end

  def rejeter

  end

  private

  def set_pret_allocataire
    @pret_allocataire = PretAllocataire.find(params[:id])
  end

  def pret_allocataire_params
    params.require(:pret_allocataire).permit(:type_pret, :commentaire)
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id])
  end
end
