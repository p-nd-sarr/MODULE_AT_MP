class Admin::AtDossierReversionRentesController < Admin::ApplicationController
  #before_action :set_at_rente_famille
  before_action :set_at_dossier_reversion_rente, only: [:show, :edit, :update, :destroy, :est_eligible, :pas_eligible, :soumettre, :instruire, :valider_info_reversion, :valider,:valider_documents,:notification ]

  def index
    @at_dossier_reversion_rentes = AtDossierReversionRente.all

  end

  def show
    @at_rente_famille = AtRenteFamille.find(@at_dossier_reversion_rente.at_rente_famille_id)
  end

  def valider_info_reversion
    if @at_dossier_reversion_rente.valider_info_reversion!
      redirect_to [:admin, @demande_arret_travail, @at_dossier_reversion_rente]
    end
  end

  def valider_documents
    unless @at_dossier_reversion_rente.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
      redirect_to [:admin, @demande_arret_travail, @at_dossier_reversion_rente]
    else
    redirect_to [:admin, @demande_arret_travail, @at_dossier_reversion_rente]
    end
  end
  
  def soumettre
    if @at_dossier_reversion_rente.creation?
      @at_dossier_reversion_rente.est_soumis!
      @at_dossier_reversion_rente.save
      redirect_to [:admin, @demande_arret_travail, @at_dossier_reversion_rente], notice: 'Arret travail was successfully submitted.'
    else
      redirect_to [:admin, @demande_arret_travail, @at_dossier_reversion_rente]
    end
  end

  def valider
    if @at_dossier_reversion_rente.soumis?
      @at_dossier_reversion_rente.est_valide!
      @at_dossier_reversion_rente.save
      redirect_to [:admin, @demande_arret_travail, @at_dossier_reversion_rente], notice: 'Arret travail was successfully submitted.'
    else
      redirect_to [:admin, @demande_arret_travail, @at_dossier_reversion_rente]
    end
  end


  def update
    respond_to do |format|
      if @at_dossier_reversion_rente.update(at_dossier_reversion_rente.merge(etat: :complete))
        @at_dossier_reversion_rente.etat= :complete
        format.html { redirect_to [:admin, @at_dossier_reversion_rente], notice: 'Reversion veuve was successfully updated.' }
        format.json { render :show, status: :ok, location: @at_dossier_reversion_rente }
      else
        format.html { render :edit }
        format.json { render json: @at_dossier_reversion_rente.errors, status: :unprocessable_entity }
      end
    end
  end



  def etat_ayant_droit_valide
    @at_dossier_reversion_rente.etat_ayant_droit_valide!
    redirect_to [:admin, @at_dossier_reversion_rente]
  end

  def documents_valide
    unless @at_dossier_reversion_rente.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:admin, @at_dossier_reversion_rente]
  end

  def soumettre_dossier
    @at_dossier_reversion_rente.update(etat: :soumis)
    redirect_to [:admin, @at_dossier_reversion_rente]
  end

  def notification
    @at_rente_famille = AtRenteFamille.find(@at_dossier_reversion_rente.at_rente_famille_id)
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Notification No. #{@at_dossier_reversion_rente.id}",
               page_size: 'A4',
               template: "admin/at_dossier_reversion_rentes/notification.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end

  end
 
  def new
    @at_dossier_reversion_rente = AtDossierReversionRente.new
  end

  def edit; end

  def create
   
    @at_dossier_reversion_rente = AtDossierReversionRente.new(at_dossier_reversion_rente_params)
    @at_dossier_reversion_rente.numero_allocataire = @allocataire.numero_allocataire
    @at_dossier_reversion_rente.ajoute_par = current_user
    @at_dossier_reversion_rente.ajouter_le = DateTime.now

    respond_to do |format|
      if @dossier_reversion_salarie.save
        format.html { redirect_to [:admin, @at_dossier_reversion_rente], notice: 'Reversion veuve was successfully created.' }
        format.json { render :show, status: :created, location: @at_dossier_reversion_rente }
      else
        format.html { render :new }
        format.json { render json: @at_dossier_reversion_rente.errors, status: :unprocessable_entity }
      end
    end
  end



  def destroy
    @reversion_veuve.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @at_base_reversion_rente], notice: 'Reversion veuve was successfully destroyed.' }
      format.json { head :no_content }
    end
  end



  def rejeter
    if @at_dossier_reversion_rente.liquide?
      @at_dossier_reversion_rente.est_rejete!
      @at_dossier_reversion_rente.valider_par = current_user
      @at_dossier_reversion_rente.valider_le = DateTime.now
      @at_dossier_reversion_rente.save
      redirect_to [:admin,@at_dossier_reversion_rente], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @at_dossier_reversion_rente]
    end
  end

 




  

  private

  def set_at_dossier_reversion_rente
    @at_dossier_reversion_rente = AtDossierReversionRente.find(params[:id] || params[:at_dossier_reversion_rente_id])
  end

  def set_at_rente_famille
   # @at_rente_famille = @at_dossier_reversion_rente.at_rente_famille
    @at_rente_famille = AtRenteFamille.find(@at_dossier_reversion_rente.at_rente_famille_id)
  end

  def dossier_reversion_salarie_veuve_params
    params.require(:at_dossier_reversion_rente).permit(:arret_travail_id, :type_ayant_droit, :conjoint_id, :enfant_id, :ascendant_id, :phone, :email)
  end
end


