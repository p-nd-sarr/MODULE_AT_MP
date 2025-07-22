class Admin::DossierPrestationGedsController < Admin::ApplicationController
  before_action :set_dossier_prestation_ged, only: [:show, :edit, :update, :destroy, :migrer_prod]

  def index
    @q = DossierPrestationGed.where(status_ged: :en_creation)
    if !current_user.admin?
      @q = @q.where(admin_agence_id: current_user.admin_agence.id)
    end
    @q = DossierPrestationGed.ransack(params[:q])
    @dossier_prestation_geds = @q.result.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @dossier_prestation_ged = DossierPrestationGed.new
  end

  def edit
  end

  def create
    @dossier_prestation_ged = DossierPrestationGed.new(dossier_prestation_ged_params)

    if @dossier_prestation_ged.save
      redirect_to admin_dossier_prestation_ged_path(@dossier_prestation_ged), notice: 'Dossier prestation GED was successfully created.'
    else
      render :new
    end
  end

  def update
    if @dossier_prestation_ged.update(dossier_prestation_ged_params)
      redirect_to admin_dossier_prestation_ged_path(@dossier_prestation_ged), notice: 'Dossier prestation GED was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @dossier_prestation_ged.destroy
    redirect_to admin_dossier_prestation_geds_path, notice: 'Dossier prestation GED was successfully destroyed.'
  end

  def migrer_prod
    @dossier_prestation = DossierPrestation.new()
    @dossier_prestation.num_affiliation = @dossier_prestation_ged.num_affiliation
    @dossier_prestation.sexe_salarie = @dossier_prestation_ged.sexe_salarie
    @dossier_prestation.prenom = @dossier_prestation_ged.prenom
    @dossier_prestation.nom = @dossier_prestation_ged.nom
    @dossier_prestation.lieu_naissance = @dossier_prestation_ged.lieu_naissance 
    @dossier_prestation.adresse_domicile = @dossier_prestation_ged.adresse_domicile 
    @dossier_prestation.telephone = @dossier_prestation_ged.telephone 
    @dossier_prestation.date_naissance = @dossier_prestation_ged.date_naissance
    @dossier_prestation.nin = @dossier_prestation_ged.nin
    @dossier_prestation.nationalite = @dossier_prestation_ged.nationalite
    @dossier_prestation.employeur_actuel = @dossier_prestation_ged.employeur_actuel
    @dossier_prestation.date_embauche = @dossier_prestation_ged.date_embauche
    @dossier_prestation.date_reception = @dossier_prestation_ged.date_reception
    @dossier_prestation.id_item = @dossier_prestation_ged.id_item

    @dossier_prestation.ajoute_par = current_user
    @dossier_prestation.etat = :creation
    @dossier_prestation.traite_par = current_user
    @dossier_prestation.traite_le = DateTime.now
    @dossier_prestation.date_validation = Date.today
    @dossier_prestation.date_ouverture = @dossier_prestation.set_date_ouverture_droit
    @dossier_prestation.admin_agence = current_user.admin_agence

    if @dossier_prestation.save
      @dossier_prestation_ged.num_affiliation = @dossier_prestation.num_affiliation
      @dossier_prestation_ged.status_ged = :valide
      @dossier_prestation_ged.save
      redirect_to [:admin, @dossier_prestation], notice: 'Dossier est créé avec succès.'
    else
      error_messages = @dossier_prestation.errors.full_messages.join(', ')
      redirect_to admin_dossier_prestation_ged_path(@dossier_prestation_ged), alert: "Erreur lors de la migration : #{error_messages}"
    end
  end

  private
    def set_dossier_prestation_ged
      @dossier_prestation_ged = DossierPrestationGed.find(params[:id] || params[:dossier_prestation_ged_id])
    end

    def dossier_prestation_ged_params
      params.require(:dossier_prestation_ged).permit(
        :num_affiliation, :sexe_salarie, :prenom, :nom, :lieu_naissance, 
        :adresse_domicile, :date_naissance, :nin, :nationalite, 
        :employeur_actuel, :date_embauche, :admin_agence_id, :num_dossier, :date_reception,
        :id_item, :lien_ged, :telephone
      )
    end
end