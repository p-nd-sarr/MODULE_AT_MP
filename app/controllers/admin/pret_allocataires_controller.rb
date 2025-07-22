class Admin::PretAllocatairesController < Admin::ApplicationController

  #before_action :set_allocataire
  before_action :set_pret_allocataire, only: [:show, :edit, :update, :valider]

  def index
    @pret_allocataires = PretAllocataire.all.order(created_at: :desc)
  end

  def edit
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaire
  end

  def new
    @pret_allocataire = PretAllocataire.new
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaire
  end

  def show
    @pret_allocataire_lignes = @pret_allocataire.pret_allocataire_lignes.page(params[:page]).per(100)
  end

  def create
    @pret_allocataire = PretAllocataire.new(pret_allocataire_params)
    # @pret_allocataire.allocataire = @allocataire
    @pret_allocataire.ajouter_par = current_user
    @pret_allocataire.etat = :creation

    respond_to do |format|
      if @pret_allocataire.save
        format.html { redirect_to [:admin, @allocataire, @pret_allocataire], notice: 'Pret pour les allocataires créé avec succès.' }
        format.json { render :show, status: :created, location: @pret_allocataire }
      else
        format.html { render :new }
        format.json { render json: @pret_allocataire.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @pret_allocataire.update(pret_allocataire_params)
      redirect_to [:admin, @allocataire, @pret_allocataire], notice: 'La demande de révision est bien mise à jour.'
    else
      render :edit
    end
  end

#region : Workflow Validation REVISION PENSION
#


  def valider
    if @pret_allocataire.creation?
      @pret_allocataire.etat= :valider
      @pret_allocataire.valider_par = current_user
      @pret_allocataire.validation_date = DateTime.now
      @pret_allocataire.save
      redirect_to [:admin, @allocataire, @pret_allocataire], notice: 'Demande de pret valider'
    else
      redirect_to [:admin, @allocataire, @pret_allocataire]
    end
  end

  def rejeter
    if @pret_allocataire.creation?
      @pret_allocataire.etat = :rejeter
      @pret_allocataire.valider_par = current_user
      @pret_allocataire.validation_date = DateTime.now
      @pret_allocataire.save
      redirect_to [:admin, @allocataire, @pret_allocataire], notice: 'Demande de pret rejeter'
    else
      redirect_to [:admin, @allocataire, @pret_allocataire]
    end
  end

  def en_attente_validation
    @pret_allocataires = PretAllocataire.creation
  end

  private
  def set_pret_allocataire
    @pret_allocataire = PretAllocataire.find(params[:id] || params[:pret_allocataire_id])
  end

  def pret_allocataire_params
    params.require(:pret_allocataire).permit(:type_pret, :commentaire)
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id])
  end


end
