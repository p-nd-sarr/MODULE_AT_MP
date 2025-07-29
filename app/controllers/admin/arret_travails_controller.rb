class Admin::ArretTravailsController < Admin::ApplicationController
  INFO_SALARIE_PAGE = 'information_salarie'.freeze
  INFO_PRO_SALARIE_PAGE = 'information_pro_salarie'.freeze
  INFO_EMPLOYEUR_PAGE = 'information_employeur'.freeze
  INFO_ACCIDENT_PAGE = 'information_accident'.freeze
  INFO_DOCUMENT_PAGE = 'information_document'.freeze
  INFO_LESION_PAGE = 'information_lesion'.freeze
  INFO_INCAPACITE_PAGE = 'information_incapacite'.freeze
  INFO_FRAIS_ENGAGE_PAGE = 'information_frais_engage'.freeze
  INFO_PRIME_SALAIRE_PAGE = 'information_prime_salaire'.freeze
  INFO_AVIS_PAGE = 'information_avis'.freeze
  INFO_SALAIRE_PAGE = '_information_les_12_derniers_salaires'.freeze
  INFO_CONSOLIDATION_PAGE = 'information_consolidation'.freeze
  before_action :set_admin_arret_travail, only: [:show, :edit, :update, :destroy, :recipisse_dossier]
  # Dans le contrôleur - remplacer la méthode index par :
  
def index  
  @est_mp = params[:est_mp].to_s == 'true'  # Conversion en booléen
  
  atmp = ArretTravail.all.not_deleted.where(est_mp: @est_mp) 
  
  @q = atmp.ransack(params[:q])
  @demande_arret_travails = @q.result.page(params[:page]).order('created_at DESC').per(100)
end

  def en_creation
    @demande_arret_travails = ArretTravail.where(user_id: current_user).en_creation.page(params[:page]).per(100)
  end

  def en_attente_soumis_chef_agence
    @demande_arret_travails = ArretTravail.en_attente_soumis_chef_agence.page(params[:page]).per(100)
  end

  def en_attente_instruction
    @demande_arret_travails= ArretTravail.en_attente_instruction.page(params[:page]).per(100)
  end

  def en_attente_affectation_redacteur
    @demande_arret_travails = ArretTravail.where(affecte_a: nil).en_attente_affectation_redacteur.page(params[:page]).per(100)
  end

  def en_attente_avis_redacteur
    @demande_arret_travails = ArretTravail.where(affecte_a: current_user).en_attente_avis_redacteur.page(params[:page]).per(100)
  end
  def en_attente_avis_dajc
    @demande_arret_travails = ArretTravail.en_attente_avis_dajc.page(params[:page]).per(100)
  end
  
  def en_attente_avis_chef_service_at
    @demande_arret_travails = ArretTravail.en_attente_avis_chef_service_at.page(params[:page]).per(100)
  end
  def en_attente_avis_dprp
    @demande_arret_travails = ArretTravail.en_attente_avis_dprp.page(params[:page]).per(100)
  end

  def en_attente_avis_medecin
    @demande_arret_travails = ArretTravail.en_attente_avis_medecin.page(params[:page]).per(100)
  end

  def en_attente_information
    @demande_arret_travails = ArretTravail.en_attente_information.page(params[:page]).per(100)
  end

  def en_attente_soumission_dir_at
    @demande_arret_travails = ArretTravail.en_attente_soumission_dir_at.page(params[:page]).per(100)
  end

  def en_attente_acceptation
    @demande_arret_travails = ArretTravail.en_attente_acceptation.page(params[:page]).per(100)
  end

  def en_attente_affectation_technicien
    if current_user.chef_agence?
      @demande_arret_travails = ArretTravail.where(affectation_at: nil).en_attente_affectation_technicien_agence.page(params[:page]).per(100)
    else
      @demande_arret_travails = ArretTravail.where(affectation_at: nil).en_attente_affectation_technicien_direction.page(params[:page]).per(100)
    end
  end

  def en_attente_soumission_liquidation
  est_mp = params[:est_mp].to_s == 'true'  # Convertir le paramètre en booléen

  base = ArretTravail.where(affectation_at: current_user.id)  # Base commune

  if current_user.technicien_at?
    base = base.en_attente_affectation_technicien_agence
  else
    base = base.affected_tech
               .en_attente_affectation_technicien_direction
               .where(creer_par_ag_direction_at: true)
               .where(affectation_at: current_user)
  end

  # Filtrer selon MP / AT
  @demande_arret_travails = base.where(est_mp: est_mp)
                               .page(params[:page]).per(100)
end


  def en_attente_validation_ij
    @demande_arret_travails = ArretTravail.en_attente_validation_ij.page(params[:page]).per(100)
  end

  def en_attente_validation_ij_mp
    @demande_arret_travails = ArretTravail.en_attente_validation_ij_mp.page(params[:page]).per(100)
     render 'en_attente_validation_ij'  # ← Ajouter cette ligne
  end

  def en_attente_validation_frais
    @demande_arret_travails = ArretTravail.en_attente_validation_frais.page(params[:page]).per(100)
  end
  
  def en_attente_validation_frais_mp
    @demande_arret_travails = ArretTravail.en_attente_validation_frais_mp.page(params[:page]).per(100)
     render 'en_attente_validation_frais'
  end

  

  def en_attente_validation_mc_ij
    @demande_arret_travails = ArretTravail.en_attente_validation_mc_ij.page(params[:page]).per(100)
  end

  def en_attente_validation_mc_frais
    @demande_arret_travails = ArretTravail.en_attente_validation_mc_frais.page(params[:page]).per(100)
  end

  def en_attente_validation_comptable
    @demande_arret_travails = ArretTravail.en_attente_validation_comptable_scope #+ ArretTravail.en_attente_validation_comptable_ij
  end

  def en_attente_validation_comptable_ij
    @demande_arret_travails = ArretTravail.en_attente_validation_comptable_scope + ArretTravail.en_attente_validation_comptable_ij
  end

  def en_attente_validation_comptable_frais
    @demande_arret_travails = ArretTravail.en_attente_validation_comptable_frais.page(params[:page]).per(100)
  end

  def en_attente_commission_rejets
    @demande_arret_travails = ArretTravail.where(affecte_a: current_user).soumis_commission_rejet.page(params[:page]).per(100)
  end

  def en_attente_retour_commission_saisi
    @demande_arret_travails = ArretTravail.retour_commission_saisi.page(params[:page]).per(100)
  end


  def consolidations_validees
    @at_consolidations = AtConsolidation.valides_consolidations.page(params[:page]).per(100)
  end

  def en_attente_validation_reouverture_dossier
    @demande_arret_travails = ArretTravail.en_attente_validation_reouverture_dossier.page(params[:page]).per(100)
  end

  def en_attente_soumission_rechutes
    @demande_arret_travails = ArretTravail.soumission_rechutes.page(params[:page]).per(100)
  end

  def en_attente_validation_rechutes_mc
    @demande_arret_travails = ArretTravail.en_attente_validation_rechutes_mc.page(params[:page]).per(100)
  end

  def en_attente_validation_rechutes
    @demande_arret_travails = ArretTravail.en_attente_validation_rechutes.page(params[:page]).per(100)
  end

  def en_attente_reouverture_dossier
    @demande_arret_travails = ArretTravail.en_attente_reouverture_dossier.page(params[:page]).per(100)
  end

  def en_attente_validation_cloture_dossier
    @demande_arret_travails = ArretTravail.en_attente_validation_cloture_dossier.page(params[:page]).per(100)
  end
  def en_attente_cloture_dossier
    @demande_arret_travails = ArretTravail.en_attente_cloture_dossier.page(params[:page]).per(100)
  end

  def en_attente_validation_cloture_dossier_tech
    @demande_arret_travails = ArretTravail.en_attente_validation_cloture_dossier_tech.page(params[:page]).per(100)
  end

  def dossiers_clotures
    @demande_arret_travails = ArretTravail.dossiers_clotures.page(params[:page]).per(100)
  end

  def dossiers_reouverts
    @demande_arret_travails = ArretTravail.dossiers_reouverts.page(params[:page]).per(100)
  end

  def en_attente_confirmation_consolidation
    @demande_arret_travails = ArretTravail.en_attente_confirmation_consolidation.page(params[:page]).per(100)
  end

  def dossiers_rct
    @demande_arret_travails = ArretTravail.dossiers_rct.page(params[:page]).per(100)
  end

  def dossiers_rejetes
    @demande_arret_travails = ArretTravail.dossiers_rejetes.page(params[:page]).per(100)
  end

  def en_attente_validation_medecin
    @demande_arret_travails = ArretTravail.en_attente_validation_medecin_scope.page(params[:page]).per(100)
  end

  def en_attente_annulation_guerison
    @demande_arret_travails = ArretTravail.en_attente_annulation_guerison.page(params[:page]).per(100)
  end

  def en_attente_affectation_dossoer_rechute
    if current_user.chef_agence?
      @demande_arret_travails = ArretTravail.where(affectation_at: nil).en_attente_affectation_rechute_agence.page(params[:page]).per(100)
    else
      @demande_arret_travails = ArretTravail.where(affectation_at: nil).en_attente_affectation_rechute_dir.page(params[:page]).per(100)
    end
  end

  def en_attente_liquidation_dossoer_rechute
    @demande_arret_travails = ArretTravail.where(affectation_at: current_user.id).en_attente_liquidation_dossoer_rechute.page(params[:page]).per(100)
  end
  



  # GET /admin/arret_travails/1
  def show
  @demande_arret_travail = ArretTravail.find(params[:id]) # Utilisez le bon modèle (à remplacer si nécessaire)

  # Initialiser les ordres de paiement frais (exemple, à adapter selon votre modèle et filtres)
  @payment_orders_fr = @demande_arret_travail.ordre_paiements.where(statut: [:paye, :en_cours]).includes(:compta_transactions).page(params[:page])
  
  # Rassembler les transactions liées aux paiements frais
  @transactions_fr = @payment_orders_fr.flat_map(&:compta_transactions)

  # Initialiser les ordres de paiement indemnités (idem, à adapter)
  @payment_orders_dpt = @demande_arret_travail.ordre_paiements.where(statut: [:paye, :en_cours]).includes(:compta_transactions).page(params[:page])
  
  # Rassembler les transactions liées aux paiements indemnités
  @transactions_dpt = @payment_orders_dpt.flat_map(&:compta_transactions)

  # Autres initialisations nécessaires pour la vue...
  @at_document = AtDocument.new
  @at_lesion = AtLesion.new
  @at_carnet = AtCarnet.new

  @at_incapacite = AtIncapacite.new
  @at_incapacite.date_debut = @demande_arret_travail.date_accident + 1.day
  @at_incapacite.date_fin = @demande_arret_travail.date_accident + 2.days

  @at_frais_engage = AtFraisEngage.new
  @at_code_prime_salaire = AtCodePrimeSalaire.new
  @at_avi = AtAvi.new
  @at_decompte = AtDecompte.new
  @at_consolidation = AtConsolidation.new
  @at_salaire = AtSalaire.new

  @info_salaries = Psrm::Participant.find_by(matric: @demande_arret_travail.numero_affiliation)
  @employeur = @demande_arret_travail.infos_employeur
  @est_mp = @demande_arret_travail.est_mp
end

  def edit
    #edit
  end


  def new
    if current_user.admin?
      respond_to do |format|
        format.html { redirect_to admin_arret_travails_path, notice: "Un admin ne peut creer de dossier AT, Merci de vous connecter en tant que AGENT_ACCUEIL" } 
      end
    end

    @demande_arret_travail = ArretTravail.new
    @demande_arret_travail.est_mp = (params[:est_mp] == 'true')
    @demande_arret_travail.at_lesions.build
    @at_document = AtDocument.new
    #@demande_arret_travail.at_documents.build
  end



  def affectation_multiple
    update_selected(params[:at_ids],params[:user_id])
    respond_to do |format|
      format.html { redirect_to admin_arret_travails_path, notice: 'La selection a été bien affectée .'
     }
      format.json { head :no_content }
    end


  end

  def user_affectation_aleatoire
    at_non_affecter = ArretTravail.not_affected
    redacteurs_id = []
    techniciens_at_id = []
    redacteurs_id = User.redacteur.map(&:id) unless at_non_affecter.empty?
    if current_user.chef_division_at?
      techniciens_at_id = User.technicien_direction_at.map(&:id) unless at_non_affecter.empty? 
    else
      techniciens_at_id = User.technicien_at.where(agence: current_user.agence).map(&:id) unless at_non_affecter.empty? 
    end
    at_non_affecter.each do |at|
      if at.accepte or at.rechute?
        at.update(affectation_at: techniciens_at_id.shuffle.first)
      else
        at.update(affecte_a: redacteurs_id.shuffle.first)
      end
    end

    respond_to do |format|
      format.html {  redirect_to [:admin, @demande_arret_travail], notice: "#{at_non_affecter.size} Dossier At affecté avec succés." }
      format.json { head :no_content }
    end
  end

  def user_affectation
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.accepte? or @demande_arret_travail.rechute?
      @demande_arret_travail.update(affectation_at: params[:user_id])
      respond_to do |format|
        format.html {  redirect_to [:admin, @demande_arret_travail], notice: 'dossier AT affecté avec succés.' }
        format.json { head :no_content }
      end
    else
      @demande_arret_travail.update(affecte_a: params[:user_id], date_affectation_redacteur: DateTime.now, traite_par: current_user, workflow_state: :affecte_redacteur)
      
      respond_to do |format|
        format.html {  redirect_to [:admin, @demande_arret_travail], notice: 'Dossier AT affecté avec succés.' }
        format.json { head :no_content }
      end

    end
  end

   # GET /admin/arret_travails/1/edit
  def edit
   @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id]  )
  end

  def create
   @demande_arret_travail = ArretTravail.new(arret_travail_params)
   @demande_arret_travail.user_id = current_user.id
   @demande_arret_travail.etat = 'instruction'
   if current_user.agent_accueil_direction_at?
     @demande_arret_travail.etat = 'instruction'
     @demande_arret_travail.creer_par_ag_direction_at = true
   end
   if @demande_arret_travail.save
     desc = "Création du dossier AT n° #{@demande_arret_travail.num_dossier} par #{current_user.email} (#{current_user.type_profil})"
     ajouter_event(@demande_arret_travail, current_user, desc)
     redirect_to [:admin, @demande_arret_travail], notice: 'Dossier est créé avec succès.'
   else
     render :new
   end
  end

  def update
   if params[:custom_page] != nil
     case params[:custom_page]
     when INFO_SALARIE_PAGE
       update_salarie_info
     when INFO_PRO_SALARIE_PAGE
       update_pro_salarie_info
     when INFO_EMPLOYEUR_PAGE
       update_employeur_info
     when INFO_ACCIDENT_PAGE
       update_accident_info
     when INFO_DOCUMENT_PAGE
       update_document_info
     when INFO_LESION_PAGE
       update_lesion_info
     when INFO_INCAPACITE_PAGE
       update_incapacite_info
     when INFO_FRAIS_ENGAGE_PAGE
       update_frais_engage_info
     when INFO_PRIME_SALAIRE_PAGE
       update_prime_salaire_info
     when INFO_AVIS_PAGE
       update_avis_info
     when INFO_SALAIRE_PAGE
       update_salaires_info
     end
   else
     @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id]  )
     if @demande_arret_travail.update(arret_travail_params)
       redirect_to [:admin, @demande_arret_travail], notice: 'Dossier At est bien mis à jour.'
     else
       render :edit
     end
   end


  end




  def delete_lesion
   @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
   @at_lesion = AtLesion.find(params[:id])
   respond_to do |format|
     if(@at_lesion.delete)
       desc = "Suppression d'une lesion du dossier AT n° #{@demande_arret_travail.num_dossier} par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)
       format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Lesion successfully deleted.' }
     else
       format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Lesion not deleted.' }
     end
   end
  end

  def delete_salaire
   @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
   @at_salaire = AtSalaire.find(params[:id])
   respond_to do |format|
     if (@at_salaire.delete)
       desc = "Suppression d'une lesion du dossier AT n° #{@demande_arret_travail.num_dossier} par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)
       format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Salaire successfully deleted.' }
     else
       format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Salaire not deleted.' }
     end
   end
  end

  def recipisse_dossier
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Récépissé du dossier d'arret de travail No. #{@demande_arret_travail.id}",
               page_size: 'A4',
               template: "admin/arret_travails/recipisse_dossier.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def validate_onglet

    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    case params[:custom_page]
    when INFO_SALARIE_PAGE
      valid_onglet(@demande_arret_travail, { info_salarie_valid: true }, INFO_SALARIE_PAGE)
    when INFO_PRO_SALARIE_PAGE
      valid_onglet(@demande_arret_travail, { info_pro_salarie_valid: true }, INFO_PRO_SALARIE_PAGE)
    when INFO_EMPLOYEUR_PAGE
     valid_onglet(@demande_arret_travail, { info_employeur_valid: true }, INFO_EMPLOYEUR_PAGE)
   when INFO_ACCIDENT_PAGE
     valid_onglet(@demande_arret_travail, { detail_accident_valid: true }, INFO_ACCIDENT_PAGE)
   when INFO_DOCUMENT_PAGE
     valid_onglet(@demande_arret_travail, { document_valid: true }, INFO_DOCUMENT_PAGE)
   when INFO_FRAIS_ENGAGE_PAGE
     valid_onglet(@demande_arret_travail, { frais_indemnité_valid: true }, INFO_FRAIS_ENGAGE_PAGE)
   end
  end

  def valid_onglet(demande_arret_travail, parameter, information)
   respond_to do |format|
     if(demande_arret_travail.update!(parameter))
       desc = "Validation de l'onglet #{information} du dossier AT n° #{demande_arret_travail.num_dossier} par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(demande_arret_travail, current_user, desc)
       format.html { redirect_to admin_arret_travail_path(demande_arret_travail), notice: "#{information} successfully validated." }
     else
       format.html { redirect_to admin_arret_travail_path(demande_arret_travail), alert: "#{information} not validated." }
     end
   end
  end
  
  def delete_frais_engage
   @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
   @at_frais_engage = AtFraisEngage.find(params[:id])
   respond_to do |format|
     if(@at_frais_engage.delete)
       desc = "Suppression d'un frais engagé du dossier AT n° #{@demande_arret_travail.num_dossier} par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)
       format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Frais engagé successfully deleted.' }
     else
       format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Frais engagé not deleted.' }
     end
   end
  end

  def delete_prime_salaire
   @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
   @item = AtCodePrimeSalaire.find(params[:id])
   respond_to do |format|
     if(@item.delete)
       desc = "Suppression d'un prime de salaire (avec reinitilialisation calcul) du dossier AT n° #{@demande_arret_travail.num_dossier} par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)
       #@demande_arret_travail.reinit_calcul
       format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Code prime salaire successfully deleted.' }
     else
       format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Code prime salaire not deleted.' }
     end
   end
  end

  

  def destroy
   @demande_arret_travail.update(deleted: true)
   desc = "Suppression logique du dossier AT n° #{@demande_arret_travail.num_dossier} par #{current_user.email} (#{current_user.type_profil})"
   ajouter_event(@demande_arret_travail, current_user, desc)
   respond_to do |format|
     format.html { redirect_to admin_arret_travails_path, notice: 'Arret travail was successfully deleted.' }
     format.json { head :no_content }
   end

  end

  def soumission_form
   @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
   @demande_arret_travail.update(etat: :en_instruction)
   @demande_arret_travail.update(etat: :en_attente_information) if @demande_arret_travail.creer_par_ag_direction_at
   respond_to do |format|
     desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef d'agence (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
     if @demande_arret_travail.creer_par_ag_direction_at
       desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef de service AT (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
     end
     ajouter_event(@demande_arret_travail, current_user, desc)
     format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.' }
     format.json { head :no_content }
   end
  end

  def soumettre
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.creation?
      if current_user.agent_accueil_direction_at?
         @demande_arret_travail.est_soumis_chefService!
      else
        @demande_arret_travail.est_en_instruction!
      end

      @demande_arret_travail.date_soumission = DateTime.now
      @demande_arret_travail.soumis_par = current_user
      @demande_arret_travail.motif = nil
      @demande_arret_travail.save
      desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef atmp (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
      ajouter_event(@demande_arret_travail, current_user, desc)
      redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end

  def soumettre_avis_redacteur
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.affecte_redacteur?
      @demande_arret_travail.est_avis_redacteur!
      @demande_arret_travail.date_soumission_redacteur = DateTime.now
      @demande_arret_travail.motif = nil
      @demande_arret_travail.save
      redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Avis a été bien soumis.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end


  def soumettre_avis_dajc
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.avis_redacteur?
      @demande_arret_travail.workflow_state = :avis_dajc
      @demande_arret_travail.date_soumission_dajc = DateTime.now
      @demande_arret_travail.motif = nil
      @demande_arret_travail.save
      redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Avis a été bien soumis.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end

  def soumettre_avis_chefService
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.avis_dajc?
      @demande_arret_travail.date_soumission_avis_chef_service = DateTime.now
      @demande_arret_travail.est_avis_chefService!
      @demande_arret_travail.motif = nil
      @demande_arret_travail.save
      redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Avis a été bien soumis.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end

  def soumission_chef_atmp
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.en_instruction?
      @demande_arret_travail.est_soumis_chefService!
      @demande_arret_travail.date_soumission_chef_service = DateTime.now
      @demande_arret_travail.soumis_chef_div_at_par = current_user
      @demande_arret_travail.motif = nil
      @demande_arret_travail.save
      desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef atmp (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
      ajouter_event(@demande_arret_travail, current_user, desc)
      redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end

  def soumission_chef_division_at
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.en_instruction?
      @demande_arret_travail.est_soumis_chefService!
      desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef atmp (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
      ajouter_event(@demande_arret_travail, current_user, desc)
      @demande_arret_travail.date_soumission_chef_service = DateTime.now
      @demande_arret_travail.soumis_chef_div_at_par = current_user
      @demande_arret_travail.motif = nil
      @demande_arret_travail.save
      redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end 

 

  def soumission_directeur
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.avis_chefService?
      @demande_arret_travail.est_soumis_directeur!
      @demande_arret_travail.date_soumission_dir_at = DateTime.now
      @demande_arret_travail.soumis_dir_at_par = current_user
      @demande_arret_travail.motif = nil
      @demande_arret_travail.save
      desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef atmp (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
      ajouter_event(@demande_arret_travail, current_user, desc)
      redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end
   
  def directeur_accepte
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.soumis_directeur? or @demande_arret_travail.avis_comite?
       @demande_arret_travail.est_accepte!
       @demande_arret_travail.date_acceptation = DateTime.now
       @demande_arret_travail.accepte_par = current_user
       @demande_arret_travail.etat = :accepte
       @demande_arret_travail.decision_commission_rejet = nil
       @demande_arret_travail.motif = nil
       @demande_arret_travail.save
       desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef atmp (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)
       redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.'
     else
       redirect_to [:admin, @demande_arret_travail]
     end
  end

  def directeur_rejete
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.soumis_directeur?
       @demande_arret_travail.est_soumis_comite!
       @demande_arret_travail.date_rejet_dossier = DateTime.now
       @demande_arret_travail.traite_par = current_user
       @demande_arret_travail.save
       desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef atmp (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)
       redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.'
     else
       redirect_to [:admin, @demande_arret_travail]
     end
  end

  def decision_commission_rejet
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id] )
    if @demande_arret_travail.soumis_comite?
      @demande_arret_travail.est_avis_comite!
      if @demande_arret_travail.update(decision_commission_rejet_params.merge(date_soumission_comite: DateTime.now, traite_par: current_user))
        desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef atmp (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
        ajouter_event(@demande_arret_travail, current_user, desc)
        redirect_to [:admin, @demande_arret_travail], notice: 'decision commission soumise !!!.' 
      end
    end
  end

  def liquidation_soumis
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.accepte?
       @demande_arret_travail.est_liquidation_soumis!
       @demande_arret_travail.traite_le = DateTime.now
       @demande_arret_travail.traite_par = current_user
       @demande_arret_travail.save
       desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef atmp (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)
       redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.'
     else
       redirect_to [:admin, @demande_arret_travail]
     end
  end

  def validation_medecin
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id])
    if @demande_arret_travail.liquidation_soumis?
       @demande_arret_travail.est_validation_medecin!
       @demande_arret_travail.traite_le = DateTime.now
       @demande_arret_travail.traite_par = current_user
       @demande_arret_travail.save
       desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef atmp (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)
       redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.'
     else
       redirect_to [:admin, @demande_arret_travail]
     end
  end

  def liquidation_valide
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.validation_medecin? or @demande_arret_travail.liquidation_soumis?
       @demande_arret_travail.est_liquidation_valide!
       @demande_arret_travail.traite_le = DateTime.now
       @demande_arret_travail.traite_par = current_user
       @demande_arret_travail.save
       desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef atmp (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)
       redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.'
     else
       redirect_to [:admin, @demande_arret_travail]
     end
  end

  def validation
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id])
    if @demande_arret_travail.liquidation_valide?
       @demande_arret_travail.est_validation_comptable!
       @demande_arret_travail.traite_le = DateTime.now
       @demande_arret_travail.traite_par = current_user
       @demande_arret_travail.save
       redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.'
     else
       redirect_to [:admin, @demande_arret_travail]
     end
  end
 

  def liquidation_frais_engages
    frais_engage = AtFraisEngage.find(params[:id])
    @demande_arret_travail = frais_engage.arret_travail
    frais_engage.date_liquidation = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
    frais_engage.etat = :liquidation
    if frais_engage.save
      render_infos(@demande_arret_travail, params[:anchor_tag])
    end
  end


  def acceptation_commission
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
      if @demande_arret_travail.rejete?
        @demande_arret_travail.est_soumis_directeur!
        @demande_arret_travail.date_acceptation = DateTime.now
        @demande_arret_travail.accepte_par = current_user
        @demande_arret_travail.decision_commission_rejet = nil
        @demande_arret_travail.motif = nil
        @demande_arret_travail.save
        desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef atmp (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
        ajouter_event(@demande_arret_travail, current_user, desc)
        redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.'
     else
       redirect_to [:admin, @demande_arret_travail]
     end
  end

  def rejet_commission
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.avis_comite?
       @demande_arret_travail.est_dossier_rejete!
       @demande_arret_travail.traite_le = DateTime.now
       @demande_arret_travail.traite_par = current_user
       @demande_arret_travail.etat = :rejete
       @demande_arret_travail.motif = nil
       @demande_arret_travail.save
       desc = "Dossier AT n° #{@demande_arret_travail.num_dossier} soumis au chef atmp (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)
       redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Arret travail was successfully submitted.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end

  def liquidation_tous_frais_engages
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    at_frais_engages = @demande_arret_travail.at_frais_engages.can_be_liquidated
    at_frais_engages.each do |at_frais_engage|
      if at_frais_engage.liquider!(current_user)
        desc = "Frais engagés n° #{at_frais_engage.id} du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) liquidé par #{current_user.email} (#{current_user.type_profil})"
        ajouter_event(@demande_arret_travail, current_user, desc)
      end
    end
    render_infos(@demande_arret_travail)
  end

=begin
  def liquidation_tous_frais_engages
#    render json: params
#  return
   @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
   frais_engages = @demande_arret_travail.at_frais_engages.where(date_liquidation: nil)
   frais_engages.each do |frais_engage|
     frais_engage.date_liquidation = DateTime.now.to_date.strftime("%d/%m/%Y").to_s
     frais_engage.etat = :liquidation
     if frais_engage.save
       desc = "Frais engages n° #{frais_engage.numero} du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) liquidé par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)

     end
   end
   render_infos(@demande_arret_travail, params[:anchor_tag])
  end
=end

  def validation_frais_engages
   frais_engage = AtFraisEngage.find(params[:id])
   @demande_arret_travail = frais_engage.arret_travail
   frais_engage.date_validation = DateTime.now.to_date
   frais_engage.etat = :validation
   if frais_engage.save
     desc = "Frais engages n° #{frais_engage.numero} du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) validé par #{current_user.email} (#{current_user.type_profil})"
     ajouter_event(@demande_arret_travail, current_user, desc)
     render_infos(@demande_arret_travail, params[:anchor_tag])
   end
  end
  def validation_tous_frais_engages
   # render json: params
   #  return
   @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
   frais_engages = @demande_arret_travail.at_frais_engages.where(date_validation: nil)
   frais_engages.each do |frais_engage|
     frais_engage.date_validation = DateTime.now.to_date
     frais_engage.etat = :validation
     if frais_engage.save
       desc = "Frais engages n° #{frais_engage.numero} du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) validé par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)

     end
   end
   render_infos(@demande_arret_travail, params[:anchor_tag])
  end

  def validation_at_frais_engages_medecin
   frais_engage = AtFraisEngage.find(params[:id])
   @demande_arret_travail = frais_engage.arret_travail
   frais_engage.date_validation_medecin = DateTime.now.to_date
   frais_engage.etat = :validation_medecin
   if frais_engage.save
     desc = "Frais engages n° #{frais_engage.numero} du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) validé par #{current_user.email} (#{current_user.type_profil})"
     ajouter_event(@demande_arret_travail, current_user, desc)
     render_infos(@demande_arret_travail, params[:anchor_tag])
   end
  end


  def validation_at_frais_engages_comptable
     frais_engage = AtFraisEngage.find(params[:id])
     @demande_arret_travail = frais_engage.arret_travail
     frais_engage.date_validation_comptable = DateTime.now.to_date
     frais_engage.etat = :validation_comptable
     if frais_engage.save
       desc = "Frais engages n° #{frais_engage.numero} du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) validé par #{current_user.email} (#{current_user.type_profil})"
       ajouter_event(@demande_arret_travail, current_user, desc)
       render_infos(@demande_arret_travail, params[:anchor_tag])
     end
  end

  def liquidation_decomptes
    at_decompte = AtDecompte.find(params[:id])
    @demande_arret_travail = at_decompte.arret_travail
    if at_decompte.liquider
      desc = "Idemnites journalières n° #{at_decompte.id} du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) liquidé par #{current_user.email} (#{current_user.type_profil})"
      ajouter_event(@demande_arret_travail, current_user, desc)
      render_infos(@demande_arret_travail, params[:anchor_tag])
    end
  end

  def liquidation_tous_decomptes
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    at_decomptes = @demande_arret_travail.at_decomptes.can_be_liquidated
    at_decomptes.each do |at_decompte|
      if at_decompte.liquider!(current_user)
        desc = "Idemnites journalières n° #{at_decompte.id} du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) liquidé par #{current_user.email} (#{current_user.type_profil})"
        ajouter_event(@demande_arret_travail, current_user, desc)
      end
    end
    render_infos(@demande_arret_travail)
  end

  def validation_decomptes
    at_decompte = AtDecompte.find(params[:id])
    @demande_arret_travail = at_decompte.arret_travail
    
    if at_decompte.valider
      desc = "Idemnites journalières n° #{at_decompte.id} du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) validé par #{current_user.email} (#{current_user.type_profil})"
      ajouter_event(@demande_arret_travail, current_user, desc)
      render_infos(@demande_arret_travail, params[:anchor_tag])
    end
  end    
    
  def validation_decomptes_comptable
    at_decompte = AtDecompte.find(params[:id])
    @demande_arret_travail = at_decompte.arret_travail
    if at_decompte.validation_comptable
      desc = "Idemnites journalières n° #{at_decompte.id} du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) validé par #{current_user.email} (#{current_user.type_profil})"
      ajouter_event(@demande_arret_travail, current_user, desc)
      render_infos(@demande_arret_travail, params[:anchor_tag])
    end
  end 

  def validation_decomptes_medecin
      at_decompte = AtDecompte.find(params[:id])
      @demande_arret_travail = at_decompte.arret_travail
      at_decompte.date_validation_medecin = DateTime.now.to_date
      at_decompte.etat = :validation_medecin
      if at_decompte.validation_medecin
        desc = "Idemnites journalières n° #{at_decompte.id} du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) validé par #{current_user.email} (#{current_user.type_profil})"
        ajouter_event(@demande_arret_travail, current_user, desc)
        render_infos(@demande_arret_travail, params[:anchor_tag])
      end
  end 
    
  def validation_tous_decomptes
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    at_decomptes = @demande_arret_travail.at_decomptes.where(est_valide: false)
    at_decomptes.each do |at_decompte|
      if at_decompte.valider
        desc = "Idemnites journalières n° #{at_decompte.id} du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) validé par #{current_user.email} (#{current_user.type_profil})"
        ajouter_event(@demande_arret_travail, current_user, desc)

      end
    end
    render_infos(@demande_arret_travail, params[:anchor_tag])
  end


            




 


  #----------Annulation guérison ------------------------------------------------------------
  

  def annulation_guerison_form
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
  end

  def soumettre_annulation_guerison
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id])
    if@demande_arret_travail.update(update_annulation_guerison)
      @demande_arret_travail.gueris?
      @demande_arret_travail.est_annulation_guerison_soumise!
      #@demande_arret_travail.reouverture_soumise_par = current_user
      @demande_arret_travail.save
      redirect_to [:admin, @demande_arret_travail], notice: 'Demande de réouverture du dossier soumise.'
    else
      render :reouverture_dossier_form
    end
  end

  def valider_annulation_guerison
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id])
    if @demande_arret_travail.annulation_guerison_soumise?
      @demande_arret_travail.est_accepte!
      @demande_arret_travail.etat = :accepte
      @demande_arret_travail.save!
      redirect_to [:admin, @demande_arret_travail], notice: 'Demande de réouverture du dossier soumise.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end

  #--------Reouverture Dossier AT---------------------------------------------------------------

  def reouverture_dossier_form
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
  end



  def soumettre_demande_reouverture
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id])
    if@demande_arret_travail.update(update_reouverture_dossier)
      @demande_arret_travail.dossier_cloture?
      @demande_arret_travail.est_rechute_en_creation!
      @demande_arret_travail.traite_le = DateTime.now
      @demande_arret_travail.reouverture_soumise_par = current_user
      @demande_arret_travail.save
      redirect_to [:admin, @demande_arret_travail], notice: 'Demande de réouverture du dossier soumise.'
    else
      render :reouverture_dossier_form
    end
  end

  def soumettre_rechute
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id])
    if @demande_arret_travail.rechute_en_creation?
       @demande_arret_travail.est_rechute_soumise!
       @demande_arret_travail.save
       redirect_to [:admin, @demande_arret_travail], notice: 'Demande de réouverture du dossier soumise.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end

  def soumission_rechute_mc
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id])
    if @demande_arret_travail.rechute_soumise?
      @demande_arret_travail.est_soumission_rechute_mc!
      @demande_arret_travail.traite_le = DateTime.now
      @demande_arret_travail.traite_par = current_user
      @demande_arret_travail.save
      redirect_to [:admin, @demande_arret_travail], notice: 'Demande de réouverture confimee par le medecin.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end

  def rechute_validee_medecin
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id])
    if @demande_arret_travail.soumission_rechute_mc?
      @demande_arret_travail.est_validation_rechute_mc!
      @demande_arret_travail.traite_le = DateTime.now
      @demande_arret_travail.traite_par = current_user
      @demande_arret_travail.save
      redirect_to [:admin, @demande_arret_travail], notice: 'Demande de réouverture validée.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end


  def rechute_validee
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id])
    if @demande_arret_travail.validation_rechute_mc?
      @demande_arret_travail.est_rechute_validee!
      @demande_arret_travail.traite_le = DateTime.now
      @demande_arret_travail.traite_par = current_user
      @demande_arret_travail.save
      redirect_to [:admin, @demande_arret_travail], notice: 'Demande de réouverture validée.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end

  
  def reouvrire_dossier_at
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id] || params[:id])
    if @demande_arret_travail.rechute_validee?
      @demande_arret_travail.est_dossier_reouvert!
      @demande_arret_travail.save
      redirect_to [:admin, @demande_arret_travail], notice: 'Dossier réouvert avec success.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end
      #--------End Réouverture Dossier AT--------------------------------------------------------------


  def valider_documents
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    unless @demande_arret_travail.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:admin, @demande_arret_travail]
  end



  def add_reversion_rente
    @at_reversion_rente= AtReversionRente.new
  end



  def retourner_process
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.en_instruction?
       @demande_arret_travail.update(traite_par: current_user,
                                  traite_le: nil)
      @demande_arret_travail.retour_creation!
    else
      if @demande_arret_travail.avis_chefService?
        if @demande_arret_travail.creer_en_agence?
          retourner_dossier_en_agence(@demande_arret_travail)
          @demande_arret_travail.retour_en_instruction!
        else
          @demande_arret_travail.update(instruit_par: nil,
          traite_par: current_user,
          instruit_le: nil)
          retourner_dossier_en_agence(@demande_arret_travail)
          @demande_arret_travail.retour_creation!
        end
      else
        if @demande_arret_travail.soumis_directeur?
          @demande_arret_travail.update(traite_par: current_user,
                                      traite_le: nil,
                                      etat: :instruction)
          @demande_arret_travail.retour_avis_chefService!
        else
          if @demande_arret_travail.accepte?
            @demande_arret_travail.update(affectation_at: nil,
                                          traite_par: current_user,
                                        traite_le: nil)
            @demande_arret_travail.retour_soumis_directeur!
          else
            if @demande_arret_travail.liquidation_soumis?
             @demande_arret_travail.update!(
                                         traite_par: current_user,
                                         traite_le: nil)
             @demande_arret_travail.retour_liquider_all_frais_engages
             @demande_arret_travail.retour_validation_all_frais_engages
             @demande_arret_travail.retour_accepte!
            else
              if @demande_arret_travail.liquidation_valide?
                @demande_arret_travail.update(traite_par: current_user,
                                            traite_le: nil)
                @demande_arret_travail.retour_validation_all_frais_engages
                @demande_arret_travail.retour_validation_comptable_all_frais_engages
                @demande_arret_travail.retour_liquidation_soumis!
              else
                if @demande_arret_travail.validation_comptable?
                  @demande_arret_travail.update(traite_par: current_user,
                                              traite_le: nil)
                  @demande_arret_travail.retour_validation_comptable_all_frais_engages
                  @demande_arret_travail.retour_liquidation_valide!
                end

              end

            end
          end
        end
      end
    end
    if @demande_arret_travail.update(arret_travail_motifRetouner_params.merge(traite_par: current_user,
      traite_le: DateTime.now))
      redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Dossier retourner avec succés.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end


  def retourner_redacteur
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.creer_en_agence?
      @demande_arret_travail.update(instruit_par: nil,
                                  traite_par: current_user,
                                  affecte_a: nil,
                                  instruit_le: nil)
      @demande_arret_travail.retour_en_instruction!
    else
      @demande_arret_travail.update(instruit_par: nil, affecte_a: nil,
      traite_par: current_user,
      instruit_le: nil)
      @demande_arret_travail.retour_creation!
    end
    if @demande_arret_travail.update(arret_travail_motifRetouner_params.merge(traite_par: current_user,
      traite_le: DateTime.now))
      redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Dossier retourner avec succés.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
    
  end

  def add_frais_engage
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    @at_frais_engage = AtFraisEngage.new(info_frais_engage_params)
    @at_frais_engage.etat = :creation
    @at_frais_engage.ajoute_par = current_user
   
    if @at_frais_engage.save!
      desc = "Mise a jour information frais engagés du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
      ajouter_event(@demande_arret_travail, current_user, desc)
      render_infos(@demande_arret_travail, params[:anchor_tag])
    else
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Frais engagé not added.' }
      end
    end
  end

  def add_decompte
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    @at_decompte = AtDecompte.new(info_decompte_params)
    @at_decompte.ajoute_par = current_user
    if @at_decompte.save
      desc = "Mise a jour information Arret travail du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
      ajouter_event(@demande_arret_travail, current_user, desc)
      render_infos(@demande_arret_travail, params[:anchor_tag])
    else
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: @at_decompte.msg_error }
      end
    end
  end


  def ajouter_lesion
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    @at_lesion = AtLesion.new(info_lesion_params)
    
    if @at_lesion.save
      #desc = "Mise a jour information consolidation du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
      #ajouter_event(@at_consolidation, current_user, desc)
      # render_infos(@at_consolidation, params[:anchor_tag])
      redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'At lesion.'
    else
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Lesion not added.' }
      end
    end
  end

    def ajouter_carnet
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    @at_carnet = AtCarnet.new(info_carnet_params)
    
    if @at_carnet.save
      redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Carnet ajouté avec succes.'
    else
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Carnet not added.' }
      end
    end
  end

  def add_avi
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    @at_avi = AtAvi.new(info_avis_params)
    if @at_avi.save
      redirect_to admin_arret_travail_path(@demande_arret_travail), notice: 'Avis ajouté avec succés.'
    else
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Erreur ajout avis.' }
      end
    end
  end

  def active_avis_medecin
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.soumis_directeur?
      unless params[:dprp_obligatoire_tag]
        @demande_arret_travail.est_avis_medecin!
        @demande_arret_travail.medecin_conseil_obligatoire=true
      else
        @demande_arret_travail.est_soumis_directeur!
        @demande_arret_travail.medecin_conseil_obligatoire=false
      end
      @demande_arret_travail.save
      redirect_to [:admin, @demande_arret_travail], notice: 'Dossier AT transmis au medecin pour donner son avis.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end

  def active_avis_dprp
    @demande_arret_travail = ArretTravail.find(params[:arret_travail_id])
    if @demande_arret_travail.soumis_directeur?
      @demande_arret_travail.est_avis_dprp!
      @demande_arret_travail.dprp_obligatoire=true
      @demande_arret_travail.save
      redirect_to [:admin, @demande_arret_travail], notice: 'Dossier AT transmis au dprp pour donner son avis.'
    else
      redirect_to [:admin, @demande_arret_travail]
    end
  end
  #----------------- methodes privates-------------------------------------------
   private


  def set_admin_arret_travail
    @demande_arret_travail = ArretTravail.find(params[:id] || params[:arret_travail_id])
  end

  def allowed_params
   %i(
     raison_sociale_employeur numero_employeur adresse_employeur boite_postale_employeur 
     email_employeur telephone_employeur fax_employeur activite_principale_entreprise 
     nin_salarie numero_affiliation carnet_accident_travail prenom_salarie 
     nom_salarie date_de_naissance_salarie situation_matrimoniale_salarie 
     nationalite_salarie adresse_domiciliaire_salarie telephone_salarie 
     qualification_professionnelle_salarie date_embauche_salarie anciennete_salarie 
     type_de_contrat_travail_salarie nature_du_travail_au_moment_accident 
     infirmite_anterieure_accident taux_infirmite_anterieure_accident 
     numero_rente_infirmite_anterieure_accident date_accident 
     nombre_hr_entre_accident_et_prise_travail lieu_accident accident_mortel 
     debut_arret_travail agent_materiel code_agent_materiel cause_circonstances_acccident 
     avec_constat detail_constat avec_temoin nom_temoin adresse_temoin personne_avisee 
     nom_personne_avisee adresse_personne_avisee personne_avisee_quand 
     personne_avisee_par_qui accident_cause_par_tiers prenom_tiers 
     nom_tiers adresse_tiers prenom_civilement_responsable nom_civilement_responsable 
     adresse_civilement_responsable salaire_verse_en_totalite_en_at date_declaration 
     nom_declarant prenom_declarant lieu_declaration etat est_ipp taux_ipp taux_itt 
     info_salarie_valid info_pro_salarie_valid info_employeur_valid detail_accident_valid document_valid
     frais_indemnité_valid user_id created_at updated_at numero_ipress_css_salarie 
     dossier_initial_salarie date_rechute_salarie salaire_du_jour salaire_du_mois 
     numero_unique_ipress_css_employeur ancien_numero_ipress_employeur 
     ancien_numero_css_employeur status_ipress status_css status_ipress_css 
     solde_total_ipress_css solde_branche_vieillesse solde_branche_at 
     solde_branche_pf agence_gestion_ipress agence_gestion_css taux_at taux_pf 
     nature_accident declarant num_dossier deleted est_journalier affecte_a 
     affectation_type dprp_obligatoire situation_matrimoniale sexe lieu_de_naissance 
     telephone adresse email nationalite type_de_piece type_declaration adresse_declarant 
     telephone_declarant consequence_accident_travail date_du_deces raison_absence_constat 
     raison_sociale_assureur nom_assureur adresse_assureur numero_police_assurance 
     incapacite_permanente medecin_conseil_obligatoire qualite_declarant is_subrogation
     active_enquete_dprp active_avis_medecin desc_dprp desc_medecin numero_temporaire has_numero_affiliation ajoute_par_id date_reception est_maladie_professionnelle
   )
  end

  def allowed_info_salarie_params
   %i( 
     raison_sociale_employeur numero_affiliation prenom_salarie nom_salarie date_de_naissance_salarie
     qualification_professionnelle_salarie numero_employeur adresse_employeur boite_postale_employeur
     email_employeur telephone_employeur fax_employeur activite_principale_entreprise nin_salarie carnet_accident_travail
     adresse_domiciliaire_salarie situation_matrimoniale_salarie nationalite_salarie telephone_salarie date_embauche_salarie
     anciennete_salarie type_de_contrat_travail_salarie nature_du_travail_au_moment_accident infirmite_anterieure_accident
     taux_infirmite_anterieure_accident numero_rente_infirmite_anterieure_accident date_accident nombre_hr_entre_accident_et_prise_travail
     lieu_accident accident_mortel debut_arret_travail agent_materiel code_agent_materiel cause_circonstances_acccident
     avec_constat detail_constat avec_temoin nom_temoin adresse_temoin personne_avisee nom_personne_avisee 
     adresse_personne_avisee personne_avisee_quand personne_avisee_par_qui accident_cause_par_tiers prenom_tiers 
     nom_tiers adresse_tiers prenom_civilement_responsable nom_civilement_responsable adresse_civilement_responsable 
     salaire_verse_en_totalite_en_at date_declaration non_declarant prenom_declarant lieu_declaration est_ipp taux_ipp 
     taux_itt info_salarie_valid info_employeur_valid detail_accident_valid document_valid frais_indemnité_valid user_id 
     created_at updated_at numero_ipress_css_salarie dossier_initial_salarie date_rechute_salarie salaire_du_jour 
     salaire_du_mois numero_unique_ipress_css_employeur ancien_numero_ipress_employeur ancien_numero_css_employeur 
     status_ipress status_css status_ipress_css solde_total_ipress_css solde_branche_vieillesse solde_branche_at 
     solde_branche_pf agence_gestion_ipress agence_gestion_css taux_at taux_pf nature_accident declarant est_journalier
     consequence_accident_travail date_du_deces raison_absence_constat raison_sociale_assureur nom_assureur 
     adresse_assureur numero_police_assurance incapacite_permanente medecin_conseil_obligatoire
   )
  end

  def allowed_info_employeur_params
   %i(  
       raison_sociale_employeur numero_employeur adresse_employeur boite_postale_employeur email_employeur 
       telephone_employeur fax_employeur activite_principale_entreprise
       numero_ipress_css_salarie dossier_initial_salarie date_rechute_salarie salaire_du_jour 
       salaire_du_mois numero_unique_ipress_css_employeur ancien_numero_ipress_employeur ancien_numero_css_employeur 
       status_ipress status_css status_ipress_css solde_total_ipress_css solde_branche_vieillesse solde_branche_at 
       solde_branche_pf agence_gestion_ipress agence_gestion_css taux_at taux_pf nature_accident declarant est_journalier
       consequence_accident_travail date_du_deces raison_absence_constat raison_sociale_assureur nom_assureur 
       adresse_assureur numero_police_assurance incapacite_permanente medecin_conseil_obligatoire_tag carnet_accident_travail
   )
  end

  def allowed_document_params
    %i(type_document document description arret_travail_id)
  end

  def allowed_document_cloture_params
    %i(type_document document description arret_travail_id)
  end
  
  def allowed_lesion_params
    %i(nature_lesion code_nature_lesion siege_lesion code_siege_lesion arret_travail_id created_at)
  end

  def allowed_carnet_params
    %i(numero_carnet numero_employeur raison_sociale date_achat arret_travail_id)
  end

  def allowed_incapacite_params
    %i(date_debut date_fin nombre_jour nombre_heure arret_travail_id) 
  end

  def allowed_decompte_params
    %i(date_debut date_fin nombre_jour arret_travail_id certificat_medical solicite_medecin)
  end
  
  def allowed_frais_engage_params
    %i(numero prenom nom montant date_liquidation nature type_frais rembourse_a_qui, remboursement_tiers arret_travail_id) 
  end

  def allowed_salaire_params
    %i(mois montant arret_travail_id) 
  end

  def allowed_prime_salaire_params
    %i(designation montant type_frais arret_travail_id) 
  end
  def allowed_avis_params
    %i(fait_par fait_par_profil description dprp_obligatoire medecin_conseil_obligatoire arret_travail_id avis)
  end
  def allowed_consolidation_params
    %i(date_consolidation taux_incapacite arret_travail_id) 
  end
  def allowed_update_taux_consolidation_params
    %i(taux_ipp_mc avis_mc motif_changement_taux_ipp) 
  end
   
  def allowed_info_accident_params
   %i(nature_du_travail_au_moment_accident infirmite_anterieure_accident taux_infirmite_anterieure_accident 
   numero_rente_infirmite_anterieure_accident date_accident date_accident date_accident date_accident date_accident 
   nombre_hr_entre_accident_et_prise_travail lieu_accident accident_mortel debut_arret_travail debut_arret_travail 
   debut_arret_travail debut_arret_travail debut_arret_travail agent_materiel cause_circonstances_acccident 
   avec_constat detail_constat avec_temoin nom_temoin adresse_temoin accident_cause_par_tiers prenom_tiers nom_tiers 
   adresse_tiers personne_avisee nom_personne_avisee adresse_personne_avisee personne_avisee_quand 
   personne_avisee_par_qui prenom_civilement_responsable nom_civilement_responsable adresse_civilement_responsable 
   salaire_verse_en_totalite_en_at date_declaration date_declaration date_declaration date_declaration date_declaration 
   nom_declarant prenom_declarant lieu_declaration est_ipp taux_ipp taux_itt est_journalier date_reception
   numero_ipress_css_salarie dossier_initial_salarie date_rechute_salarie salaire_du_jour 
   salaire_du_mois numero_unique_ipress_css_employeur ancien_numero_ipress_employeur ancien_numero_css_employeur 
   status_ipress status_css status_ipress_css solde_total_ipress_css solde_branche_vieillesse solde_branche_at 
   solde_branche_pf agence_gestion_ipress agence_gestion_css taux_at taux_pf nature_accident declarant
   consequence_accident_travail date_du_deces raison_absence_constat raison_sociale_assureur nom_assureur 
   adresse_assureur numero_police_assurance incapacite_permanente personne_avisee_qualite
   )
  end

  def update_salarie_info
    render_infos(@demande_arret_travail.update(info_salarie_params))
    desc = "Mise a jour information salaire du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
    ajouter_event(@demande_arret_travail, current_user, desc)
  end

  def update_pro_salarie_info
    render_infos(@demande_arret_travail.update(info_salarie_params))
    desc = "Mise a jour information salaire du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
    ajouter_event(@demande_arret_travail, current_user, desc)
  end

  def update_employeur_info
    render_infos(@demande_arret_travail.update(info_employeur_params))
    desc = "Mise a jour information employeur du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
    ajouter_event(@demande_arret_travail, current_user, desc)
  end

  def update_accident_info
    if info_accident_params[:consequence_accident_travail] == "deces"
      @demande_arret_travail.active_avis_medecin = true
      @demande_arret_travail.save
    end
    render_infos(@demande_arret_travail.update(info_accident_params))

  end

  def update_document_info
   @at_document = AtDocument.new(info_document_params)
   
   if @at_document.save
     desc = "Mise a jour information document du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
     ajouter_event(@demande_arret_travail, current_user, desc)
     render_infos(@demande_arret_travail, params[:anchor_tag])
   else
     respond_to do |format|
       format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Document not added.' }
     end
   end
 end

  def update_lesion_info
    @at_lesion = AtLesion.new(info_lesion_params)
    if params[:at_lesion][:created_at].to_date >= Date.today
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: "Date de lésion doit etre antérieure à la date d'aujourd'hui." }
      end
    elsif params[:at_lesion][:created_at].to_date < @demande_arret_travail.date_accident
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: "Date de lésion doit etre postérieure à la date d'accident" }
      end
    else
    
      if @at_lesion.save
        desc = "Mise a jour information lesion du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
        ajouter_event(@demande_arret_travail, current_user, desc)
        render_infos(@demande_arret_travail, params[:anchor_tag])
      else
        respond_to do |format|
          format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Lesion not added.' }
        end
      end
    end
  end

  def update_incapacite_info
    @at_incapacite = AtIncapacite.new(info_incapacite_params)
    if params[:at_incapacite][:date_debut].to_date < @demande_arret_travail.date_accident
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: "Date début d'arret doit etre postérieure à la date d'accident." }
      end
    elsif params[:at_incapacite][:date_debut].to_date > params[:at_incapacite][:date_fin].to_date
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: "Date fin d'arret doit etre postérieure à la date debut d'arret" }
      end
    else
      #@at_incapacite.date_fin = @at_incapacite.date_debut + (@at_incapacite.nombre_jour.days - 1) if  @at_incapacite.nombre_jour
      @at_incapacite.done_by = current_user.id
      if @at_incapacites.first_arret?
      end
      if @at_incapacite.save
        desc = "Mise a jour information incapacité du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
        ajouter_event(@demande_arret_travail, current_user, desc)
        #@demande_arret_travail.update(etat: 'en_attente_information') if @demande_arret_travail.accepte?
        render_infos(@demande_arret_travail, params[:anchor_tag])
      else
        respond_to do |format|
          format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert:  "Incapacité not added. #{@at_incapacite.errors.messages}"}
        end
      end
    end
  end



  def update_frais_engage_info
    @at_frais_engage = AtFraisEngage.new(info_frais_engage_params)
   
    if @at_frais_engage.save
      desc = "Mise a jour information frais engagés du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
      ajouter_event(@demande_arret_travail, current_user, desc)
      render_infos(@demande_arret_travail, params[:anchor_tag])
    else
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Frais engagé not added.' }
      end
    end
  end

  def update_prime_salaire_info
    puts "===Info",info_prime_salaire_params
    @at_code_prime_salaire = AtCodePrimeSalaire.new(info_prime_salaire_params)
    @at_code_prime_salaire.montant = 0 if @at_code_prime_salaire.montant.nil? 
    @at_code_prime_salaire.code = info_prime_salaire_params[:designation] + "_" + @demande_arret_travail.id.to_s
    @at_code_prime_salaire.designation.gsub!('_',' ')
    composant_salaire = Admin::ComposantSalaire.find_by(designation: info_prime_salaire_params[:designation])
    puts "===Info",composant_salaire.prise_en_compte
    @at_code_prime_salaire.prise_en_compte = composant_salaire.prise_en_compte
    if @at_code_prime_salaire.save
     # @demande_arret_travail.reinit_calcul
      render_infos(@demande_arret_travail, params[:anchor_tag])
    else
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Prime salaire not added.' }
      end
    end
  end

  def update_avis_info
    if params[:dprp_obligatoire_tag] || params[:medecin_conseil_obligatoire_tag]
      @demande_arret_travail.update(dprp_obligatoire: params[:dprp_obligatoire] == '1') if params[:dprp_obligatoire_tag]
      @demande_arret_travail.update(medecin_conseil_obligatoire: params[:medecin_conseil_obligatoire] == '1') if params[:medecin_conseil_obligatoire_tag]
      render_infos(@demande_arret_travail, params[:anchor_tag])
      return
    end

   

    @at_avi = AtAvi.new(info_avis_params) 
    
    if @at_avi.save
      desc = "Mise a jour information avis du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.workflow_state}) par #{current_user.email} (#{current_user.type_profil})"
      ajouter_event(@demande_arret_travail, current_user, desc)
      render_infos(@demande_arret_travail, params[:anchor_tag])
    else
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Avis not added.' }
      end
    end
  end

  def update_salaires_info
    @at_salaire = AtSalaire.new(info_salaire_params)
    
    if @at_salaire.save
      desc = "Mise a jour salaire annuel du dossier AT n° #{@demande_arret_travail.num_dossier} (etat #{@demande_arret_travail.etat}) par #{current_user.email} (#{current_user.type_profil})"
      ajouter_event(@demande_arret_travail, current_user, desc)
      render_infos(@demande_arret_travail, params[:anchor_tag])
    else
      respond_to do |format|
        format.html { redirect_to admin_arret_travail_path(@demande_arret_travail), alert: 'Salaire not added.' }
      end
    end
  end



  def render_infos(infos, anchor_tag=nil)
   respond_to do |format|
     if infos
       format.html { redirect_to admin_arret_travail_path(@demande_arret_travail)+"##{anchor_tag}", notice: 'Arret travail was successfully updated.' }
       format.json { render :show, status: :ok, location: admin_arret_travail_path(@demande_arret_travail) }
     else
       @at_document = AtDocument.new
       @at_lesion = AtLesion.new
       @at_incapacite = AtIncapacite.new
       @at_incapacite.date_debut = @demande_arret_travail.date_accident + 1.day
       @at_incapacite.date_fin = @demande_arret_travail.date_accident + 2.day
       @at_frais_engage = AtFraisEngage.new
       @at_code_prime_salaire = AtCodePrimeSalaire.new
       @at_avi = AtAvi.new
       format.html { render :show}
       format.json { render json: @demande_arret_travail.errors, status: :unprocessable_entity }
     end
   end
  end


  def arret_travail_params
   params.require(:arret_travail).permit(allowed_params)
  end

  def info_salarie_params
   params.require(:arret_travail).permit(allowed_params)
  end

  def info_employeur_params
   params.require(:arret_travail).permit(allowed_info_employeur_params)
  end

  def info_accident_params
   params.require(:arret_travail).permit(allowed_info_accident_params)
  end

  def info_document_params
   params.require(:at_document).permit(allowed_document_params)
 end

  def info_document_cloture_params
    params.require(:at_document).permit(allowed_document_cloture_params)
  end
   
  def info_lesion_params
    params.require(:at_lesion).permit(allowed_lesion_params)
  end

  def info_carnet_params
    params.require(:at_carnet).permit(allowed_carnet_params)
  end

  def info_incapacite_params
    params.require(:at_incapacite).permit(allowed_incapacite_params)
  end
  def info_decompte_params
    params.require(:at_decompte).permit(allowed_decompte_params)
  end
  
  def info_frais_engage_params
    params.require(:at_frais_engage).permit(allowed_frais_engage_params)
  end

  def info_salaire_params
    params.require(:at_salaire).permit(allowed_salaire_params)
  end
  
  def info_prime_salaire_params
    params.require(:at_code_prime_salaire).permit(allowed_prime_salaire_params)
  end

  def info_avis_params
    params.require(:at_avi).permit(allowed_avis_params)
  end
  def info_consolidation_params
    params.require(:at_consolidation).permit(allowed_consolidation_params)
  end
  def update_taux_consolidation_params
    params.require(:at_consolidation).permit(allowed_update_taux_consolidation_params)
  end

  def update_cloture_dossier
    params.require(:arret_travail).permit(:date_cloture_dossier, :certificat_guerison)
  end

  def update_reouverture_dossier
    params.require(:arret_travail).permit(:date_reouverture_dossier, :certificat_medical)
  end

  def update_annulation_guerison
    params.require(:arret_travail).permit(:date_annulation_guerison, :motif_annulation_guerison)
  end

  def ajouter_event(demande_arret_travail, user, desc)
    at_event = AtEvent.new
    at_event.description = desc
    at_event.done_by = user.email
    at_event.arret_travail_id = demande_arret_travail.id
    at_event.save
  end
  
  def convert_enum_to_integer(parameters)
    parameters[:qualification_professionnelle_salarie] =  parameters[:qualification_professionnelle_salarie].to_i
    parameters[:nature_accident] =  parameters[:nature_accident].to_i
    parameters[:declarant] =  parameters[:declarant].to_i
    parameters
  end
  def decision_commission_rejet_params
    params.require(:arret_travail).permit(:decision_commission_rejet)
  end
  def arret_travail_motifRetouner_params
    params.require(:arret_travail).permit(:motif)
  end

  def active_avis_medecin_params
    params.require(:arret_travail).permit(:active_avis_medecin, :desc_medecin, :medecin_conseil_obligatoire, :medecin_conseil_obligatoire_tag)
  end

  def active_avis_dprp_params
    params.require(:arret_travail).permit(:active_enquete_dprp, :desc_dprp, :dprp_obligatoire)
  end

  def update_selected(at_selected, users)
    unless at_selected.nil?
    redacteurs_id = []
    techniciens_at_id = []
    redacteurs_id = User.redacteur.map(&:id) unless at_selected.empty?
    at_selected.each do |at_id|
      at = ArretTravail.find(at_id)
      if at.accepte?
        at.update(affectation_at: users, date_affectation_tech: DateTime.now, traite_par: current_user)
      else
        at.update(affecte_a: users, date_affectation_redacteur: DateTime.now, traite_par: current_user, workflow_state: :affecte_redacteur)
      end
    end
    end

  end

  def retourner_dossier_en_agence(at)
    at.update(
      instruit_par: nil,
      traite_par: current_user,
      affecte_a: nil,
      etat: :instruction,
      instruit_le: nil,
      date_soumission_redacteur: nil,
      date_soumission_dajc: nil,
      date_soumission_chef_service: nil

    )

  end


end