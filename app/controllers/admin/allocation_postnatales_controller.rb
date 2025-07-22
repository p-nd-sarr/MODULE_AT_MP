class Admin::AllocationPostnatalesController < Admin::ApplicationController
  before_action :set_dossier_prestation, except: [:en_attente, :rejeter, :rejeter_create, :index_all, :attente_validation]
  before_action :set_allocation_postnatale, except: [:index, :new, :create, :en_attente, :ajoutee, :index_all]
  before_action :can_valide_operation, only: [:valider, :attente_validation]
  before_action :can_soumettre, only: [:soumettre]
  before_action :check_migrated_allocation, only: %i[ create ]
  after_action :set_num_genere_volet, only: [:soumettre]

  # GET /allocation_postnatales
  # GET /allocation_postnatales.json
  def index
    @allocation_postnatales = @dossier_prestation.allocation_postnatales
    if @dossier_prestation.conjoint.nil?
      @enfants = Enfant.where(numero_affiliation: @dossier_prestation.num_affiliation).not_deleted.not_incomplete
    else
      @enfants = Enfant.where(conjoint_id: @dossier_prestation.conjoint.id).not_deleted.not_incomplete
    end
  end

  def en_attente
    @allocation_postnatales = AllocationPostnatale.en_attente.page(params[:page]).per(100)
  end

  def index_all
    @allocation_postnatales = AllocationPostnatale.visible_for_admins.page(params[:page]).per(100)
  end

  def valider
    if @allocation_postnatale.dossier_prestation.valide?
      @allocation_postnatale.etat = :valide
      @allocation_postnatale.traite_par = current_user
      @allocation_postnatale.traite_le = DateTime.now
      @allocation_postnatale.date_validation = DateTime.now
      @allocation_postnatale.motif_retour_volet = nil
      @allocation_postnatale.retourne_par_id = nil
      @allocation_postnatale.date_retour = nil
      @allocation_postnatale.save
      flash[:notice] = 'Prestation validée.'
      redirect_to [:admin, @dossier_prestation, @allocation_postnatale]
    else
      flash[:error] = 'Une erreur est survenue lors du traitement. ', @allocation_postnatale.errors.full_messages
      redirect_to [:admin, @dossier_prestation, @allocation_postnatale]
    end
  end

  def attente_validation
    @allocation_postnatale.etat = :valide
    @allocation_postnatale.traite_par = current_user
    @allocation_postnatale.traite_le = DateTime.now
    @allocation_postnatale.date_validation = DateTime.now
    @allocation_postnatale.save
    flash[:notice] = 'Prestation postnatale validée.'
    redirect_to allocation_en_attente_admin_dossier_prestations_path
  end

  def rejeter; end

  def rejeter_create
    if @allocation_postnatale.update(allocation_postnatale_rejet_params.merge(etat: :rejete,
                                                                              traite_par: current_user,
                                                                              traite_le: DateTime.now))
      redirect_to en_attente_admin_allocation_postnatales_path, notice: 'Deamande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def allocation_postnatale_rejet_params
    params.require(:allocation_postnatale).permit(:motif_rejet)
  end

  # GET /allocation_postnatales/1
  # GET /allocation_postnatales/1.json
  def show
    #show
  end

  # GET /allocation_postnatales/new
  def new
    @allocation_postnatale = AllocationPostnatale.new
    @enfant = @dossier_prestation.enfants.find(params[:enfant_id])
  end

  # GET /allocation_postnatales/1/edit
  def edit
    @enfant = @allocation_postnatale.enfant
  end

  # POST /allocation_postnatales
  # POST /allocation_postnatales.json
  def create
    @allocation_postnatale = AllocationPostnatale.new(allocation_postnatale_params)
    @allocation_postnatale.dossier_prestation = @dossier_prestation
    #@allocation_postnatale.user = @dossier_prestation.user
    @allocation_postnatale.ajoute_par = current_user
    @allocation_postnatale.etat = :creation

    respond_to do |format|
      if @allocation_postnatale.save
        format.html { redirect_to [:admin, @dossier_prestation, @allocation_postnatale], notice: 'Création allocation postnatale faite avec succés.' }
        format.json { render :show, status: :created, location: @allocation_postnatale }
      else
        format.html { render :new }
        format.json { render json: @allocation_postnatale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /allocation_postnatales/1
  # PATCH/PUT /allocation_postnatales/1.json
  def update
    respond_to do |format|
      if @allocation_postnatale.update(allocation_postnatale_params)
        format.html { redirect_to [:admin, @dossier_prestation, @allocation_postnatale], notice: 'Allocation postnatale bien modifiée.' }
        format.json { render :show, status: :ok, location: @allocation_postnatale }
      else
        format.html { render :edit }
        format.json { render json: @allocation_postnatale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /allocation_postnatales/1
  # DELETE /allocation_postnatales/1.json
  def destroy
    @allocation_postnatale.destroy
    respond_to do |format|
      format.html { redirect_to admin_dossier_prestation_allocation_postnatales_path(@dossier_prestation), notice: 'Allocation postnatale  bien supprimée.' }
      format.json { head :no_content }
    end
  end

  def soumettre
    if @allocation_postnatale.update(etat: :soumis, date_soumission: Date.today, motif_retour_volet: nil, retourne_par: nil, date_retour: nil)
      redirect_to [:admin, @dossier_prestation, @allocation_postnatale], notice: "La demande d'allocation a été liquidée avec succès."
    else
      flash[:error] = "Une erreur est survenue lors du traitement. ", @allocation_postnatale.errors.full_messages
      redirect_to [:admin, @dossier_prestation, @allocation_postnatale]
    end
  end

  def soumission_form; end

  def retour
    @allocation_postnatale = AllocationPostnatale.find(params[:id] || params[:allocation_postnatale_id])
  end

  def retour_volet
    if @allocation_postnatale.soumis?
      @allocation_postnatale.update(allocation_postnatale_retour_volet_params.merge(date_liquidation: nil, date_soumission: nil,
                                                                                    retourne_par: current_user,
                                                                                    date_retour: DateTime.now))
      @allocation_postnatale.creation!

    else
      if @allocation_postnatale.valide?
        @allocation_postnatale.update(allocation_postnatale_retour_volet_params.merge(date_validation: nil, date_soumission: nil,
                                                                                      retourne_par: current_user,
                                                                                      date_retour: DateTime.now))
        @allocation_postnatale.soumis!
      end

      redirect_to [:admin, @dossier_prestation, @allocation_postnatale], notice: 'Le volet à été retourné avec succés.'
    end
  end

  private

  def check_migrated_allocation
    enfant = Enfant.find(params['allocation_postnatale']['enfant_id'])
    volet = params['allocation_postnatale']['volet']
    migrated_allocation = enfant.allocations_postnatales_migrees.where.not(enfant_id: nil).find_by(volet: AllocationPostnatale.volets[volet])
    unless migrated_allocation.nil?
      flash[:error] = "Cette allocation existe déjà dans l'historique des allocations migrées !."
      redirect_to admin_dossier_prestation_allocation_postnatales_path(@dossier_prestation)
    end
  end

  def set_num_genere_volet
    annee = Date.today.year
    if @allocation_postnatale.num_volet_generer.nil?
      @allocation_postnatale.num_volet_generer = params[:dossier_prestation_id] + "/" + params[:allocation_postnatale_id] + "/" + "#{annee}/DOSSALPOS0001"
      @allocation_postnatale.save
    end
  end

  def can_soumettre
    migrated_allocation = @allocation_postnatale.enfant.allocations_postnatales_migrees.where.not(enfant_id: nil).find_by(volet: @allocation_postnatale.read_attribute_before_type_cast(:volet))
    date_ref = @allocation_postnatale.date_accouchement + if @allocation_postnatale.volet4?
                                                            0.months
                                                          elsif @allocation_postnatale.volet5?
                                                            6.months
                                                          elsif @allocation_postnatale.volet6?
                                                            12.months
                                                          elsif @allocation_postnatale.volet7?
                                                            18.months
                                                          elsif @allocation_postnatale.volet8?
                                                            24.months
                                                          end
    unless migrated_allocation.nil?
      flash[:error] = "Cette allocation a déjà été payée dans progress"
      redirect_to admin_dossier_prestation_allocation_postnatales_path
      return
    end
    if not @allocation_postnatale.dossier_prestation.pret_pour_soumission_pre_post_natal?
      flash[:error] = "Vous ne pouvez pas encore liquider cette prestation. Création dossier pas encore complet."
      redirect_to admin_dossier_prestation_allocation_postnatales_path
    elsif current_user.admin_agence.id != @allocation_postnatale.ajoute_par.admin_agence.id
      flash[:error] = "Vous ne pouvez pas liquider cette prestation. Vous n'êtes pas abilité"
      redirect_to admin_dossier_prestation_allocation_postnatales_path
    elsif @allocation_postnatale.dossier_prestation.date_ouverture > date_ref
      flash[:error] = "Ce volet est invalide : antérieur à la date d'ouverture des droits."
      redirect_to admin_dossier_prestation_allocation_postnatales_path
    elsif not (@allocation_postnatale.date_reception.between?(date_ref.beginning_of_month, (date_ref + 12.months).end_of_month))
      flash[:error] = "Date de réception invalide : PRESCRIPTION !"
      redirect_to admin_dossier_prestation_allocation_postnatales_path
    end
  end

  def can_valide_operation
    migrated_allocation = @allocation_postnatale.enfant.allocations_postnatales_migrees.where.not(enfant_id: nil).find_by(volet: @allocation_postnatale.read_attribute_before_type_cast(:volet))
    unless migrated_allocation.nil?
      flash[:error] = "Cette allocation a déjà été payée dans progress"
      redirect_to admin_dossier_prestation_allocation_postnatales_path
      return
    end
    unless current_user.admin_agence.id == @allocation_postnatale.ajoute_par.admin_agence.id
      flash[:error] = "Vous ne pouvez pas valider cette prestation. Vous n'êtes pas abilité."
      redirect_to admin_dossier_prestation_allocation_postnatales_path
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_allocation_postnatale
    @allocation_postnatale = AllocationPostnatale.find(params[:id] || params[:allocation_postnatale_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def allocation_postnatale_params
    params.require(:allocation_postnatale).permit(:date_accouchement, :volet, :commentaire, :document, :enfant_id, :date_visite_1, :date_visite_2,
                                                  :date_visite_3, :date_etablissement, :date_depot, :num_volet_generer, :date_reception, :date_enregistrement)
  end

  def set_dossier_prestation
    @dossier_prestation = DossierPrestation.find(params[:dossier_prestation_id])
  end

  def soumission_allocation_postnatale_params
    # params.require(:allocation_postnatale).permit(:condition_1, :condition_2, :condition_3)
  end

  def allocation_postnatale_retour_volet_params
    params.require(:allocation_postnatale).permit(:motif_retour_volet)
  end
end
