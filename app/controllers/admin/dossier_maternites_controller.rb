class Admin::DossierMaternitesController < Admin::ApplicationController
  before_action :set_dossier_maternite, except: [:index, :new, :create, :en_attente, :ajoutee, :recipisse_dossier, :historique_dossier,
                                                 :valider_ordre, :generer_paiement, :retour]
  before_action :can_valide_alaire_section, only: [:valider_salaire]

  def index
    @q = DossierMaternite.visible_for_admins.not_deleted.not_incomplete.ransack(params[:q])
    #@dossier_maternites = @q.result.order('prenom desc')
    @dossier_maternites = @q.result.order('dossier_maternites.prenom desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def search
    if params[:search].blank?
      redirect_to admin_dossier_maternites_path
    else
      @parameter = params[:search].downcase
      @results = DossierMaternite.all.where("lower(name) LIKE :search", search: @parameter).not_deleted.not_incomplete
    end
  end

  def en_attente
    @q = DossierMaternite.en_attente.not_deleted.not_incomplete.ransack(params[:q])
    @dossier_maternites = @q.result.order('dossier_maternites.prenom desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def valider_ordre
    @q = DossierMaternite.valide.ransack(params[:q])
    @dossier_maternites = @q.result.page(params[:page]).per(100)
  end

  def ajoutee
    @dossier_maternites = current_user.dossier_maternite_crees.page(params[:page]).per(100)
  end

  def valider
    @dossier_maternite.valide!
    @dossier_maternite.traite_par = current_user
    @dossier_maternite.traite_le = DateTime.now
    @dossier_maternite.save
    #flash[:notice] = 'Demande traitée'
    #redirect_to [:admin, @dossier_maternite]
    redirect_to [:admin, @dossier_maternite], notice: 'Le dossier est validé !'
  end

  def cloturer
    @dossier_maternite.cloture!
    @dossier_maternite.cloture_par = current_user
    @dossier_maternite.date_cloture = DateTime.now
    if @dossier_maternite.save
      redirect_to [:admin, @dossier_maternite], notice: 'Le dossier est cloturé !'
    else
      flash[:notice] = 'Une erreur est survenue', @dossier_maternite.errors.full_messages
      redirect_to [:admin, @dossier_maternite]
    end
  end

  def rejeter; end

  def retourner_dossier
    if @dossier_maternite.update(dossier_maternite_params)
      if current_user.chef_agence?
        @dossier_maternite.creation!
        @dossier_maternite.etat_civil_demandeur_valid!(false)
        @dossier_maternite.carriere_valid!(false)
        @dossier_maternite.document_valid!(false)
        @dossier_maternite.salaire_valid!(false)
        @dossier_maternite.date_soumission = nil
        @dossier_maternite.traite_le = nil
        @dossier_maternite.traite_par_id = nil
        @dossier_maternite.soumis_par_id = nil
        @dossier_maternite.indemnite_conges_maternites.update_all(etat: :creation, date_soumission: nil, date_liquidation: nil, montant_paiement: nil, numero_liquidation: nil)
      end

      @dossier_maternite.retourne_par = current_user
      @dossier_maternite.retourne_le = DateTime.now
      @dossier_maternite.date_soumission = nil
      @dossier_maternite.save
      redirect_to [:admin, @dossier_maternite], notice: 'Le dossier a été retourné avec succès.'
    else
      flash[:error] = "Une erreur estbsurvenue."
      redirect_to [:admin, @dossier_maternite]
    end
  end

  def rejeter_create
    if @dossier_maternite.update(dossier_maternite_rejet_params.merge(etat: :rejete,
                                                                      traite_par: current_user,
                                                                      traite_le: DateTime.now))
      redirect_to admin_dossier_maternites_path, notice: 'Demande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def dossier_maternite_retour_params
    params.require(:dossier_maternite).permit(:motif_retour)
  end


  def dossier_maternite_rejet_params
    params.require(:dossier_maternite).permit(:motif_rejet)
  end


  # GET /dossier_maternites/1
  # GET /dossier_maternites/1.json
  def show
    #@document_dossier_maternite = DocumentDossierMaternite.new
    if @dossier_maternite.deleted? or @dossier_maternite.incomplete?
      redirect_to admin_dossier_maternites_path, notice: 'Dossier incomplet ou supprimé.'
    end
    @carriere_dossier_maternite = CarriereDossierMaternite.new
    @carriere_dossier_maternites = @dossier_maternite.carriere_dossier_maternites
    @composant_salaire_icm = ComposantSalaireIcm.new

    #@composants = ComposantSalaire.order("designation DESC")
    @composants = Admin::ComposantSalaire.order("designation DESC")

    @controleurs = User.controleur_css
    @controleurs = User.controleur_css.where.not(id: @dossier_maternite.ajoute_par.id) unless @dossier_maternite.ajoute_par.nil? # avoir la liste des gestionnaires

    @transactions = @dossier_maternite.compta_transactions.includes(:ordre_paiement).order("created_at DESC")

    @agents = User.users_for_type('gestionnaire_compte_allocataire').en_agence(current_user.agence_id)
  end

  def create_document_tdp
    @carriere_dossier_maternite = CarriereDossierMaternite.new(carriere_dossier_maternite_params)
    @carriere_dossier_maternite.dossier_maternite = @dossier_maternite
    @carriere_dossier_maternite.date_depot = Date.today
    @carriere_dossier_maternite.num_employeur = @dossier_maternite.num_immatriculation
    @carriere_dossier_maternite.raison_sociale = @dossier_maternite.raison_sociale

    if @carriere_dossier_maternite.save
      redirect_to [:admin, @dossier_maternite], notice: 'Le document TDP est ajouté.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document."
      render :show
    end
  end

  # GET /dossier_maternites/new
  def new
    @dossier_maternite = DossierMaternite.new(num_affiliation: params[:num_affiliation])

    #@dossier_maternite.num_affiliation = current_user.numero_salarie
  end

  # GET /dossier_maternites/1/edit
  def edit
    #edit
  end

  def admin_edit
  end

  def admin_edit_except
    if @dossier_maternite.update(dossier_maternite_params_except)
      redirect_to [:admin, @dossier_maternite], notice: 'Modification effectuée avec succès !.'
    else
      render :admin_edit
    end
  end

  # POST /dossier_maternites
  # POST /dossier_maternites.json
  def create
    @dossier_maternite = DossierMaternite.new(dossier_maternite_params)
    @dossier_maternite.documents_deposes_obligatoires = params[:documents_deposes_obligatoires]
    @dossier_maternite.documents_deposes_facultatifs = params[:documents_deposes_facultatifs]
    @dossier_maternite.ajoute_par = current_user
    @dossier_maternite.admin_agence = current_user.agence
    @dossier_maternite.etat = :creation

    if @dossier_maternite.save
      redirect_to [:admin, @dossier_maternite], notice: 'Le dossier est créé.'
    else
      render :new
    end
  end

  # PATCH/PUT /carriere_dossier_maternites/1
  # PATCH/PUT /carriere_dossier_maternites/1.json
  def update_carriere
    if @dossier_maternite.update(carriere_dossier_maternite_params)
      @dossier_maternite.etat_civil_demandeur_valid!(false)
      redirect_to [:admin, @dossier_maternite], notice: 'La demande de liquidation est bien mise à jour.'
    else
      render :edit
    end
  end

  # DELETE /carriere_dossier_maternites/1
  # DELETE /carriere_dossier_maternites/1.json
  def destroy_carriere
    @carriere_dossier_maternite = CarriereDossierMaternite.find(params[:carriere_dossier_maternite_id])
    @carriere_dossier_maternite.destroy
    redirect_to [:admin, @dossier_maternite], notice: 'Temps de présence suupprimé avec succès.'
  end

  # PATCH/PUT /dossier_maternites/1
  # PATCH/PUT /dossier_maternites/1.json
  def update
    if @dossier_maternite.update(dossier_maternite_params)
      @dossier_maternite.etat_civil_demandeur_valid!(false)
      @dossier_maternite.documents_deposes_obligatoires = params[:documents_deposes_obligatoires]
      @dossier_maternite.documents_deposes_facultatifs = params[:documents_deposes_facultatifs]
      @dossier_maternite.save
      redirect_to [:admin, @dossier_maternite], notice: 'La demande est bien mise à jour.'
    else
      render :edit
    end
  end

  # DELETE /dossier_maternites/1
  # DELETE /dossier_maternites/1.json
  def destroy
    @dossier_maternite.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @dossier_maternite], notice: 'Dossier maternite est supprimée.' }
      format.json { head :no_content }
    end
  end

  # region : affecter une demande à un/des controleur

  def affecter_controleur
    #affecter une demande à un controleur
    if @dossier_maternite.update(dossier_maternite_affecter_controleur_params.merge(affectation_controleur_date: DateTime.now))
      redirect_to admin_dossier_maternite_path(@dossier_maternite), notice: 'Demande Affectée.'
    end
  end

  def valider_etat_civil_demandeur
    @dossier_maternite.etat_civil_demandeur_valid!
    redirect_to [:admin, @dossier_maternite]
  end

  def valider_salaire
    if (@dossier_maternite.montant_indemnite > 0)
      @dossier_maternite.salaire_valid!
    else
      flash[:error] = "Veuillez ajouter les composants de salaire"
    end
    redirect_to [:admin, @dossier_maternite]
  end

  def valider_enfants
    @dossier_maternite.enfants_valide!
    redirect_to [:admin, @dossier_maternite]
  end

  def valider_carriere
    @carriere_dossier_maternites = @dossier_maternite.carriere_dossier_maternites
    #unless (@carriere_dossier_maternites.empty?)
    @dossier_maternite.carriere_valid!
    #else
    #flash[:error] = "Veuillez déposer le temps de présence"
    #end
    redirect_to [:admin, @dossier_maternite]
  end

  def valider_documents
    unless @dossier_maternite.document_valid!
      if @dossier_maternite.virement? and Document.rib.empty?
        flash[:error] = "Veuillez déposer le RIB avant la validation"
      end
      if @dossier_maternite.subrogation? and Document.attestation_maintien_salaire.empty?
        flash[:error] = "Veuillez déposer l'attestation de maintien de salaire avant la validation"
      end
      if not @dossier_maternite.subrogation? and Document.attestation_cess_paie.empty?
        flash[:error] = "Veuillez déposer l’attestation de cessation de paiement avant la validation"
      end
      #if not @dossier_maternite.subrogation? and Document.attestation_cess_travail.empty?
      #  flash[:error] = "Veuillez déposer l’attestation de cessation de travail avant la validation"
      #end
      if @dossier_maternite.attributaire? and Document.type_piece_attributaire.empty?
        flash[:error] = "La piéce d'identification de l'attributaire est requise avant la validation"
      end
      if Document.type_piece_demandeur.empty?
        flash[:error] = "La piéce d'identification est requise avant la validation"
      else
        flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
      end

    end
    redirect_to [:admin, @dossier_maternite]
  end

  def create_composant
    @composant_salaire_icm = ComposantSalaireIcm.new(composant_salaire_icm_params)
    @composant_salaire_icm.dossier_maternite = @dossier_maternite

    if @composant_salaire_icm.save
      #@dossier_maternite.document_valid!(false)
      redirect_to [:admin, @dossier_maternite], notice: 'Composant Salaire bien ajouté.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du composant."
      @document_dossier_maternite = DocumentDossierMaternite.new

      #@composants = ComposantSalaire.all
      @composants = Admin::ComposantSalaire.all
      render :show
    end
  end

  def destroy_composant
    @composant_salaire_icm = ComposantSalaireIcm.find(params[:composant_salaire_icm_id])
    @composant_salaire_icm.destroy
    redirect_to [:admin, @dossier_maternite], notice: 'Le composant a été suupprimé avec succès.'
  end

  def recipisse_dossier
    @dossier_maternite = DossierMaternite.find(params[:id] || params[:dossier_maternite_id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Récépissé du dossier de maternite No. #{@dossier_maternite.id}",
               page_size: 'A4',
               template: "admin/dossier_maternites/recipisse_dossier.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def valider_indemnites
    cpt = 0
    @indemnites = @dossier_maternite.indemnite_conges_maternites.soumis

    @indemnites.each do |indemnite|
      migrated_allocation = @dossier_maternite.indemnite_conges_maternite_migrees.find_by(num_tranche: indemnite.num_tranche)
      cpt += 1 unless migrated_allocation.nil?
      next unless migrated_allocation.nil?
      indemnite.etat = :valide
      indemnite.traite_par = current_user
      indemnite.traite_le = DateTime.now
      indemnite.date_validation = Date.today
      indemnite.save
    end
    message = 'Tranches validées. '
    message = [message, cpt, ' allocations déjà payées dans progress'].join('') if cpt > 0
    flash[:notice] = message
    redirect_to admin_dossier_maternite_indemnite_conges_maternites_path(@dossier_maternite)
  end

  def liquider_indemnites
    cpt = 0
    @indemnites = @dossier_maternite.indemnite_conges_maternites.creation

    annee = Date.today.year
    nbre = @dossier_maternite.indemnite_conges_maternites.soumis.count

    @indemnites.each do |indemnite|
      migrated_allocation = @dossier_maternite.indemnite_conges_maternite_migrees.find_by(num_tranche: indemnite.num_tranche)
      cpt += 1 unless migrated_allocation.nil?
      next unless migrated_allocation.nil?
      if indemnite.nbre_jr_payes > 0
        indemnite.etat = :soumis
        nbre += 1
        indemnite.date_soumission = Date.today
        indemnite.date_liquidation = Date.today
        indemnite.montant_paiement = indemnite.montant_paiement
        indemnite.numero_liquidation = nbre.to_s + "/" + @dossier_maternite.num_dossier + "/" + "#{annee}/LiqICM"

        indemnite.save
      end
    end
    message = 'Tranches liquidées. '
    message = [message, cpt, ' allocations déjà payées dans progress'].join('') if cpt > 0
    flash[:notice] = message
    redirect_to admin_dossier_maternite_indemnite_conges_maternites_path(@dossier_maternite)

  end

  def historique_dossier
    @dossier_maternite = DossierMaternite.find(params[:dossier_maternite_id])

    render template: "/admin/dossier_maternites/historique_dossier"
  end

  def soumettre
    #composant
    #if @dossier_maternite.update(soumission_dossier_maternite_params.merge(etat: :soumis, date_soumission: Date.today, montant_indemnite: @dossier_maternite.montant_icm))
    #  redirect_to [:admin, @dossier_maternite], notice: 'Le dossier de maternite est soumis !'
    #else
    #  render :soumission_form
    #end
    if @dossier_maternite.creation?
      @dossier_maternite.soumis!
      @dossier_maternite.date_soumission = DateTime.now
      @dossier_maternite.soumis_par = current_user
      @dossier_maternite.montant_indemnite = @dossier_maternite.salaire_reference
      @dossier_maternite.retourne_par = nil
      @dossier_maternite.retourne_le = nil
      @dossier_maternite.motif_retour = ''
      @dossier_maternite.save
      redirect_to [:admin, @dossier_maternite], notice: 'Le dossier de prestation est soumis !'
    else
      redirect_to [:admin, @dossier_maternite]
    end
  end

  def soumission_form;
  end

  def rapport_controle_soumettre

    if @dossier_maternite.update(dossier_maternite_params.merge(date_rapport: DateTime.now, date_rapport_joint: DateTime.now))
      # @dossier_maternite.date_rapport(DateTime.now)
      redirect_to [:admin, @dossier_maternite], notice: 'Rapport enregistré.'
    else
      render :rapport_controle_form
    end

  end

  def rapport_controle_form;
  end

  def retour
    @dossier_maternite = DossierMaternite.new(id: params[:dossier_maternite_id])
  end

  def retour_process
    if @dossier_maternite.soumis?
      @dossier_maternite.update(dossier_maternite_retour_params.merge(ajoute_par: current_user, traite_le: DateTime.now, date_soumission: nil))
      @dossier_maternite.retour_creation!
      redirect_to [:admin, @dossier_maternite], notice: 'Le dossier est retourné avec succés !'
    end
  end

  def generer_paiement
    puts "id =====> #{params[:id]} - #{params[:paiement_id]}"
    @paiement = PaiementAllocataire.find(params[:id] || params[:dossier_maternite_id])

    @dossier_maternite = @paiement.dossier_maternite

    @indemnites = IndemniteCongesMaternite.where(paiement_id: @paiement.id)

    @paiement = PaiementAllocataire.where(numero_allocataire: @dossier_maternite.num_affiliation).last

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "paiement prestation n°. #{@dossier_maternite.id}",
               page_size: 'A4',
               template: "admin/dossier_maternites/paiement_prestation.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def valider_paiement
    if @dossier_maternite.generation_paiement_encours?
      flash[:error] = "Une génération de facture est en cours pour ce dossier, veuillez réessayer plus tard"
    else
      @dossier_maternite.update_columns(generation_paiement_encours: true)
      ValiderPaiementsDossierMaterniteJob.perform_now(@dossier_maternite, current_user)

      flash[:notice] = "Génération de l'ordre de paiement en cours ..."
    end
    redirect_to [:admin, @dossier_maternite]
  end

  def icm_tranches_historic
    @q = @dossier_maternite.indemnite_conges_maternite_migrees.ransack(params[:q])
    @historic_tranches = @q.result.page(params[:page]).per(100)
  end

  def affecter_dossier
    @agent = User.find(params[:agent_id])
    @dossier_maternite.set_as_agent_chosen(@agent.id)
    redirect_to admin_dossier_maternite_path(@dossier_maternite), notice: 'L' 'agent a été choisi en tant que titulaire du dossier.'
  end

  def annuler_affectation_dossier
    @agent = User.find(params[:agent_id])
    @dossier_maternite.is_not_agent_chosen_anymore(@agent.id)
    redirect_to admin_dossier_maternite_path(@dossier_maternite), notice: 'L' 'agent a été retiré en tant que titulaire du dossier.'
  end

  private

  def generate_reference(dossier_maternite)
    letters = (0..9).to_a + ('A'..'Z').to_a
    dossier_maternite.id.to_s + letters.sample(10).join
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_dossier_maternite
    @dossier_maternite = DossierMaternite.visible_for_admins.find(params[:id] || params[:dossier_maternite_id])
  rescue ActiveRecord::RecordNotFound => e
    @dossier_maternite = current_user.dossier_maternite_crees.find(params[:id] || params[:dossier_maternite_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dossier_maternite_params
    params.require(:dossier_maternite).permit(:sexe_salarie, :num_affiliation, :prenom, :nom, :date_naissance,
                                              :lieu_naissance, :adresse_domicile, :etat, :date_soumission,
                                              :date_validation, :num_dossier, :debut_grossesse, :debut_conges, :montant_salaire,
                                              :telephone, :email, :nin, :subrogation, :mode_paiement,
                                              :compte_bancaire_numero_compte, :compte_bancaire_cle_rib, :admin_banque_agence_id,
                                              :attributaire, :nom_attributaire, :prenom_attributaire, :nin_attributaire, :num_immatriculation,
                                              :raison_sociale, :tel_employeur, :email_employeur, :adresse_employeur, :date_embauche,
                                              :date_accouchement_prev, :date_fin_cong_prev, :document, :rapport_controle, :date_rapport,
                                              :date_suspension_salaire, :nombre_part_impot, :part_trimf, :motif_retour, :est_ir_trimf_applique, :montant_ir)
  end

  def dossier_maternite_params_except
    params.require(:dossier_maternite).permit(:prenom, :nom, :nin, :debut_grossesse, :date_embauche, :debut_conges, :date_suspension_salaire, :montant_salaire)
  end

  def soumission_dossier_maternite_params
    params.require(:dossier_maternite).permit(:condition_1, :condition_2, :condition_3)
  end

  def document_dossier_maternite_params
    params.require(:document_dossier_maternite).permit(:type_document, :volet, :document, :commentaire)
  end

  def dossier_maternite_affecter_controleur_params
    params.require(:dossier_maternite).permit(:affectation_controleur, :commentaire_affectation_controleur)
  end

  def carriere_dossier_maternite_params
    params.require(:carriere_dossier_maternite).permit(:num_employeur, :raison_sociale, :annee, :document, :date_document,
                                                       :trimestre, :premier_mois, :deuxiem_mois, :troisiem_mois, :en_jour, :en_heure)
  end

  def composant_salaire_icm_params
    params.require(:composant_salaire_icm).permit(:composant_salaire_id, :montant)
  end

  def peut_etre_edite!
    unless @dossier_maternite.creation?
      flash[:error] = "Vous ne pouvez pas éditer un dossier déjà soumis"
      redirect_to [:admin, @dossier_maternite]
    end
  end

  def can_add!
    unless current_user.can_add_dossier_maternite?
      flash[:error] = "Vous ne pouvez pas ajouter un nouveau dossier de maternite. Il y'a déjà un en cours"
      redirect_to admin_dossier_maternites_path
    end
  end

  def can_valide_alaire_section
    if @dossier_maternite.revenu_brut > 5_000_000 and @dossier_maternite.montant_ir.nil?
      flash[:error] = "Vous ne pouvez pas valider cette section : Montant IR non renseigné! "
      redirect_to [:admin, @dossier_maternite]
    end
  end

end
