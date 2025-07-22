class Admin::EnfantsController < Admin::ApplicationController
  before_action :set_enfant, only: [:edit, :update, :destroy, :show, :valider, :rejeter, :edit_incomplete, :update_incomplete, :set_complete]
  #before_action :can_be_edited?, only: [:edit, :destroy, :update]
  before_action :is_completion_possible?, only: [:set_complete]
  before_action :do_exist?, only: [:set_complete]

  def index
    @q = Enfant.all.ransack(params[:q])
    @enfants = @q.result.includes(:conjoint).order('prenom asc').page(params[:page]).per(100)
  end

  def en_attente
    @q = Enfant.creation.ransack(params[:q])
    @enfants = @q.result.order('prenom asc').page(params[:page]).per(100)
    render :index
  end

  def show
    #show
  end

  def valider
    @enfant.valide!
    flash[:notice] = 'Demande traitée'
    redirect_to admin_enfants_path
  end

  def rejeter
    @enfant.rejete!
    flash[:notice] = "Demande traitée"
    redirect_to admin_enfants_path
  end

  def new
    @enfant = Enfant.new
  end

  def edit
    @conjoints = Conjoint.where(id: @enfant.conjoint)
  end

  def edit_enfant
    @enfant = Enfant.find_by(numero_affiliation: params[:numero_affiliation])
    @conjoints = Conjoint.where(numero_affiliation: params[:numero_affiliation])
    @localite_grappes = Admin::LocaliteGrappe.all.order('localite')
  end

  def edit_incomplete
  end

  def create
    @enfant = Enfant.new(enfant_params)
    @enfant.ajoute_par = current_user
    @enfant.etat = :valide

    if @enfant.save
      redirect_to [:admin, @enfant], notice: 'Enfant was successfully created.'
    else
      render :new
    end
  end

  def update
    if DossierPrestation.find_by_conjoint_id(@enfant.id)
      @enfant.etat = :soumis
    end
    if @enfant.update(enfant_params)
      redirect_to [:admin, @enfant], notice: 'Enfant was successfully updated.'
    else
      render :edit
    end
  end

  def update_incomplete
    if @enfant.update(enfant_params)
      redirect_to [:admin, @enfant], notice: 'Enfant was successfully updated.'
    else
      render :edit_incomplete
    end
  end

  def set_complete
    @enfant.turn_to_complete!
    redirect_to [:admin, @enfant], notice: 'Enfant validé avec succès.'
  end

  def destroy
    @enfant.destroy
    redirect_to admin_enfants_path, notice: 'Enfant was successfully destroyed.'
  end

  def active_deces
    @enfant = Enfant.find(params[:enfant_id])
    redirect_to new_admin_allocataire_update_grappe_familiale_url(:allocataire_id => params[:id], :id => @enfant.id, :type => "enfant", :etat => "deces")
  end

  def listenfant
    @enfants = if params[:numero_affiliation]
                 Enfant.where(numero_affiliation: params[:numero_affiliation]).page(params[:page]).per(100)
               end
  end

  private

  def do_exist?
    if @enfant.enfant_exist?
      flash[:error] = "Vous ne pouvez pas valider l'enfant : enfant déjà enregistré pour ce salarié"
      redirect_to [:admin, @enfant]
    end
  end

  def is_completion_possible?
    unless @enfant.can_be_completed?
      flash[:error] = "Vous ne pouvez pas valider l'enfant : merci de completer les informations manquantes"
      redirect_to [:admin, @enfant]
    end
  end

  def can_be_edited?
    unless @enfant.can_be_edited?
      flash[:error] = 'Vous ne pouvez pas modifier un enfant déjà validé'
      redirect_back(fallback_location: admin_enfants_path)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_enfant
    @enfant = Enfant.find(params[:id] || params[:enfant_id] || params[:numero_affiliation])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def enfant_params
    params.require(:enfant).permit(:prenom, :nom, :date_naissance, :nom_salarie, :prenom_salarie, :sexe, :code_etat_civil, :numero_registre,
                                   :full_name_conjoint, :extrait_naissance, :numero_affiliation, :nom_mere, :prenom_mere, :nom_pere, :date_delivrance_piece,
                                   :prenom_pere, :origine_enfant, :type_piece, :numero_piece, :conjoint_id, :nom_mere_naturel, :prenom_mere_naturel, :nin_generer, :lieu_naissance, :date_transcription)
  end
end
