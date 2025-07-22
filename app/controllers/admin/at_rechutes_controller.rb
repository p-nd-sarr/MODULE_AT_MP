class Admin::AtRechutesController < Admin::ApplicationController
  before_action :set_at_rechute, except: [:create, :new, :index, :soumis_chef_service, :en_attente_validation_agence, :en_attente_soumission, :en_attente_verification, :en_attente_validation_dir_at, :en_attente_avis_mc]
  before_action :set_arret_travail, only: [:create, :new]

  # GET /admin/at_rente_familles
  # GET /admin/at_rente_familles.json
  def index
    @at_rechutes = AtRechute.all.page(params[:page]).per(100)
  end

  def en_attente_soumission
    @at_rente_familles = AtRechute.en_attente_soumission.page(params[:page]).per(100)
  end

  def en_attente_validation_agence
    @at_rechutes = AtRechute.soumis_chef_agence.page(params[:page]).per(100)
  end

  def soumis_chef_service
    @at_rechutes = AtRechute.soumis_chef_service.page(params[:page]).per(100)
  end

  def en_attente_verification
    @at_rechutes = AtRechute.en_attente_verification.page(params[:page]).per(100)
  end

  def en_attente_validation_dir_at
    @at_rechutes = AtRechute.en_attente_validation_dir_at.page(params[:page]).per(100)
  end

  def en_attente_avis_mc
    @at_rechutes = AtRechute.en_attente_avis_mc.page(params[:page]).per(100)
  end



  # GET /admin/at_rente_familles/1
  # GET /admin/at_rente_familles/1.json
  def show
    @arret_travail = @at_rechute.arret_travail
    if @at_rechute.arret_travail.creer_en_agence?
       @techniciens = User.technicien_at # avoir la liste des gestionnaires
    else
      @techniciens = User.technicien_direction_at
    end
    #@at_salaire = AtSalaire.new
    #@last_salaires = @arret_travail.at_salaires
    @at_code_prime_salaire = AtCodePrimeSalaire.new
  end


  # GET /admin/at_rente_familles/new
  def new
    @at_rechute = AtRechute.new
  end

  # GET /admin/at_rente_familles/1/edit
  def edit
    @arret_travail = @at_rechute.arret_travail
  end

  # POST /admin/at_rente_familles
  # POST /admin/at_rente_familles.json
  def create
    @at_rechute = AtRechute.new(at_rechute_params)
    @at_rechute.arret_travail= @arret_travail
    respond_to do |format|
      if @at_rechute.save
        format.html { redirect_to [:admin,@arret_travail, @at_rechute], notice: 'Rechute créée avec succès.' }
        format.json { render :show, status: :created, location: @at_rechute }
      else
        format.html { render :new }
        format.json { render json: @at_rechute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/at_rente_familles/1
  # PATCH/PUT /admin/at_rente_familles/1.json
  def update
    respond_to do |format|
      if @at_rechute.update(at_rechute_params)
        format.html { redirect_to [:admin, @at_rechute], notice: 'Rente famille mise à jour avec succès.' }
        format.json { render :show, status: :ok, location: @at_rechute }
      else
        format.html { render :edit }
        format.json { render json: @at_rechute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/at_rente_familles/1
  # DELETE /admin/at_rente_familles/1.json
  def destroy
    @at_rechute.destroy
    respond_to do |format|
      format.html { redirect_to [:admin,@at_rechute], notice: 'Rente famille supprimée avec succès.' }
      format.json { head :no_content }
    end
  end

  # region : valider toutes les infos de la demande
  def valider_information_generale
    @at_rechute.information_generale!
    redirect_to [:admin, @arret_travail, @at_rechute], notice: "Les informations de la validation sont validées"
  end

  def valider_documents
    unless @at_rechute.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:admin,@arret_travail, @at_rechute], notice: 'Les documents sont bien validés'
  end

  def valider_avis_mc
    unless @at_rechute.avis_mc_valide!
      flash[:error] = "Veuillez sauvegarder l'avis du MC"
    end
    redirect_to [:admin, @at_rechute], notice: 'Avis MC sont bien validé'
  end



  def valider_information_salaire
    unless @at_rechute.information_salaire_valide!
      flash[:error] = "Veuillez entrer les 12 derniers salaires avant la validation"
    end
    redirect_to [:admin, @at_rechute]
  end

  def add_salaire
    for i in 0..11
      @at_salaire = AtSalaire.new(salaire_params)
      first_month = AtSalaire.mois[@at_salaire.mois]
      next_month=first_month+i 
      @at_salaire.mois=next_month if next_month <= 12
      @at_salaire.mois=next_month-12 if next_month > 12
      @at_salaire.save
   end
   redirect_to [:admin, @arret_travail, @at_rechute], notice: 'Salaire was successfully submitted.'
  end

  def soumettre
    if @at_rechute.creation?
      if @at_rechute.arret_travail.creer_en_agence? 
         @at_rechute.est_soumis_chef_agence!
      else
        @at_rechute.est_soumis_chef_service!
      end
      @at_rechute.date_soumission = DateTime.now
      @at_rechute.soumis_par = current_user
      @at_rechute.motif = nil
      @at_rechute.save
      if @at_rechute.save
        redirect_to [:admin, @at_rechute], notice: 'Dossier soumis avec succés .'
      end
    else
      redirect_to [:admin, @at_rechute]
    end
  end

  def affectation_technicien
    #affecter une consolidation à un technicien
    @at_rechute.update(at_rente_famille_affecter_tech_params.merge(date_affectation: DateTime.now, workflow_state: :affectation_technicien))
    redirect_to [:admin, @at_rechute], notice: 'Dossier Affecté avec succés.'
  end

  def ajouter_element_salaire
    @at_code_prime_salaire = AtCodePrimeSalaire.new(code_prime_salaire_params)
    composant_salaire = Admin::ComposantSalaire.find_by(designation: code_prime_salaire_params[:designation])
    puts "===Info",composant_salaire.prise_en_compte
    @at_code_prime_salaire.prise_en_compte = composant_salaire.prise_en_compte
    @at_code_prime_salaire.code = code_prime_salaire_params[:designation] + "_" + @at_rechute.id.to_s
    if @at_code_prime_salaire.save
      redirect_to [:admin, @at_rechute], notice: 'Elément salaire ajouté avec succés.'
    else
      respond_to do |format|
        format.html { redirect_to [:admin, @at_rechute], alert: 'Erreur ajout element salaire.' }
      end
    end
    
  end

  def validation_chef_agence
    if @at_rechute.soumis_chef_agence?
      @at_rechute.est_soumis_mc!
      @at_rechute.date_validation = DateTime.now
      @at_rechute.valide_par = current_user
      @at_rechute.motif = nil
      @at_rechute.save
      if @at_rechute.save
        redirect_to [:admin, @at_rechute], notice: 'Rechute validée avec succés .'
      end
    else
      redirect_to [:admin, @at_rechute]
    end
  end

  def validation_chef_service
    if @at_rechute.soumis_chef_service?
      @at_rechute.est_soumis_mc!
      @at_rechute.date_validation = DateTime.now
      @at_rechute.valide_par = current_user
      @at_rechute.motif = nil
      @at_rechute.save
      if @at_rechute.save
        redirect_to [:admin, @at_rechute], notice: 'Rechute validée avec succés .'
      end
    else
      redirect_to [:admin, @at_rechute]
    end
  end

  def validation_avis_mc
    if @at_rechute.soumis_mc?
      @at_rechute.est_soumis_directeur_at!
      @at_rechute.date_validation_mc = DateTime.now
      @at_rechute.valide_par = current_user
      @at_rechute.motif = nil
      @at_rechute.save
      if @at_rechute.save
        redirect_to [:admin, @at_rechute], notice: 'Rechute validée avec succés .'
      end
    else
      redirect_to [:admin, @at_rechute]
    end
  end

  def validation_directeur_at
    @arret_travail = @at_rechute.arret_travail
    if @at_rechute.soumis_directeur_at? and @arret_travail.gueris?
      @arret_travail.est_rechute!
      @arret_travail.affectation_at = nil
      @arret_travail.etat = 'rechute'
      @arret_travail.save
      @at_rechute.est_rechute_validee!
      @at_rechute.date_validation_mc = DateTime.now
      @at_rechute.valide_par = current_user
      @at_rechute.motif = nil
      @at_rechute.save
      if @at_rechute.save
        redirect_to [:admin, @at_rechute], notice: 'Rechute validée avec succés .'
      end
    else
      redirect_to [:admin, @at_rechute]
    end
  end

  def rejet_directeur_at
    if @at_rechute.soumis_directeur_at?
      @at_rechute.est_rechute_rejetee!
      @at_rechute.date_validation_mc = DateTime.now
      @at_rechute.valide_par = current_user
      @at_rechute.motif = nil
      @at_rechute.save
      if @at_rechute.save
        redirect_to [:admin, @at_rechute], notice: 'Rechute validée avec succés .'
      end
    else
      redirect_to [:admin, @at_rechute]
    end
  end


  def retourner_dossier
    if at_rechute_motifRetouner_params[:motif].blank? 
      flash[:error] = 'Motif est obligataoire!'
      redirect_to [:admin, @at_rechute]
    else
      @arret_travail = @at_rechute.arret_travail
      if @at_rechute.soumis_chef_service? or @at_rechute.soumis_chef_agence?
        @at_rechute.retour_creation!
        @at_rechute.update(at_rechute_motifRetouner_params)
        redirect_to [:admin,@at_rechute], notice: 'Rechute a été retournée avec succés.'
      else
        redirect_to [:admin, @at_rechute]
      end
    end 

  end

  def rejet_dossier
    if at_rechute_motifRetouner_params[:motif].blank? 
      flash[:error] = 'Motif est obligataoire!'
      redirect_to [:admin, @at_rechute]
    else
      @arret_travail = @at_rechute.arret_travail
      if @at_rechute.soumis_directeur_at?
        @at_rechute.est_rechute_rejetee!
        @at_rechute.update(at_rechute_motifRetouner_params.merge(date_rejet_rechute: DateTime.now, rejete_par: current_user))
        redirect_to [:admin,@at_rechute], notice: 'Rechute a été rejeté avec succés.'
      else
        redirect_to [:admin, @at_rechute]
      end
    end 
  end

  

  private


    # Use callbacks to share common setup or constraints between actions.
    def set_at_rechute
      @at_rechute = AtRechute.find(params[:id] || params[:at_rechute_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def at_rechute_params
      params.require(:at_rechute).permit(:observation, :date_rechute, :arret_travail_id, :avis, :description_avis)
    end
    
    def set_arret_travail
      @arret_travail = ArretTravail.find(params[:arret_travail_id])
    end

    def salaire_params
      params.require(:at_salaire).permit(:mois, :montant, :arret_travail_id, :at_rechute_id)
    end

    def at_rente_famille_affecter_tech_params
      params.require(:at_rechute).permit(:affectation_technicien)
    end
    def code_prime_salaire_params
      params.require(:at_code_prime_salaire).permit(:designation, :montant, :type_frais, :at_rechute_id)
    end
    def at_rechute_motifRetouner_params
      params.require(:at_rechute).permit(:motif)
    end

  
end
