class Admin::AllocationPrenatalesController < Admin::ApplicationController
  before_action :set_dossier_prestation, except: [:en_attente, :valider, :rejeter, :rejeter_create, :index_all, :attente_validation]
  before_action :set_allocation_prenatale, except: [:index, :new, :create, :en_attente, :ajoutee, :index_all]
  before_action :can_valide_operation, only: [:valider, :attente_validation]
  before_action :can_soumettre, only: [:soumettre]
  before_action :check_migrated_allocation, only: %i[ create ]
  after_action :set_num_genere_volet, only: [:soumettre]

  # GET /allocation_prenatales
  # GET /allocation_prenatales.json
  def index
    @allocation_prenatales = @dossier_prestation.allocation_prenatales
  end

  def en_attente
    @allocation_prenatales = AllocationPrenatale.en_attente.page(params[:page]).per(100)
  end

  def index_all
    @allocation_prenatales = AllocationPrenatale.visible_for_admins.page(params[:page]).per(100)
  end

  def valider
    if @allocation_prenatale.dossier_prestation.valide?
      @allocation_prenatale.etat = :valide
      @allocation_prenatale.traite_par = current_user
      @allocation_prenatale.traite_le = DateTime.now
      @allocation_prenatale.date_validation = DateTime.now
      @allocation_prenatale.save
      flash[:notice] = 'Prestation prénatale validée.'
      redirect_to admin_dossier_prestation_allocation_prenatales_path(@allocation_prenatale.dossier_prestation)
    else
      flash[:error] = 'Vous devez valider le dossier avant de valider les prestations.'
      redirect_to admin_dossier_prestation_allocation_prenatales_path(@allocation_prenatale.dossier_prestation)
    end
  end

  def attente_validation
      @allocation_prenatale.etat = :valide
      @allocation_prenatale.traite_par = current_user
      @allocation_prenatale.traite_le = DateTime.now
      @allocation_prenatale.date_validation = DateTime.now
      @allocation_prenatale.save
      flash[:notice] = 'Prestation prénatale validée.'
      redirect_to allocation_en_attente_admin_dossier_prestations_path
  end

  def retour
    @allocation_prenatale = AllocationPrenatale.find(params[:id] || params[:allocation_prenatale_id])
  end

  def retour_volet
    if @allocation_prenatale.soumis?
      @allocation_prenatale.update(allocation_prenatale_retour_volet_params.merge(date_liquidation: nil, date_soumission: nil))
      @allocation_prenatale.creation!

      redirect_to admin_dossier_prestation_allocation_prenatales_path(@allocation_prenatale.dossier_prestation), notice: 'Le volet à été retourné avec succés.'
    else
      if @allocation_prenatale.valide?
        @allocation_prenatale.update(allocation_prenatale_retour_volet_params.merge(date_validation: nil, date_soumission: Date.today))
        @allocation_prenatale.soumis!

        redirect_to admin_dossier_prestation_allocation_prenatales_path(@allocation_prenatale.dossier_prestation), notice: 'Le volet à été retourné avec succés.'
      end
    end
  end

  def rejeter
    @allocation_prenatale.rejete!
    @allocation_prenatale.traite_par = current_user
    @allocation_prenatale.traite_le = DateTime.now
    @allocation_prenatale.date_rejet = Date.today
    @allocation_prenatale.save
    flash[:notice] = 'Prestation rejetée'
    redirect_to admin_dossier_prestation_allocation_prenatales_path(@allocation_prenatale.dossier_prestation)

  end

  def rejeter_create
    if @allocation_prenatale.update(allocation_prenatale_rejet_params.merge(etat: :rejete,
                                                                            traite_par: current_user,
                                                                            traite_le: DateTime.now))
      redirect_to en_attente_admin_allocation_prenatales_path, notice: 'Deamande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def rejet_volet
    @allocation_prenatale = AllocationPrenatale.new(id: params[:allocation_prenatale_id])
  end

  def motif_rejet
    if @allocation_prenatale.update(allocation_prenatale_rejet_params.merge(etat: :rejete,
                                                                            traite_par: current_user,
                                                                            traite_le: DateTime.now))
      redirect_to admin_dossier_prestation_allocation_prenatales_path(@allocation_prenatale.dossier_prestation), notice: 'Deamande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def allocation_prenatale_rejet_params
    params.require(:allocation_prenatale).permit(:motif_rejet)
    end

  def allocation_prenatale_retour_volet_params
    params.require(:allocation_prenatale).permit(:motif_retour_volet)
  end


  # GET /allocation_prenatales/1
  # GET /allocation_prenatales/1.json
  def show
    #show
  end

  # GET /allocation_prenatales/new
  def new
    @allocation_prenatale = AllocationPrenatale.new
    @grossesse = @dossier_prestation.grossesses.find(params[:grossesse_id])
  end

  # GET /allocation_prenatales/1/edit
  def edit
    # @grossesse = @allocation_prenatale.grossesse
  end

  # POST /allocation_prenatales
  # POST /allocation_prenatales.json
  def create
    @allocation_prenatale = AllocationPrenatale.new(allocation_prenatale_params)
    @allocation_prenatale.dossier_prestation = @dossier_prestation
    @allocation_prenatale.user = @dossier_prestation.user
    @allocation_prenatale.ajoute_par = current_user
    @allocation_prenatale.etat = :creation

    respond_to do |format|
      if @allocation_prenatale.save
        format.html { redirect_to [:admin, @dossier_prestation, @allocation_prenatale], notice: 'Création allocation prenatale faite avec succés.' }
        format.json { render :show, status: :created, location: @allocation_prenatale }
      else
        puts @allocation_prenatale.errors.messages
        @grossesse = @dossier_prestation.grossesses.find(@allocation_prenatale.grossesse_id)
        format.html { render :new }
        format.json { render json: @allocation_prenatale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /allocation_prenatales/1
  # PATCH/PUT /allocation_prenatales/1.json
  def update
    respond_to do |format|
      if @allocation_prenatale.update(allocation_prenatale_params)
        format.html { redirect_to [:admin, @dossier_prestation, @allocation_prenatale], notice: 'Allocation prenatale bien modifiée.' }
        format.json { render :show, status: :ok, location: @allocation_prenatale }
      else
        format.html { render :edit }
        format.json { render json: @allocation_prenatale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /allocation_prenatales/1
  # DELETE /allocation_prenatales/1.json
  def destroy
    @allocation_prenatale.destroy
    respond_to do |format|
      format.html { redirect_to admin_dossier_prestation_allocation_prenatales_path(@dossier_prestation), notice: 'Allocation prenatale bien supprimée.' }
      format.json { head :no_content }
    end
  end

  def soumettre
    if @allocation_prenatale.update(etat: :soumis, date_soumission: Date.today)
      redirect_to admin_dossier_prestation_allocation_prenatales_path(@dossier_prestation), notice: "La demande d'allocation est liquidée."
    else
      render :soumission_form
    end
  end

  def soumission_form; end

  private

  def check_migrated_allocation
    date_visite = params['allocation_prenatale']['date_visite']
    volet = params['allocation_prenatale']['volet']
    migrated_allocation = AllocationsPrenatalesMigree.find_by(volet: AllocationPrenatale.volets[volet], date_visite: date_visite.to_date, dossier_prestation_id: @dossier_prestation.num_dossier)

    unless migrated_allocation.nil?
      flash[:error] = "Cette allocation existe déjà dans l'historique des allocations migrées !."
      redirect_to admin_dossier_prestation_allocation_prenatales_path(@dossier_prestation)
    end
  end

  def set_num_genere_volet
    annee = Date.today.year
    if @allocation_prenatale.num_volet_generer.nil?
      @allocation_prenatale.num_volet_generer = params[:dossier_prestation_id] + "/" + params[:allocation_prenatale_id] + "/" + "#{annee}/DOSSALPRE0001"
      @allocation_prenatale.save
    end
  end

  def can_soumettre
    dossier = @allocation_prenatale.dossier_prestation
    if dossier.feminin?
      migrated_allocation = @allocation_prenatale.dossier_prestation.allocations_prenatales_migrees.find_by(volet: @allocation_prenatale.read_attribute_before_type_cast(:volet), date_visite: @allocation_prenatale.date_visite)
    else
      migrated_allocation = @allocation_prenatale.dossier_prestation.allocations_prenatales_migrees.find_by(volet: @allocation_prenatale.read_attribute_before_type_cast(:volet), conjoint_id: @allocation_prenatale.dossier_prestation.conjoint.old_conjoint_id, date_visite: @allocation_prenatale.date_visite)
    end
    date_ref = @allocation_prenatale.grossesse.date_grossesse + if @allocation_prenatale.volet1?
                                                                  3.months
                                                                elsif @allocation_prenatale.volet2?
                                                                  6.months
                                                                elsif @allocation_prenatale.volet3?
                                                                  8.months
                                                                end
    unless migrated_allocation.nil?
      flash[:error] = "Cette allocation a déjà été payée dans progress"
      redirect_to admin_dossier_prestation_allocation_prenatales_path
      return
    end
    if not @allocation_prenatale.dossier_prestation.pret_pour_soumission_pre_post_natal?
      flash[:error] = "Vous ne pouvez pas liquider cette prestation. Création dossier pas encore complet."
      redirect_to admin_dossier_prestation_allocation_prenatales_path
    elsif current_user.admin_agence.id != @allocation_prenatale.ajoute_par.admin_agence.id
      flash[:error] = "Vous ne pouvez pas liquider cette prestation. Vous n'êtes pas abilité"
      redirect_to admin_dossier_prestation_allocation_prenatales_path
    elsif @allocation_prenatale.dossier_prestation.date_ouverture > date_ref
      flash[:error] = "Ce volet est invalide : antérieur à la date d'ouverture des droits."
      redirect_to admin_dossier_prestation_allocation_prenatales_path
    elsif not (@allocation_prenatale.date_reception.between?(date_ref, (date_ref + 12.months).end_of_month))
      flash[:error] = "Date de réception invalide : PRESCRIPTION !"
      redirect_to admin_dossier_prestation_allocation_prenatales_path
    end
  end

  def can_valide_operation
    dossier = @allocation_prenatale.dossier_prestation
    if dossier.feminin?
      migrated_allocation = @allocation_prenatale.dossier_prestation.allocations_prenatales_migrees.find_by(volet: @allocation_prenatale.read_attribute_before_type_cast(:volet), date_visite: @allocation_prenatale.date_visite)
    else
      migrated_allocation = @allocation_prenatale.dossier_prestation.allocations_prenatales_migrees.find_by(volet: @allocation_prenatale.read_attribute_before_type_cast(:volet), conjoint_id: @allocation_prenatale.dossier_prestation.conjoint.old_conjoint_id, date_visite: @allocation_prenatale.date_visite)
    end
    unless migrated_allocation.nil?
      flash[:error] = "Cette allocation a déjà été payée dans progress"
      redirect_to admin_dossier_prestation_allocation_prenatales_path
      return
    end
    unless current_user.admin_agence.id == @allocation_prenatale.ajoute_par.admin_agence.id
      flash[:error] = "Vous ne pouvez pas valider cette prestation. Vous n'est pas abilité."
      redirect_to admin_dossier_prestation_allocation_prenatales_path
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_allocation_prenatale
    @allocation_prenatale = AllocationPrenatale.find(params[:id] || params[:allocation_prenatale_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def allocation_prenatale_params
    params.require(:allocation_prenatale).permit(:grossesse_id, :volet, :commentaire, :document, :date_visite, :date_etablissement,
                                                 :date_depot, :num_volet_generer, :date_reception)
  end

  def set_dossier_prestation
    @dossier_prestation = DossierPrestation.find(params[:dossier_prestation_id])
  end

  def soumission_allocation_prenatale_params
    params.require(:allocation_prenatale).permit(:condition_1, :condition_2, :condition_3)
  end
end
