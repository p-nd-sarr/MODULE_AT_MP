class Admin::AvisTiersController < Admin::ApplicationController
  before_action :set_allocataire
  before_action :set_avis_tier, only: [:show, :edit, :update, :valider_par_directeur, :valider_chef_service]

  def index
    @avis_tiers = AvisTier.where(numero_allocataire: @allocataire.numero_allocataire)
  end

  def edit
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaire
  end

  def new
    @avis_tier = AvisTier.new
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaire
  end

  def show
    #show
  end

  def create
    @avis_tier = AvisTier.new(avis_tier_params)
    @avis_tier.allocataire = @allocataire
    @avis_tier.ajouter_par = current_user
    @avis_tier.etat = :creation

    respond_to do |format|
      if @avis_tier.save
        format.html { redirect_to [:admin, @allocataire, @avis_tier], notice: 'La demande avis tiers créée avec succés.' }
        format.json { render :show, status: :created, location: @avis_tier }
      else
        format.html { render :new }
        format.json { render json: @avis_tier.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @avis_tier.creation?
      if @avis_tier.update(avis_tier_params)
        redirect_to [:admin, @allocataire, @avis_tier], notice: 'La demande avis tiers est bien mise à jour.'
      else
        render :edit
      end
    else
      redirect_to [:admin, @allocataire, @avis_tier], error: 'La demande avis tiers ne peut pas être mise à jour.'
    end
  end

  #region : Workflow Validation REVISION PENSION
  #

  def rejeter
    if @avis_tier.validation_directeur?
      @avis_tier.etat = :rejeter
      @avis_tier.valider_par = current_user
      @avis_tier.validation_date = DateTime.now
      @avis_tier.save
      redirect_to [:admin, @allocataire, @avis_tier], notice: 'Demande avis tiers rejeter'
    else
      redirect_to [:admin, @allocataire, @avis_tier]
    end
  end

  def valider_par_directeur
    if @avis_tier.creation?
      @avis_tier.etat = :validation_directeur
      @avis_tier.valider_par = current_user
      @avis_tier.valider_le = DateTime.now
      @avis_tier.save
      redirect_to [:admin, @allocataire, @avis_tier], notice: 'Demande avis tiers valider'
    else
      redirect_to [:admin, @allocataire, @avis_tier]
    end
  end

  def valider_chef_service
    if @avis_tier.update(avis_valider_montant_params)
      @avis_tier.set_montant_mensuel
      @avis_tier.etat = :validation_chef_service
      @avis_tier.save
      redirect_to [:admin, @allocataire, @avis_tier], notice: 'Demande avis tiers rejeter'
    end

  end

  def lettre_notification
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "lettre notification n°. #{@pension_alimentaire.id}",
               page_size: 'A4',
               template: "admin/avis_tierslettre_notification.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  private

  def set_avis_tier
    @avis_tier = @allocataire.avis_tiers.find(params[:id] || params[:avis_tier_id])
  end

  def avis_tier_params
    params.require(:avis_tier).permit(:nombre_echeance, :commentaire, :date_debut, :montant, :type, :gest_allocataire_id)
  end

  def avis_valider_montant_params
    params.require(:avis_tier).permit(:montant, :nombre_echeance, :commentaire, :document)
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id])
  end
end