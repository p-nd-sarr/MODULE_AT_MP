class Admin::ConjointsController < Admin::ApplicationController
  before_action :set_conjoint, only: [:show, :edit, :update, :destroy, :valider, :rejeter, :edit_incomplete, :update_incomplete, :set_complete]
  #before_action :can_be_edited?, only: [:update, :edit, :destroy]
  before_action :is_completion_possible?, only: [:set_complete]
  before_action :do_exist?, only: [:set_complete]

  # GET /salarie/conjoints
  # GET /salarie/conjoints.json
  def index
    @q = Conjoint.all.ransack(params[:q])
    @conjoints = @q.result.order('prenom asc').page(params[:page]).per(100)
    #@conjoints = if params[:numero_affiliation]
    #Conjoint.where(numero_affiliation: params[:numero_affiliation]).page(params[:page]).per(100)
    #else
    # Conjoint.all.page(params[:page]).per(100)
    #end
  end

  def valides
    @conjoints = if params[:numero_affiliation]
                   Conjoint.valide.where(numero_affiliation: params[:numero_affiliation], etat_conjoint: :union).page(params[:page]).per(100)
                 else
                   Conjoint.valide.page(params[:page]).per(100)
                 end
    render :index
  end

  def en_attente
    @q = Conjoint.creation.ransack(params[:q])
    @conjoints = @q.result.order('prenom asc').page(params[:page]).per(100)
    render :index
  end

  # GET /salarie/conjoints/1
  # GET /salarie/conjoints/1.json
  def show
    #show
  end

  def valider
    @conjoint.valide!
    flash[:notice] = 'Demande traitée'
    redirect_to admin_conjoints_path
  end

  def rejeter
    @conjoint.rejete!
    flash[:notice] = "Demande traitée"
    redirect_to admin_conjoints_path
  end

  # GET /salarie/conjoints/new
  def new
    @conjoint = Conjoint.new
  end

  # GET /salarie/conjoints/1/edit
  def edit
    @localite_grappes = Admin::LocaliteGrappe.all.order('localite')
  end

  def edit_incomplete
  end

  # POST /salarie/conjoints
  # POST /salarie/conjoints.json
  def create
    @conjoint = Conjoint.new(conjoint_params)
    @conjoint.ajoute_par = current_user
    @conjoint.etat = :valide

    if @conjoint.save
      redirect_to [:admin, @conjoint], notice: 'Conjoint was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /salarie/conjoints/1
  # PATCH/PUT /salarie/conjoints/1.json
  def update
    if DossierPrestation.find_by_conjoint_id(@conjoint.id)
      @conjoint.etat = :soumis
    end
    if @conjoint.update(conjoint_params)
      redirect_to [:admin, @conjoint], notice: 'Conjoint was successfully updated.'
    else
      render :edit
    end
  end

  def update_incomplete
    if @conjoint.update(conjoint_params)
      redirect_to [:admin, @conjoint], notice: 'Conjoint was successfully updated.'
    else
      render :edit_incomplete
    end
  end

  def set_complete
    @conjoint.turn_to_complete!
    redirect_to [:admin, @conjoint], notice: 'Conjoint validé avec succès.'
  end

  # DELETE /salarie/conjoints/1
  # DELETE /salarie/conjoints/1.json
  def destroy
    @conjoint.destroy
    redirect_to admin_conjoints_path, notice: 'Conjoint was successfully destroyed.'
  end

  def listconjoint
    @conjoints = if params[:numero_affiliation]
                   Conjoint.where(numero_affiliation: params[:numero_affiliation]).page(params[:page]).per(100)
                 end
  end

  def listsalaries
    @salarie = Salarie.find_by(matric: params[:numero_affiliation])
  end

  def infos_conjoint
    #@conjoint = Conjoint.find_by(numero_piece: params[:numero_piece])
    @conjoint = if Psrm::Participant.where(numero_piece: params[:numero_piece]).exists?
                  Psrm::Participant.find_by(numero_piece: params[:numero_piece])
                else
                  Conjoint.find_by(numero_piece: params[:numero_piece])
                end
  end

  def active_deces_conjoint
    @conjoint = Conjoint.find(params[:conjoint_id])
    redirect_to new_admin_allocataire_update_grappe_familiale_url(:allocataire_id => params[:id], :id => @conjoint.id, :type => "conjoint", :etat => "deces")
  end

  def active_divorce
    @conjoint = Conjoint.find(params[:conjoint_id])
    redirect_to new_admin_allocataire_update_grappe_familiale_url(:allocataire_id => params[:id], :id => @conjoint.id, :type => "conjoint", :etat => "divorce")
  end

  def infos_salaries
    if Psrm::Participant.where(matric: params[:numero_affiliation]).exists?
      @salarieOrAllocataire = Psrm::Participant.where(matric: params[:numero_affiliation])
      #else
      #@salarieOrAllocataire = Allocataire.where(numero_allocataire: params[:numero_affiliation])
    end
  end

  private

  def do_exist?
    if @conjoint.conjoint_exist?
      flash[:error] = 'Vous ne pouvez pas valider le conjoint : conjoint déjà enregistré pour ce salarié'
      redirect_to [:admin, @conjoint]
    end
  end

  def is_completion_possible?
    unless @conjoint.can_be_completed?
      flash[:error] = 'Vous ne pouvez pas valider le conjoint : merci de completer les informations manquantes'
      redirect_to [:admin, @conjoint]
    end
  end

  def can_be_edited?
    unless @conjoint.can_be_edited?
      flash[:error] = 'Vous ne pouvez pas modifier un supprimer un conjoint déjà validé'
      redirect_back(fallback_location: admin_conjoints_path)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_conjoint
    @conjoint = Conjoint.find(params[:id] || params[:conjoint_id] || params[:numero_piece])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def conjoint_params
    params.require(:conjoint).permit(:user_id, :prenom, :nom, :date_naissance, :date_mariage, :date_etablissement_mariage, :date_jugement_suppletif, :nombre_femmes, :nin, :code_etat_civil,
                                     :extrait_naissance, :certificat_mariage, :certificat_deces, :certificat_divorce, :numero_affiliation, :est_enceinte, :numero_registre,
                                     :est_salarie, :numero_salarie, :type_piece, :numero_piece, :piece_identite, :sex,
                                     :date_delivrance_piece, :date_expiration_piece, :matric_conjoint, :nin_generer,
                                     :prenom_salarie, :nom_salarie, :regime_matrimoniale, :etat_conjoint, :etat_civil, :date_delivrance_piece_salarie,
                                     :rang_conjoint, :date_naissance_salarie, :date_divorce, :date_deces, :date_transcription, :nombre_femmes, :numero_jugement_mariage)
  end
end
