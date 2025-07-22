class Admin::IndemniteCongesMaternitesController < Admin::ApplicationController
  before_action :set_dossier_maternite, except: [:en_attente, :valider, :rejeter, :rejeter_create, :index_all]
  before_action :set_indemnite_conges_maternite, except: [:index, :new, :create, :en_attente, :ajoutee, :index_all]
  before_action :can_valide_operation, only: [:valider]
  before_action :can_soumettre, only: [:soumettre]
  #after_action :set_num_genere_volet, only: [:soumettre]

  # GET /indemnite_conges_maternites
  # GET /indemnite_conges_maternites.json
  def index
    @q = @dossier_maternite.indemnite_conges_maternites
    @indemnite_conges_maternites = @q.order('num_tranche asc')
  end

  def en_attente
    @indemnite_conges_maternites = IndemniteCongesMaternite.en_attente.page(params[:page]).per(100)
  end

  def index_all
    @indemnite_conges_maternites = IndemniteCongesMaternite.visible_for_admins.page(params[:page]).per(100)
  end

  def valider
    if @indemnite_conges_maternite.dossier_maternite.valide?
      @indemnite_conges_maternite.valide!
      @indemnite_conges_maternite.traite_par = current_user
      @indemnite_conges_maternite.traite_le = DateTime.now
      @indemnite_conges_maternite.date_validation = Date.today
      @indemnite_conges_maternite.retourne_par = nil
      @indemnite_conges_maternite.retourne_le = nil
      @indemnite_conges_maternite.motif_retour = ''

      @indemnite_conges_maternite.save
      flash[:notice] = 'Demande traitée'
      #redirect_to en_attente_admin_indemnite_conges_maternites_path
      redirect_to admin_dossier_maternite_indemnite_conges_maternites_path(@indemnite_conges_maternite.dossier_maternite)
    else
      flash[:error] = 'Vous devez valider le dossier avant de valider les indemnités.'
      redirect_to admin_dossier_maternite_indemnite_conges_maternites_path(@indemnite_conges_maternite.dossier_maternite)
    end
  end

  def rejeter
    @indemnite_conges_maternite.rejete!
    @indemnite_conges_maternite.traite_par = current_user
    @indemnite_conges_maternite.traite_le = DateTime.now
    @indemnite_conges_maternite.date_validation = Date.today
    @indemnite_conges_maternite.save
    flash[:notice] = 'Prestation rejetée'
    redirect_to admin_dossier_maternite_indemnite_conges_maternites_path(@indemnite_conges_maternite.dossier_maternite)
  end

  def rejeter_create
    if @indemnite_conges_maternite.update(indemnite_conges_maternite_rejet_params.merge(etat: :rejete,
                                                                                        traite_par: current_user,
                                                                                        traite_le: DateTime.now))
      redirect_to en_attente_admin_indemnite_conges_maternites_path, notice: 'Demande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end


  def indemnite_conges_maternite_rejet_params
    params.require(:indemnite_conges_maternite).permit(:motif_rejet)
  end

  # GET /indemnite_conges_maternites/1
  # GET /indemnite_conges_maternites/1.json
  def show
    #show
  end

  # GET /indemnite_conges_maternites/new
  def new
    if @dossier_maternite.dossier_maternite_avis_tiers.exists?(type_avis: :trop_percu, etat: [:creation, :soumis])
      respond_to do |format|
        format.html { redirect_to admin_dossier_maternite_indemnite_conges_maternites_path(@dossier_maternite), 
          alert: "Vous ne pouvez pas créer une nouvelle tranche. Un avis tiers non validé existe." } 
      end
      return
    end
    @indemnite_conges_maternite = IndemniteCongesMaternite.new
  end

  # GET /indemnite_conges_maternites/1/edit
  def edit
    #edit
  end

  # POST /indemnite_conges_maternites
  # POST /indemnite_conges_maternites.json
  def create
    @indemnite_conges_maternite = IndemniteCongesMaternite.new(indemnite_conges_maternite_params)

    @indemnite_conges_maternite.dossier_maternite = @dossier_maternite
    @indemnite_conges_maternite.debut_conges = @dossier_maternite.debut_conges
    @indemnite_conges_maternite.user = @dossier_maternite.user
    @indemnite_conges_maternite.ajoute_par = current_user
    @indemnite_conges_maternite.etat = :creation

    respond_to do |format|
      if @indemnite_conges_maternite.save
        format.html { redirect_to [:admin, @dossier_maternite, @indemnite_conges_maternite], notice: 'ICM was successfully created.' }
        format.json { render :show, status: :created, location: @indemnite_conges_maternite }
      else
        format.html { render :new }
        format.json { render json: @indemnite_conges_maternite.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /indemnite_conges_maternites/1
  # PATCH/PUT /indemnite_conges_maternites/1.json
  def update
    respond_to do |format|
      if @indemnite_conges_maternite.update(indemnite_conges_maternite_params)
        format.html { redirect_to [:admin, @dossier_maternite, @indemnite_conges_maternite], notice: 'ICM was successfully updated.' }
        format.json { render :show, status: :ok, location: @indemnite_conges_maternite }
      else
        format.html { render :edit }
        format.json { render json: @indemnite_conges_maternite.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indemnite_conges_maternites/1
  # DELETE /indemnite_conges_maternites/1.json
  def destroy
    if (@indemnite_conges_maternite.apres_acouchement?)
      @dossier_maternite.update(date_accouchement_reel: nil)
    elsif (@indemnite_conges_maternite.apres_reprise?)
      @dossier_maternite.update(date_fin_cong_reel: nil)
    elsif (@indemnite_conges_maternite.tranche_prolongation?)
      @dossier_maternite.update(jours_prolongation: nil)
    end
    if (@indemnite_conges_maternite.decedee?)
      @dossier_maternite.update(decedee: false)
    end
    @indemnite_conges_maternite.destroy
    respond_to do |format|
      format.html {
        redirect_to admin_dossier_maternite_indemnite_conges_maternites_path(@dossier_maternite), notice: 'ICM was successfully destroyed.'
      }
      format.json { head :no_content }
    end
  end

  def soumettre
    annee = Date.today.year
    @indemnite_conges_maternites = @dossier_maternite.indemnite_conges_maternites
    nbre = @indemnite_conges_maternites.soumis.count
    if @indemnite_conges_maternite.update(etat: :soumis, date_soumission: Date.today, date_liquidation: Date.today, retourne_par: nil, retourne_le: nil, motif_retour: '',
                                          montant_paiement: @indemnite_conges_maternite.montant_paiement,
                                          numero_liquidation: nbre.to_s + "/" + @dossier_maternite.num_dossier + "/" + "#{annee}/LiqICM")
      redirect_to admin_dossier_maternite_indemnite_conges_maternites_path(@dossier_maternite), notice: "La demande est liquidée."
    else
      flash[:error] = "Erreur : Liquidation.", @indemnite_conges_maternite.errors.full_messages
      redirect_to admin_dossier_maternite_indemnite_conges_maternites_path(@dossier_maternite)
    end
  end

  def retourner
    if @indemnite_conges_maternite.update(indemnite_conges_maternite_params)
      if current_user.chef_agence?
        @indemnite_conges_maternite.creation!
        @indemnite_conges_maternite.update(date_soumission: nil, date_liquidation: nil, montant_paiement: nil, numero_liquidation: nil)
      end
      if current_user.comptable?
        @indemnite_conges_maternite.soumis!
        @indemnite_conges_maternite.update(date_validation: nil, traite_par: nil, traite_le: nil)
      end

      @indemnite_conges_maternite.retourne_par = current_user
      @indemnite_conges_maternite.retourne_le = DateTime.now
      @indemnite_conges_maternite.save
      redirect_to [:admin, @dossier_maternite, @indemnite_conges_maternite], notice: 'La tranche a été retournée avec succès.'
    else
      flash[:error] = "Une erreur estbsurvenue."
      redirect_to [:admin, @dossier_maternite, @indemnite_conges_maternite]
    end
  end

  def soumission_form; end

  #def valider_paiement_compt
  def valider_paiement
    ValiderPaiementsDossierMaterniteJob.perform_later(@dossier_maternite, current_user)

    #flash[:notice] = "Génération de l'ordre de paiement en cours ..."
    redirect_to admin_dossier_maternite_indemnite_conges_maternites_path(@dossier_maternite),
                notice: "Génération de l'ordre de paiement en cours ... à retrouver dans le dossier."
  end

  private

  #def set_num_genere_volet
  #  annee = Date.today.year
  #  if @indemnite_conges_maternite.numero_liquidation.nil?
  #    @indemnite_conges_maternite.numero_liquidation = params[:dossier_maternite_id] + "/" +
  # params[:indemnite_conges_maternite_id] + "/" + "#{annee}/ICM"
  #    @indemnite_conges_maternite.save
  #  end
  #end

  def can_valide_operation
    migrated_allocation = @indemnite_conges_maternite.dossier_maternite.indemnite_conges_maternite_migrees.find_by(num_tranche: @indemnite_conges_maternite.num_tranche)
    unless migrated_allocation.nil?
      flash[:error] = "Cette tranche a déjà été payée dans progress"
      redirect_to admin_dossier_maternite_indemnite_conges_maternites_path
      return
    end
    unless current_user.admin_agence.id == @indemnite_conges_maternite.ajoute_par.admin_agence.id
      flash[:error] = "Vous ne pouvez pas valider cette prestation. Vous n'est pas abilité."
      redirect_to admin_dossier_maternite_indemnite_conges_maternites_path
    end
  end

  def can_soumettre
    migrated_allocation = @indemnite_conges_maternite.dossier_maternite.indemnite_conges_maternite_migrees.find_by(num_tranche: @indemnite_conges_maternite.num_tranche)
    unless migrated_allocation.nil?
      flash[:error] = "Cette tranche a déjà été payée dans progress"
      redirect_to admin_dossier_maternite_indemnite_conges_maternites_path
      return
    end
    if not @indemnite_conges_maternite.dossier_maternite.pret_pour_soumission?
      flash[:error] = "Vous ne pouvez pas liquider cette prestation. Création dossier pas encore complet."
      redirect_to admin_dossier_maternite_indemnite_conges_maternites_path
    elsif current_user.admin_agence.id != @indemnite_conges_maternite.ajoute_par.admin_agence.id
      flash[:error] = "Vous ne pouvez pas liquider cette prestation. Vous n'êtes pas abilité"
      redirect_to admin_dossier_maternite_indemnite_conges_maternites_path
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_indemnite_conges_maternite
    @indemnite_conges_maternite = IndemniteCongesMaternite.find(params[:id] || params[:indemnite_conges_maternite_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def indemnite_conges_maternite_params
    params.require(:indemnite_conges_maternite).permit(:tranche_paiement, :debut_conges, :date_accouchement, :lieu_accouchement,
                                                       :date_reprise_service, :attestation_accouchement, :certificat_reprise,
                                                       :nbre_jr_payes, :decedee, :date_deces, :nom_mandataire, :prenom_mandataire,
                                                       :nin_mandataire, :certificat_deces, :certificat_heredite, :procuration_legalisee, :cas_force_majeur,
                                                       :document_cas_force_majeur, :document_rapport, :rapport_controle, :date_rapport,
                                                       :prolongation, :certificat_medical, :date_reprise_reelle, :certificat_non_reprise,
                                                       :jours_prolongation, :motif_retour)
  end

  def set_dossier_maternite
    @dossier_maternite = DossierMaternite.find(params[:dossier_maternite_id])
  end

  def soumission_indemnite_conges_maternite_params
    params.require(:indemnite_conges_maternite).permit(:condition_1, :condition_2)
  end
end
