class Admin::AtGuerisonsController < Admin::ApplicationController
  before_action :set_at_guerison, only: [:show, :edit, :update, :destroy, :valider_information_generale, :valider_documents, :soumettre, :validation_chef_agence, :validation_chef_service, :rejet_dossier, :retourner_dossier]
  before_action :set_arret_travail, only: [:create, :new]

  # GET /at_guerisons
  # GET /at_guerisons.json
  def index
    @at_guerisons = AtGuerison.all.page(params[:page]).per(100)
  end

  def en_attente_soumission
    @at_guerisons = AtGuerison.en_attente_soumission.page(params[:page]).per(100)
  end

  def soumis_chef_agence
    @at_guerisons = AtGuerison.soumis_chef_agence.page(params[:page]).per(100)
  end

  def soumis_chef_service
    @at_guerisons = AtGuerison.soumis_chef_service.page(params[:page]).per(100)
  end

  def mes_dossiers_en_creations
    @at_guerisons = AtGuerison.mes_creations(current_user).page(params[:page]).per(100)
  end

  def dossiers_retournes
    @at_guerisons = AtGuerison.mes_dossiers_retournes(current_user).page(params[:page]).per(100)
  end


  # GET /at_guerisons/1
  # GET /at_guerisons/1.json
  def show
    @arret_travail = @at_guerison.arret_travail
  end

  # GET /at_guerisons/new
  def new
    @at_guerison = AtGuerison.new
  end

  # GET /at_guerisons/1/edit
  def edit
    @arret_travail = @at_guerison.arret_travail
  end

  # POST /at_guerisons
  # POST /at_guerisons.json
  def create
    @at_guerison = AtGuerison.new(at_guerison_params)
    @at_guerison.arret_travail= @arret_travail

    respond_to do |format|
      if @at_guerison.save
        format.html { redirect_to [:admin,@arret_travail, @at_guerison], notice: 'Dossier guérison créé avec succès.' }
        format.json { render :show, status: :created, location: @at_guerison }
      else
        format.html { render :new }
        format.json { render json: @at_guerison.errors, status: :unprocessable_entity }
      end
    end
  end



  # PATCH/PUT /at_guerisons/1
  # PATCH/PUT /at_guerisons/1.json
  def update
    @arret_travail = @at_guerison.arret_travail
    respond_to do |format|
      if @at_guerison.update(at_guerison_params)
        format.html { redirect_to [:admin,@arret_travail, @at_guerison], notice: 'At guerison was successfully updated.' }
        format.json { render :show, status: :ok, location: @at_guerison }
      else
        format.html { render :edit }
        format.json { render json: @at_guerison.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /at_guerisons/1
  # DELETE /at_guerisons/1.json
  def destroy
    @at_guerison.destroy
    respond_to do |format|
      format.html { redirect_to [:admin,@at_guerison.arret_travail], notice: 'At guerison was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  # region : valider toutes les infos de la demande
  def valider_information_generale
    @at_guerison.information_generale!
    redirect_to [:admin, @at_guerison], notice: "Les informations de la validation sont validées"
  end

  def valider_documents
    puts "======OKK", @at_guerison.documents_valide!
    unless @at_guerison.documents_valide!
      redirect_to [:admin, @at_guerison]
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    else
      redirect_to [:admin, @at_guerison], notice: 'Les documents sont bien validés'
    end
  end

  def soumettre
    if @at_guerison.creation?
      if @at_guerison.arret_travail.creer_en_agence? 
          @at_guerison.est_soumis_chef_agence!
      else
        @at_guerison.est_soumis_chef_service!
      end
      @at_guerison.date_soumission = DateTime.now
      @at_guerison.soumis_par = current_user
      @at_guerison.motif = nil
      @at_guerison.save
      if @at_guerison.save
        redirect_to [:admin, @at_guerison], notice: 'Dossier soumis avec succés .'
      end
    else
      redirect_to [:admin, @at_guerison]
    end
  end

  def validation_chef_agence
    if @at_guerison.soumis_chef_agence?
      @at_guerison.est_guerison_validee!
      @at_guerison.date_validation = DateTime.now
      @at_guerison.valide_par = current_user
      @at_guerison.motif = nil
      @arret_travail = @at_guerison.arret_travail
      @arret_travail.est_gueris!
      @arret_travail.etat = 'gueris'
      @arret_travail.save
      @at_guerison.save
      if @at_guerison.save
        redirect_to [:admin, @at_guerison], notice: 'Guérison validée avec succés .'
      end
    else
      redirect_to [:admin, @at_guerison]
    end
  end

  def validation_chef_service
    @arret_travail = @at_guerison.arret_travail
    if @at_guerison.soumis_chef_service? and @arret_travail.accepte?
      @at_guerison.est_guerison_validee!
      @at_guerison.date_validation = DateTime.now
      @at_guerison.valide_par = current_user
      @at_guerison.motif = nil
      @arret_travail = @at_guerison.arret_travail
      @arret_travail.est_gueris!
      @arret_travail.etat = 'gueris'
      @arret_travail.save
      @at_guerison.save
      if @at_guerison.save
        redirect_to [:admin, @at_guerison], notice: 'Guérison validée avec succés .'
      end
    else
      redirect_to [:admin, @at_guerison]
    end
  end

  def rejet_dossier
    if at_guerison_motifRetouner_params[:motif].blank? 
      flash[:error] = 'Motif est obligataoire!'
      redirect_to [:admin, @at_guerison]
    else
      @arret_travail = @at_guerison.arret_travail
      if @at_guerison.soumis_chef_service? or @at_guerison.soumis_chef_agence?
        @at_guerison.est_guerison_rejetee!
        @at_guerison.update(at_guerison_motifRetouner_params.merge(date_rejet: DateTime.now, rejete_par: current_user))
        redirect_to [:admin,@at_guerison], notice: 'Guérison a été rejeté avec succés.'
      else
        redirect_to [:admin, @at_guerison]
      end
    end 
  end

  def retourner_dossier
    if at_guerison_motifRetouner_params[:motif].blank? 
      flash[:error] = 'Motif est obligataoire!'
      redirect_to [:admin, @at_guerison]
    else
      @arret_travail = @at_guerison.arret_travail
      if @at_guerison.soumis_chef_service? or @at_guerison.soumis_chef_agence?
        @at_guerison.retour_creation!
        @at_guerison.update(at_guerison_motifRetouner_params)
        redirect_to [:admin,@at_guerison], notice: 'Guérison a été retournée avec succés.'
      else
        redirect_to [:admin, @at_guerison]
      end
    end 

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_at_guerison
      @at_guerison = AtGuerison.find(params[:id] || params[:at_guerison_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def at_guerison_params
      params.require(:at_guerison).permit(:workflow_state, :observation, :date_ouverture_guerison, :ajoute_par_id)
    end

    def set_arret_travail
      @arret_travail = ArretTravail.find(params[:arret_travail_id])
    end

    def at_guerison_motifRetouner_params
      params.require(:at_guerison).permit(:motif)
    end
end
