class Admin::AllocataireCnavsController < Admin::ApplicationController
  before_action :set_dossier_cnav, except: [:en_attente, :valider, :rejeter, :rejeter_create, :index_all]
  before_action :set_allocataire_cnav, except: [:index, :new, :create, :en_attente, :ajoutee, :index_all]
  #before_action :can_valide_operation, only: [:valider]
  before_action :can_soumettre, only: [:soumettre]

  # GET /allocataire_cnavs
  # GET /allocataire_cnavs.json
  def index
    #@allocataire_cnavs = AllocataireCnav.all

    @q = @dossier_cnav.allocataire_cnavs.visible_for_admins.ransack(params[:q])
    @allocataire_cnavs = @q.result.order('delta asc, nom asc')
    @totaux = @allocataire_cnavs
    @allocataire_cnavs = @allocataire_cnavs.page(params[:page]).per(150)
  end

  def en_attente
    @allocataire_cnavs = AllocataireCnav.en_attente.page(params[:page]).per(150)
  end

  def index_all
    @allocataire_cnavs = AllocataireCnav.visible_for_admins.page(params[:page]).per(150)
  end


  def valider_liquidation
    @allocataire_cnav.valide_liquidation!
    @allocataire_cnav.valider_liq_par = current_user
    @allocataire_cnav.valider_liq_le = DateTime.now

    @allocataire_cnav.save
    flash[:notice] = 'Validation Liquidation Réussie.'
    redirect_to admin_dossier_cnav_allocataire_cnavs_path(@allocataire_cnav.dossier_cnav)
  end

  def rejeter_liquidation
    @allocataire_cnav.rejete_liquidation!
    @allocataire_cnav.valider_liq_par = current_user
    @allocataire_cnav.valider_liq_le = DateTime.now
    @allocataire_cnav.save
    flash[:notice] = 'Opération de rejet de la liquidation réussie.'
    redirect_to admin_dossier_cnav_allocataire_cnavs_path(@allocataire_cnav.dossier_cnav)
  end


  def valider_inspection
    @allocataire_cnav.valide_inspection!
    @allocataire_cnav.valider_insp_par = current_user
    @allocataire_cnav.valider_insp_le = DateTime.now

    @allocataire_cnav.save
    flash[:notice] = 'Validation Inspection Réussie.'

    # GENERATION FACTURE
    @allocataire_cnav.generer_facture

    redirect_to admin_dossier_cnav_allocataire_cnavs_path(@allocataire_cnav.dossier_cnav)
  end

  def rejeter_inspection
    @allocataire_cnav.rejete_inspection!
    @allocataire_cnav.valider_insp_par = current_user
    @allocataire_cnav.valider_insp_le = DateTime.now
    @allocataire_cnav.save
    flash[:notice] = "Opération de rejet de l'inspection réussie."
    redirect_to admin_dossier_cnav_allocataire_cnavs_path(@allocataire_cnav.dossier_cnav)
  end


  def valider
    #if @allocataire_cnav.dossier_cnav.valide?
      @allocataire_cnav.valide!
      @allocataire_cnav.traite_par = current_user
      @allocataire_cnav.traite_le = DateTime.now
      @allocataire_cnav.date_validation = Date.today

      @allocataire_cnav.save
      flash[:notice] = 'Validation Réussie.'
      #redirect_to en_attente_admin_allocataire_cnavs_path
      redirect_to admin_dossier_cnav_allocataire_cnavs_path(@allocataire_cnav.dossier_cnav)
    #else
    #  flash[:error] = 'Vous devez valider le dossier avant de valider les indemnités.'
    #  redirect_to admin_dossier_cnav_allocataire_cnavs_path(@allocataire_cnav.dossier_cnav)
    #end
  end

  def rejeter
    @allocataire_cnav.rejete!
    @allocataire_cnav.traite_par = current_user
    @allocataire_cnav.traite_le = DateTime.now
    @allocataire_cnav.date_validation = Date.today
    @allocataire_cnav.save
    flash[:notice] = 'Opération de rejet réussie.'
    redirect_to admin_dossier_cnav_allocataire_cnavs_path(@allocataire_cnav.dossier_cnav)
  end

  def rejeter_create
    if @allocataire_cnav.update(allocataire_cnav_rejet_params.merge(etat: :rejete,
                                                                    traite_par: current_user,
                                                                    traite_le: DateTime.now))
      redirect_to en_attente_admin_allocataire_cnavs_path, notice: 'Demande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end


  def allocataire_cnav_rejet_params
    params.require(:allocataire_cnav).permit(:motif_rejet)
  end

  # GET /allocataire_cnavs/1
  # GET /allocataire_cnavs/1.json
  def show
  end

  # GET /allocataire_cnavs/new
  def new
    @allocataire_cnav = AllocataireCnav.new
  end

  # GET /allocataire_cnavs/1/edit
  def edit
  end

  # POST /allocataire_cnavs
  # POST /allocataire_cnavs.json
  def create
    @allocataire_cnav = AllocataireCnav.new(allocataire_cnav_params)

    @allocataire_cnav.dossier_cnav = @dossier_cnav
    @allocataire_cnav.user = @dossier_cnav.user
    @allocataire_cnav.date_import = Date.today
    @allocataire_cnav.ajoute_par = current_user
    @allocataire_cnav.etat = :creation

    respond_to do |format|
      if @allocataire_cnav.save
        format.html { redirect_to [:admin, @dossier_cnav, @allocataire_cnav], notice: 'Création Réussie.' }
        format.json { render :show, status: :created, location: @allocataire_cnav }
      else
        format.html { render :new }
        format.json { render json: @allocataire_cnav.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /allocataire_cnavs/1
  # PATCH/PUT /allocataire_cnavs/1.json
  def update
    respond_to do |format|
      if @allocataire_cnav.update(allocataire_cnav_params)
        format.html { redirect_to [:admin, @dossier_cnav, @allocataire_cnav], notice: 'Modification Réussie.' }
        format.json { render :show, status: :ok, location: @allocataire_cnav }
      else
        format.html { render :edit }
        format.json { render json: @allocataire_cnav.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /allocataire_cnavs/1
  # DELETE /allocataire_cnavs/1.json
  def destroy
    @allocataire_cnav.destroy
    respond_to do |format|
      format.html {
        redirect_to admin_dossier_cnav_allocataire_cnavs_path(@dossier_cnav), notice: 'Suppression Réussie.'
      }
      format.json { head :no_content }
    end
  end


  def soumettre
    annee = Date.today.year
    @allocataire_cnavs = @dossier_cnav.allocataire_cnavs
    nbre = @allocataire_cnavs.soumis.count + 1
    # code = @dossier_cnav.type_convention

    num_liq = @dossier_cnav.mois.nil? ? DossierCnav.human_enum_name(:trimestre, @dossier_cnav.trimestre) + "Trim/" + "#{annee}/" + nbre.to_s + "Liq" : DossierCnav.human_enum_name(:mois, @dossier_cnav.mois) + "/" + "#{annee}/" + nbre.to_s + "Liq"
    if @allocataire_cnav.update(etat: :soumis, date_soumission: Date.today, date_liquidation: Date.today,
                                numero_liquidation: num_liq)
      redirect_to admin_dossier_cnav_allocataire_cnavs_path(@dossier_cnav), notice: "Liquidation Réussie."

    else
      redirect_to admin_dossier_cnav_allocataire_cnavs_path(@dossier_cnav), notice: 'Erreur : Liquidation.'
    end
  end


=begin
  def valider_paiement
    ValiderPaiementsDossierMaterniteJob.perform_later(@dossier_cnav, current_user)

    #flash[:notice] = "Génération de l'ordre de paiement en cours ..."
    redirect_to admin_dossier_cnav_allocataire_cnavs_path(@dossier_cnav),
                notice: "Génération de l'ordre de paiement en cours ... à retrouver dans le dossier."
  end
=end

  private

=begin
  def can_valide_operation
    unless current_user.admin_agence.id == @allocataire_cnav.ajoute_par.admin_agence.id
      flash[:error] = "Vous ne pouvez pas valider cette prestation. Vous n'est pas abilité."
      redirect_to admin_dossier_cnav_allocataire_cnavs_path
    end
  end
=end

  def can_soumettre
    if current_user.admin_agence.id != @allocataire_cnav.ajoute_par.admin_agence.id
      flash[:error] = "Vous n'êtes pas abilité à procéder à la liquidation."
      redirect_to admin_dossier_cnav_allocataire_cnavs_path
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_allocataire_cnav
    #@allocataire_cnav = AllocataireCnav.find(params[:id])
    @allocataire_cnav = AllocataireCnav.find(params[:id] || params[:allocataire_cnav_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def allocataire_cnav_params
    params.require(:allocataire_cnav).permit(:dossier_cnav_id, :date_import, :numero, :prenom, :nom, :admin_region_id,
                                             :montant, :origine, :compte, :caisse_bk, :date_soumission, :date_validation,
                                             :valide_par_id, :user_id, :ajoute_par_id, :traite_le, :traite_par_id, :motif_rejet,
                                             :montant_paiement, :paiement, :etat, :mode_paiement, :numero_liquidation, :date_liquidation, :iban)
  end

  def set_dossier_cnav
    @dossier_cnav = DossierCnav.find(params[:dossier_cnav_id])
  end
end
