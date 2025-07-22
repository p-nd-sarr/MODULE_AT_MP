class Admin::ReversionVeuvesController < Admin::ApplicationController
  before_action :set_allocataire
  before_action :set_reversion_veuve, only: [:show, :edit, :update, :destroy, :est_eligible, :pas_eligible,
                                             :soumettre, :instruire, :liquider, :valider, :rejeter,
                                             :affecter_allocataire,
                                             :lettre_notification, :retourner_process, :affecter_dossier, :annuler_affectation_dossier]

  def index
    @reversion_veuves = ReversionVeuve.all.includes(:allocataire)
  end

  def toutes_demandes
    @q = ReversionVeuve.all.ransack(params[:q])

    @total = @q.result.count

    @reversion_veuves = @q.result.includes(:allocataire).order('created_at desc')

    @reversion_veuves = @reversion_veuves.page(params[:page]).per(100) unless params[:format] == 'xlsx'
    if params[:format] == 'xlsx'
      response.headers['Content-Disposition'] = "attachment; filename=""reversion_veuves_#{Date.today.strftime('%Y_%m_%d')}.xlsx"""
      render :liste
    end
  end

  def mes_demandes
    @q = current_user.reversion_veuves_crees.ransack(params[:q])

    @reversion_veuves = @q.result.includes(:allocataire).page(params[:page]).order('created_at desc').per(100)
  end

  def en_attente_instruction
    if current_user.can_instruction?  #check if current_user is a chef_agence_ipres
      @reversion_veuves = ReversionVeuve.where(admin_agence_id: current_user.admin_agence.id).where(workflow_state: :soumis)
    else
      @reversion_veuves = ReversionVeuve.en_attente_instruction
    end
  end

  def en_attente_affectation
    @reversion_veuves = ReversionVeuve.en_attente_allocation
  end

  def en_attente_affectation_allocataire
    @reversion_veuves = ReversionVeuve.en_attente_allocation
  end

  def en_attente_validation_liquidation
    @reversion_veuves = ReversionVeuve.en_attente_validation_liquidation
  end

  def en_attente_validation_recap
    @reversion_veuves = ReversionVeuve.en_attente_validation_recap
  end

  def show
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires
    @agents = User.users_for_type('gestionnaire_compte_allocataire').en_agence(current_user.agence_id)
  end

  def affecter_dossier
    @agent = User.find(params[:agent_id])
    @reversion_veuve.set_as_agent_chosen(@agent.id)
    redirect_to [:admin, @allocataire, @reversion_veuve], notice: 'L' 'agent a été choisi en tant que titulaire du dossier.'
  end

  def annuler_affectation_dossier
    @agent = User.find(params[:agent_id])
    @reversion_veuve.is_not_agent_chosen_anymore(@agent.id)
    redirect_to [:admin, @allocataire, @reversion_veuve], notice: 'L' 'agent a été retiré en tant que titulaire du dossier.'
  end

  def est_eligible
    if @reversion_veuve.veuve? and @reversion_veuve.base_reversion.nombre_veuve_eligible_atteint?
      flash[:error] = 'Vous avez atteint le nombre max de veuves éligibles'
    elsif @reversion_veuve.orphelin? and @reversion_veuve.base_reversion.nombre_orphelins_eligible_atteint?
      flash[:error] = 'Vous avez atteint le nombre max d' 'orphelins éligibles'
    else
      if @reversion_veuve.peut_etre_eligible?
        @reversion_veuve.update(eligible: true)
      else
        flash[:error] = "Cet ayant droit n'est pas éligible"
      end
    end
    redirect_to [:admin, @allocataire, @reversion_veuve]
  end

  def pas_eligible
    @reversion_veuve.update(eligible: false)
    redirect_to [:admin, @allocataire, @reversion_veuve]
  end

  def new
    if @allocataire.base_reversion.nil?
      redirect_to new_admin_allocataire_base_reversion_path(@allocataire)
    else
      @reversion_veuve = ReversionVeuve.new
    end
  end

  def edit; end

  def create
    redirect_to(new_admin_allocataire_base_reversion_path(@allocataire)) if @allocataire.base_reversion.nil?
    @reversion_veuve = ReversionVeuve.new(reversion_veuve_params)
    @reversion_veuve.numero_allocataire = @allocataire.numero_allocataire
    @reversion_veuve.ajoute_par = current_user
    @reversion_veuve.ajouter_le = DateTime.now
    @reversion_veuve.admin_agence = current_user.admin_agence

    respond_to do |format|
      if @reversion_veuve.save
        format.html { redirect_to [:admin, @allocataire, @reversion_veuve], notice: 'Reversion veuve was successfully created.' }
        format.json { render :show, status: :created, location: @reversion_veuve }
      else
        format.html { render :new }
        format.json { render json: @reversion_veuve.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @reversion_veuve.update(reversion_veuve_params)
        format.html { redirect_to [:admin, @allocataire, @reversion_veuve], notice: 'Reversion veuve was successfully updated.' }
        format.json { render :show, status: :ok, location: @reversion_veuve }
      else
        format.html { render :edit }
        format.json { render json: @reversion_veuve.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @reversion_veuve.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @allocataire], notice: 'Reversion veuve was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def affecter_allocataire
    # affecter une demande à un gestionnaire allocataire
    if @reversion_veuve.update(revision_affecter_allocataire_params.merge(affecter_le: DateTime.now))
      redirect_to [:admin, @allocataire, @reversion_veuve], notice: 'Demande Affectée.'
    end
  end

  def soumettre
    if @reversion_veuve.creation?
      @reversion_veuve.est_soumis!
      @reversion_veuve.date_soumis = DateTime.now
      @reversion_veuve.traite_par = current_user
      @reversion_veuve.traite_le = DateTime.now
      @reversion_veuve.save
      redirect_to [:admin, @allocataire, @reversion_veuve], notice: 'La demande de reversion est soumise'
    else
      redirect_to [:admin, @allocataire, @reversion_veuve]
    end

  end

  def instruire
    if current_user.can_instruction? and @reversion_veuve.ajoute_par.admin_agence != current_user.admin_agence
      flash[:error] = 'Vous n\'avez pas le droit de faire une action sur ce dossier'
      redirect_to [:admin, @reversion_veuve]
      return
    end

    if @reversion_veuve.soumis?
      @reversion_veuve.est_instruit!
      @reversion_veuve.instruit_par = current_user
      @reversion_veuve.instruit_le = DateTime.now
      @reversion_veuve.save
      redirect_to [:admin, @allocataire, @reversion_veuve], notice: 'Demande Instruit'
    else
      redirect_to [:admin, @allocataire, @reversion_veuve]
    end
  end

  def liquider
    if @reversion_veuve.instruit?
      @reversion_veuve.est_liquide!
      @reversion_veuve.traite_par = current_user
      @reversion_veuve.traite_le = DateTime.now
      @reversion_veuve.save
      redirect_to [:admin, @allocataire, @reversion_veuve], notice: 'Dossier liquidé avec succés'
    else
      redirect_to [:admin, @allocataire, @reversion_veuve]
    end
  end

  def valider
    if @reversion_veuve.liquide?
      @reversion_veuve.est_valide!
      @reversion_veuve.valider_par = current_user
      @reversion_veuve.valider_le = DateTime.now
      @reversion_veuve.save
      @reversion_veuve.allocataire.eteint!
      redirect_to [:admin, @allocataire, @reversion_veuve], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @allocataire, @reversion_veuve]
    end
  end

  def rejeter
    if @reversion_veuve.liquide?
      @reversion_veuve.est_rejete!
      @reversion_veuve.valider_par = current_user
      @reversion_veuve.valider_le = DateTime.now
      @reversion_veuve.save
      redirect_to [:admin, @allocataire, @reversion_veuve], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @allocataire, @reversion_veuve]
    end
  end

  def lettre_notification
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "lettre notification n°. #{@reversion_veuve.id}",
               page_size: 'A4',
               template: "admin/reversion_veuves/lettre_notification.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def en_attente_soumission
    @reversion_veuves = ReversionVeuve.where(soumis_par: current_user.id).with_creation_state
  end

  def en_attente_recap_soumission
    @reversion_veuves = ReversionVeuve.with_instruit_state
  end

  def en_attente_liquidation
    @reversion_veuves = ReversionVeuve.with_instruit_state
  end

  def en_attente_validation
    @reversion_veuves = ReversionVeuve.with_liquide_state
  end

  def toute_demanndes
    @reversion_veuves = ReversionVeuve.all
  end


  def retourner_process
    if @reversion_veuve.soumis?
      @reversion_veuve.update(traite_par: current_user,
                                  traite_le: nil)
      @reversion_veuve.retour_creation!
    elsif @reversion_veuve.instruit?
      @reversion_veuve.update(instruit_par: nil,
                                  traite_par: current_user,
                                  instruit_le: nil)
      @reversion_veuve.retour_soumis!

    elsif @reversion_veuve.liquide?
      @reversion_veuve.update(traite_par: current_user,
                                  traite_le: nil)
      @reversion_veuve.retour_instruit!
    end
    if @reversion_veuve.update(reversion_motif_params.merge(traite_par: current_user,
                                                                           traite_le: DateTime.now))
      redirect_to [:admin, @allocataire, @reversion_veuve]
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      redirect_to [:admin, @allocataire, @reversion_veuve]
      #render :rejeter
    end
  end

  private

  def set_reversion_veuve
    if(@allocataire.nil?)
      @reversion_veuve = ReversionVeuve.find(params[:id] || params[:reversion_veuve_id])

    else
      @reversion_veuve = @allocataire.reversion_veuves.find(params[:id] || params[:reversion_veuve_id])

    end
  end

  def reversion_veuve_params
    params.require(:reversion_veuve).permit(:prenom, :nom, :date_naissance, :lieu_naissance, :adresse,
                                            :adresse_reception_allocation, :mode_paiement,
                                            :compte_bancaire_cle_rib, :compte_bancaire_numero_compte, :admin_banque_agence_id,
                                            :type_ayant_droit, :conjoint_id, :enfant_id, :nom_tuteur, :prenom_tuteur, :telephone, :email, :agence_paiement_id)
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id]) unless params[:allocataire_id].nil?
  end

  def revision_affecter_allocataire_params
    params.require(:reversion_veuve).permit(:affecter_a)
  end

  def reversion_motif_params
    params.require(:reversion_veuve).permit(:motif)
  end
end
