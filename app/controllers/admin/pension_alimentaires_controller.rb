class Admin::PensionAlimentairesController < Admin::ApplicationController

  before_action :set_allocataire, except: [:lettre_notification]
  before_action :set_pension_alimentaire, only: [:show, :edit, :update, :valider_par_directeur, :valider_chef_service]
  before_action :set_pension_alimentaire_pdf, only: [:lettre_notification]

  def index
    @pension_alimentaires = PensionAlimentaire.where(numero_allocataire: @allocataire.numero_allocataire)
  end

  def edit
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaire
  end

  def new
    @pension_alimentaire = PensionAlimentaire.new
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaire
  end

  def show
    #show
  end

  def create
    @pension_alimentaire = PensionAlimentaire.new(pension_alimentaire_params)
    @pension_alimentaire.allocataire = @allocataire
    @pension_alimentaire.ajouter_par = current_user
    @pension_alimentaire.etat = :creation

    respond_to do |format|
      if @pension_alimentaire.save
        format.html { redirect_to [:admin, @allocataire, @pension_alimentaire], notice: 'Pret allocataire was successfully created.' }
        format.json { render :show, status: :created, location: @pension_alimentaire }
      else
        format.html { render :new }
        format.json { render json: @pension_alimentaire.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @pension_alimentaire.update(pension_alimentaire_params)
      redirect_to [:admin, @allocataire, @pension_alimentaire], notice: 'La demande de révision est bien mise à jour.'
    else
      render :edit
    end
  end

#region : Workflow Validation REVISION PENSION
#

  def rejeter
    if @pension_alimentaire.validation_directeur?
      @pension_alimentaire.etat = :rejeter
      @pension_alimentaire.valider_par = current_user
      @pension_alimentaire.validation_date = DateTime.now
      @pension_alimentaire.save
      redirect_to [:admin, @allocataire, @pension_alimentaire], notice: 'Demande de pension rejeter'
    else
      redirect_to [:admin, @allocataire, @pension_alimentaire]
    end
  end

  def valider_par_directeur
    if @pension_alimentaire.validation_chef_service?
      @pension_alimentaire.etat= :validation_directeur
      @pension_alimentaire.valider_par = current_user
      @pension_alimentaire.valider_le = DateTime.now
      @pension_alimentaire.save
      redirect_to [:admin, @allocataire, @pension_alimentaire], notice: 'Demande de pret valider'
    else
      redirect_to [:admin, @allocataire, @pension_alimentaire]
    end
  end

  def valider_chef_service
    if @pension_alimentaire.update(pension_valider_montant_params)
      @pension_alimentaire.etat =:validation_chef_service
      @pension_alimentaire.save
      redirect_to [:admin, @allocataire, @pension_alimentaire], notice: 'Demande de pension rejeter'
    end

  end


  def lettre_notification

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "lettre notification n°. #{@pension_alimentaire.id}",
               page_size: 'A4',
               template: "admin/pension_alimentaires/lettre_notification.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  private
  def set_pension_alimentaire
    @pension_alimentaire = @allocataire.pension_alimentaires.find(params[:id] || params[:pension_alimentaire_id])
  end

  def set_pension_alimentaire_pdf
    @pension_alimentaire = PensionAlimentaire.find(params[:id] || params[:pension_alimentaire_id])
  end

  def pension_alimentaire_params
    params.require(:pension_alimentaire).permit(:nom, :prenom, :adresse, :adresse, :telephone, :email, :commentaire, :date_jouissance, :date_naissance, :gest_allocataire_id, :numero_jugement, :montant_versement, :montant, :document)
  end

  def pension_valider_montant_params
    params.require(:pension_alimentaire).permit(:montant, :commentaire, :document)
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id])
  end

end