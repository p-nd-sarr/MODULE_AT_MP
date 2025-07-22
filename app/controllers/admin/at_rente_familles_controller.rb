class Admin::AtRenteFamillesController < Admin::ApplicationController
  before_action :set_at_rente_famille, except: [:create, :new, :index, :soumis_chef_service, :en_attente_soumission, :soumis_chef_agence, :en_attente_verification, :en_attente_validation_dg, :en_attente_validation_dir_at, :en_attente_validation_audit]
  before_action :set_arret_travail, only: [:create, :new ]

  # GET /admin/at_rente_familles
  # GET /admin/at_rente_familles.json
  def index
    @at_rente_familles = AtRenteFamille.all
  end

  def en_attente_soumission
    @at_rente_familles = AtRenteFamille.en_attente_soumission.page(params[:page]).per(100)
  end

  def soumis_chef_agence
    @at_rente_familles = AtRenteFamille.soumis_chef_agence.page(params[:page]).per(100)
  end

  def soumis_chef_service
    @at_rente_familles = AtRenteFamille.soumis_chef_service.page(params[:page]).per(100)
  end

  def en_attente_validation_dir_at
    @at_rente_familles = AtRenteFamille.soumis_dir_at.page(params[:page]).per(100)
  end

  def en_attente_validation_audit
    @at_rente_familles = AtRenteFamille.soumis_audit.page(params[:page]).per(100)
  end

  def en_attente_validation_dg
    @at_rente_familles = AtRenteFamille.soumis_dg.page(params[:page]).per(100)
  end

  # GET /admin/at_rente_familles/1
  # GET /admin/at_rente_familles/1.json
  def show
    @arret_travail = ArretTravail.find(@at_rente_famille.arret_travail_id)
    if @arret_travail.creer_en_agence?
       @techniciens = User.technicien_at # avoir la liste des gestionnaires
    else
      @techniciens = User.technicien_direction_at
    end
    @at_salaire = AtSalaire.new
    @last_salaires = @arret_travail.at_salaires
  end


  # GET /admin/at_rente_familles/new
  def new
    @at_rente_famille = AtRenteFamille.new
  end

  # GET /admin/at_rente_familles/1/edit
  def edit
  end

  # POST /admin/at_rente_familles
  # POST /admin/at_rente_familles.json
  def create
  
    @at_rente_famille = AtRenteFamille.new(at_rente_famille_params)
    @at_rente_famille.arret_travail= @arret_travail
    @at_rente_famille.numero_affiliation= @arret_travail.numero_affiliation
    respond_to do |format|
      if @at_rente_famille.save
        format.html { redirect_to [:admin,@arret_travail, @at_rente_famille], notice: 'Rente famille créée avec succès.' }
        format.json { render :show, status: :created, location: @at_rente_famille }
      else
        format.html { render :new }
        format.json { render json: @at_rente_famille.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/at_rente_familles/1
  # PATCH/PUT /admin/at_rente_familles/1.json
  def update
    respond_to do |format|
      if @at_rente_famille.update(at_rente_famille_params)
        format.html { redirect_to [:admin,@at_rente_famille], notice: 'Rente famille mise à jour avec succès.' }
        format.json { render :show, status: :ok, location: @at_rente_famille }
      else
        format.html { render :edit }
        format.json { render json: @at_rente_famille.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/at_rente_familles/1
  # DELETE /admin/at_rente_familles/1.json
  def destroy
    @at_rente_famille.destroy
    respond_to do |format|
      format.html { redirect_to [:admin,@at_rente_famille], notice: 'Rente famille supprimée avec succès.' }
      format.json { head :no_content }
    end
  end

  # region : valider toutes les infos de la demande
  def valider_information_defunt
  @at_rente_famille.information_defunt!
  redirect_to [:admin, @arret_travail, @at_rente_famille], notice: "Les informations de la validation sont validées"
  end

  def valider_documents
    puts "======OKK", @at_rente_famille.documents_valide!
    unless @at_rente_famille.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:admin,@arret_travail, @at_rente_famille], notice: 'Les documents sont bien validés'
  end

  def valider_epouses
    @at_rente_famille.epouses_valide!
    redirect_to [:admin, @at_rente_famille]
  end

  def valider_enfants
    @at_rente_famille.enfants_valide!
    redirect_to [:admin, @at_rente_famille]
  end

  def valider_information_salaire
    unless @at_rente_famille.information_salaire_valide!
      flash[:error] = "Veuillez entrer les 12 derniers salaires avant la validation"
    end
    redirect_to [:admin, @at_rente_famille]
  end

  def valider_onglet_tableau_rente
    unless @at_rente_famille.tableau_rente_valide!
      flash[:error] = "Veuillez valider le tableau des rentes"
    end
    redirect_to [:admin, @at_rente_famille]
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
   redirect_to [:admin, @arret_travail, @at_rente_famille], notice: 'Salaire was successfully submitted.'
  end

  def soumettre
    if @at_rente_famille.creation?
      if @at_rente_famille.arret_travail.creer_en_agence? 
         @at_rente_famille.est_soumis_chef_agence!
      else
        @at_rente_famille.est_soumis_chef_service!
      end
      @at_rente_famille.date_soumission = DateTime.now
      @at_rente_famille.soumis_par = current_user
      @at_rente_famille.motif = nil
      @at_rente_famille.save
      if @at_rente_famille.save
        #create_reversion_veuve( @at_rente_famille.conjoints)
        #create_reversion_orphelin(@at_rente_famille.enfants)
        redirect_to [:admin, @at_rente_famille], notice: 'Dossier soumis avec succés .'
      end
    else
      redirect_to [:admin, @at_rente_famille]
    end
  end

  def retourner_dossier
    if @at_rente_famille.soumis_chef_agence?
      desactive_onglet(@at_rente_famille)
      @at_rente_famille.retour_creation!
    else
      if @at_rente_famille.soumis_chef_service?
        if @at_rente_famille.arret_travail.creer_en_agence?
          @at_rente_famille.retour_soumis_chef_agence!
        else
          desactive_onglet(@at_rente_famille)
          @at_rente_famille.retour_creation!
        end
      else
        if @at_rente_famille.soumis_directeur_at?
          @at_rente_famille.retour_soumis_chef_service!
        else
          if @at_rente_famille.soumis_dg?
            @at_rente_famille.retour_soumis_directeur_at!
          end
        end
      end
    end
    if @at_rente_famille.update(at_rente_famille_motifRetouner_params)
      redirect_to admin_at_rente_famille_path(@at_rente_famille), notice: 'Dossier retourner avec succés.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end


  def validation_chef_agence
    if @at_rente_famille.soumis_chef_agence?
      @at_rente_famille.est_soumis_chef_service!
      @at_rente_famille.date_validation_chef_agence = DateTime.now
      @at_rente_famille.valide_chef_agence_par = current_user
      @at_rente_famille.motif = nil
      @at_rente_famille.save
      if @at_rente_famille.save
        redirect_to [:admin, @at_rente_famille], notice: 'Dossier soumis avec succés .'
      end
    else
      redirect_to [:admin, @at_rente_famille]
    end
  end

  def validation_chef_service
    if @at_rente_famille.soumis_chef_service?
      @at_rente_famille.est_soumis_directeur_at!
      @at_rente_famille.date_validation_chef_service = DateTime.now
      @at_rente_famille.valide_chef_service_par = current_user
      @at_rente_famille.motif = nil
      @at_rente_famille.save
      if @at_rente_famille.save
        redirect_to [:admin, @at_rente_famille], notice: 'Dossier soumis avec succés .'
      end
    else
      redirect_to [:admin, @at_rente_famille]
    end
  end

  def validation_directeur_at
    if @at_rente_famille.soumis_directeur_at?
      @at_rente_famille.est_soumis_audit!
      @at_rente_famille.date_validation_directeur_at = DateTime.now
      @at_rente_famille.valide_dir_at_par = current_user
      @at_rente_famille.motif = nil
      @at_rente_famille.save
      if @at_rente_famille.save
        redirect_to [:admin, @at_rente_famille], notice: 'Dossier soumis avec succés .'
      end
    else
      redirect_to [:admin, @at_rente_famille]
    end
  end

  def validation_audit
    if @at_rente_famille.soumis_audit?
      @at_rente_famille.est_soumis_dg!
      @at_rente_famille.date_validation_audit = DateTime.now
      @at_rente_famille.validation_audit_par = current_user
      @at_rente_famille.motif = nil
      @at_rente_famille.save
      if @at_rente_famille.save
        redirect_to [:admin, @at_rente_famille], notice: 'Dossier soumis avec succés .'
      end
    else
      redirect_to [:admin, @at_rente_famille]
    end
  end

  def validation_directeur_general
    if @at_rente_famille.soumis_dg?
      arret_travail = @at_rente_famille.arret_travail
      arret_travail.etat = :decede
      arret_travail.save
      @at_rente_famille.est_dossier_valide!
      @at_rente_famille.date_validation_directeur_general = DateTime.now
      @at_rente_famille.valide_dg_par = current_user
      @at_rente_famille.motif = nil
      @at_rente_famille.save
      if @at_rente_famille.save
        redirect_to [:admin, @at_rente_famille], notice: 'Dossier soumis avec succés .'
      end
    else
      redirect_to [:admin, @at_rente_famille]
    end
  end

  def affectation_technicien
    #affecter une consolidation à un technicien
    @at_rente_famille.update(at_rente_famille_affecter_tech_params.merge(date_affectation: DateTime.now, workflow_state: :affectation_technicien))
    redirect_to [:admin, @at_rente_famille], notice: 'Dossier Affecté avec succés.'
  end

  def soumettre_orphelins
    @at_rente_famille.enfants_id=params[:enfants_id]
    if @at_rente_famille.save
      create_reversion_orphelin(params[:enfants_id])
      redirect_to [:admin, @at_rente_famille], notice: 'Liste enfants créée avec succés.'
    else
      redirect_to [:admin, @at_rente_famille], error: 'Error lors de la création des enfants'
    end
  end

  def soumettre_veuves
    puts "OVOVO",at_rente_famille_veuves_params.inspect
    @at_rente_famille.conjoints_id=params[:conjoints_id]
    if @at_rente_famille.save
      create_reversion_veuve(params[:conjoints_id])
      redirect_to [:admin, @at_rente_famille], notice: 'Liste epouse créée avec succés.'
    else
      redirect_to [:admin, @at_rente_famille], error: 'Error lors de la création des conjoints'
    end
  end

  private

  def create_reversion_orphelin(enfants_id)
    AtDossierReversionRente.where(at_rente_famille_id: @at_rente_famille.id, conjoint_id: nil).destroy_all
    unless enfants_id.nil?
      enfants_id.each do |enfant_id|
        puts "===ENF", enfant_id
        demandeur =AtDossierReversionRente.new
        enf = Enfant.find(enfant_id)
        puts "===ENF", enf.inspect
        demandeur.enfant_id=enf.id
        demandeur.conjoint_id=nil
        demandeur.nom = enf.nom
        demandeur.prenom = enf.prenom
        demandeur.date_naissance = enf.date_naissance
        demandeur.numero_affiliation = @at_rente_famille.numero_affiliation
        demandeur.at_rente_famille_id = @at_rente_famille.id
        demandeur.etat = :creation
        demandeur.type_ayant_droit = :orphelin
        demandeur.save!
      end
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
     redirect_to [:admin,@arret_travail, @at_consolidation], notice: 'Salaire was successfully submitted.'
    end

  end

  def create_reversion_veuve(conjoints_id)
    AtDossierReversionRente.where(at_rente_famille_id: @at_rente_famille.id, enfant_id: nil).destroy_all
    unless conjoints_id.nil?
      conjoints_id.each do |conjoint_id|
        demandeur = AtDossierReversionRente.new
        conj = Conjoint.find(conjoint_id)
        puts "===CONF", conj.inspect
        demandeur.enfant_id=nil
        demandeur.conjoint_id=conj.id
        demandeur.nom = conj.nom
        demandeur.prenom = conj.prenom
        demandeur.date_naissance = conj.date_naissance
        demandeur.date_mariage = conj.date_mariage
        demandeur.numero_affiliation = @at_rente_famille.numero_affiliation
        demandeur.etat = :creation
        demandeur.at_rente_famille_id = @at_rente_famille.id
        demandeur.type_ayant_droit = :veuve
        demandeur.save!
      end
    end
  end

  def create_reversion_ascendant_mere(ascendants)
        puts "OKKKKKKK", ascendants.inspect
        unless ascendants.nil?
       ascendants.each do |ascendant|
        demandeur = AtDossierReversionRente.new
        asc = AscendantsSalarie.find(ascendant)
        puts asc.inspect
        demandeur.enfant_id=nil
        demandeur.conjoint_id=nil
        demandeur.ascendants_salarie_id=ascendant
        demandeur.nom = asc.nom_mere
        demandeur.prenom = asc.prenom_mere
       # demandeur.date_naissance = asc.date_naissance
        demandeur.numero_affiliation = @at_base_reversion_rente.numero_affiliation
       # puts "ID", @at_base_reversion_rente.id
        demandeur.etat = :creation
        demandeur.at_base_reversion_rente_id = @at_base_reversion_rente.id
        demandeur.type_ayant_droit = :mere
        #demandeur.ajoute_par = current_user
        #demandeur.ajouter_le = DateTime.now
        demandeur.save!
      end
    end

  end

  def create_reversion_ascendant_pere(ascendants)
    puts "IDDDDDD", ascendants.inspect
    unless ascendants.nil?
       ascendants.each do |ascendant|
        demandeur = AtDossierReversionRente.new
        asc = AscendantsSalarie.find(ascendant)
        demandeur.enfant_id=nil
        demandeur.conjoint_id=nil
        demandeur.ascendants_salarie_id=ascendant
        demandeur.nom = asc.nom_pere
        demandeur.prenom = asc.prenom_pere
       # demandeur.date_naissance = asc.date_naissance
        demandeur.numero_affiliation = @at_base_reversion_rente.numero_affiliation
        demandeur.etat = :creation
        demandeur.at_base_reversion_rente_id = @at_base_reversion_rente.id
        demandeur.etat = :creation
        demandeur.type_ayant_droit = :pere
        #demandeur.ajoute_par = current_user
        #demandeur.ajouter_le = DateTime.now
        demandeur.save!
      end
    end
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_at_rente_famille
      @at_rente_famille = AtRenteFamille.find(params[:id] || params[:at_rente_famille_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def at_rente_famille_params
      params.require(:at_rente_famille).permit(:date_deces, :motif_deces, :arret_travail_id, :ajoute_par_id)
    end
    
    def set_arret_travail
      @arret_travail = ArretTravail.find(params[:arret_travail_id])
    end

    def salaire_params
      params.require(:at_salaire).permit(:mois, :montant, :arret_travail_id, :at_rente_famille_id)
    end

    def at_rente_famille_affecter_tech_params
      params.require(:at_rente_famille).permit(:affectation_technicien)
    end

    def at_rente_famille_orphelins_params
      params.permit(:enfants_id)
    end
    def at_rente_famille_veuves_params
      params.permit(:conjoints_id)
    end
    def at_rente_famille_motifRetouner_params
      params.require(:at_rente_famille).permit(:motif)
    end

    def desactive_onglet(at_rente_famille)
     at_rente_famille.update(information_defunt: false, documents_valide: false, 
                              enfants_valide: false, epouses_valide: false, 
                              information_salaire: false, tableau_rente_valide: false)
    end
end
