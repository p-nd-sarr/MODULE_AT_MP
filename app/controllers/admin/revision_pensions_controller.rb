class Admin::RevisionPensionsController < Admin::ApplicationController

  before_action :set_allocataire, except: [:en_attente_affectation_allocataire, :en_attente_affectation_salarie, :en_attente_instruction, :en_attente_validation_allocataire, :en_attente_validation_salaire, :en_attente_validation_carriere, :en_attente_validation_recap, :en_attente_validation_instruction, :en_attente_validation_revision, :en_attente_validation_inspection, :en_attente_soumission, :en_attente_validation]
  before_action :set_revision_pension, only: [:show, :edit, :update, :destroy, :valider_ligne_carriere, :rejeter_ligne_carriere, :ajouter_carriere, :affecter_allocataire, :affecter_salarie, :update_carriere, :soumettre, :instruire, :soumettre_carriere, :valider_cotisation, :soumettre_recapitulatif, :valider_liquidation, :valider, :rejeter, :valider_revision, :valider_directeur, :traitement_montant_revision, :lettre_notification, :retourner_dossier]
  after_action :update_carriere, only: [:create]
  #after_action :traitement_montant_revision, only: [:valider]

  def index
    @revision_pensions = RevisionPension.where(allocation_id: @allocataire.id)
  end

  def edit
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaire
  end

  def new
    @revision_pension = RevisionPension.new
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaire
  end

  def show
    @gestionnaires = User.gestionnaire_compte_allocataire.where.not(id: @revision_pension.ajouter_par.id).where.not(id: @revision_pension.soumis_par.id) # avoir la liste des gestionnaires
    @gestionnaires_salaries = User.gestionnaire_compte_salarie # avoir la liste des gestionnaires

    #@carrieres = Carriere.en_revision(@revision_pension.id)
    @carriere = Carriere.new

    @montant_rappel = MontantRevision.where(revision_pension: @revision_pension.id).map { |m| m.montant_revision.to_i }.sum

    @point_revision_rc = 0
    @point_revision_rg = 0
  end

  def destroy
    @revision_pension.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @allocataire, @revision_pension], notice: 'Revision pension supprimée avec succès.' }
      format.json { head :no_content }
    end
  end

  def en_attente_affectation_salarie
    @revision_pensions = RevisionPension.en_attente_salaire
  end

  def en_attente_affectation_allocataire
    @revision_pensions = RevisionPension.en_attente_allocation
  end

  def en_attente_validation_allocataire
    @revision_pensions = RevisionPension.where(affectation_allocataire: current_user.id).can_affecte
  end

  def en_attente_soumission
    @revision_pensions = RevisionPension.where(soumis_par: current_user.id).with_creation_state
  end

  def en_attente_validation_salaire
    @revision_pensions = RevisionPension.where(affectation_salarie: current_user.id).can_affecte
  end

  def en_attente_validation_carriere
    @revision_pensions = RevisionPension.with_carriere_soumis_state
  end

  def en_attente_validation_recap
    @revision_pensions = RevisionPension.with_recap_soumis_state
  end

  def en_attente_validation
    @revision_pensions = RevisionPension.with_liquidation_valide_state
  end

  def en_attente_validation_inspection
    @revision_pensions = RevisionPension.with_valider_directeur_state
  end

  def en_attente_validation_revision
    @revision_pensions = RevisionPension.with_valider_state
  end

  def en_attente_instruction
    if current_user.can_instruction?  #check if current_user is a chef_agence_ipres
      @revision_pensions = RevisionPension.where(admin_agence_id: current_user.admin_agence.id).where(workflow_state: :soumis)
    else
      @revision_pensions = RevisionPension.en_attente_instruction
    end
  end

  def create
    @revision_pension = RevisionPension.new(revision_pension_params)
    if @revision_pension.justification_carriere? and @allocataire.carrieres_prestation.rejete.empty?
      flash[:error] = 'Pas de carrière rejeter pour faire une justificatif.'
      redirect_to [:admin, @allocataire, @revision_pension]
    else
      @revision_pension.numero_affiliation = @allocataire.numero_allocataire
      @revision_pension.numero_allocataire = @allocataire.numero_allocataire
      @revision_pension.allocataire = @allocataire
      @revision_pension.ajouter_par = current_user
      @revision_pension.ajouter_le = DateTime.now
      @revision_pension.admin_agence = current_user.admin_agence

      respond_to do |format|
        if @revision_pension.save
          format.html { redirect_to [:admin, @allocataire, @revision_pension], notice: 'Revision pension was successfully created.' }
          format.json { render :show, status: :created, location: @revision_pension }
        else
          format.html { render :new }
          format.json { render json: @revision_pension.errors, status: :unprocessable_entity }
        end
      end
    end

  end

  def update
    if @revision_pension.update(revision_pension_params)
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'La demande de révision est bien mise à jour.'
    else
      render :edit
    end
  end

  def retourner_dossier
    if @revision_pension.update(revision_pension_params)
      if current_user.chef_section_instruction?
        @revision_pension.retour_creation!
      end
      if current_user == @revision_pension.affectation_salarie
        @revision_pension.retour_soumis!
      end
      if current_user.chef_service_cotisation?
        @revision_pension.retour_instruit!
      end
      if current_user == @revision_pension.affectation_allocataire
        @revision_pension.update_allocataire(false)
        @revision_pension.set_allocataire_backup(true)
        @revision_pension.montant_revisions.destroy_all
        @revision_pension.retour_carriere_soumis!
      end
      if current_user.chef_section_liquidation?
        @revision_pension.retour_cotisation_valide!
      end
      if current_user.chef_service_allocation?
        @revision_pension.retour_recap_soumis!
      end
      if current_user.directeur_prestation?
        @revision_pension.retour_liquidation_valide!
      end
      if current_user.inspection?
        @revision_pension.retour_valider!
      end
      @revision_pension.retourne_par = current_user
      @revision_pension.retourne_le = Date.today
      @revision_pension.save
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'La demande de révision est bien mise à jour.'
    else
      flash[:error] = "Une erreur estbsurvenue."
      redirect_to [:admin, @allocataire, @revision_pension]
    end
  end

  def ajouter_carriere
    @carriere = Carriere.new(carriere_params)
    bareme = Admin::Bareme.where(:created_at => @carriere.date_entree.beginning_of_day..@carriere.date_entree.end_of_day).last

    @carriere.salaire = (@carriere.salaire1 || 0) + (@carriere.salaire2 || 0)

    if @carriere.salaire <= 0
      flash[:error] = 'Le salaire du carrière doit pas être égale à zero.'
      redirect_to [:admin, @allocataire, @revision_pension]
    else
      @carriere.numero_affiliation = @revision_pension.numero_affiliation
      @carriere.etat = :en_attente
      @carriere.revision_pension = @revision_pension

      if @carriere.save
        redirect_to [:admin, @allocataire, @revision_pension], notice: 'Carriere ajoutée.'
      else
        flash[:error] = "Erreur sur la création."
        redirect_to [:admin, @allocataire, @revision_pension]
      end
    end
=begin
    if bareme.plafond_salaire < @carriere.salaire
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'Erreur sur la création. Salaire plafonnd dépassé'
    end
=end

  end

  def affecter_allocataire
    #affecter une demande à un gestionnaire allocataire
    if @revision_pension.update(revision_affecter_allocataire_params.merge(affecter_allocataire_date: DateTime.now))
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'Demande Affectée.'
    end
  end

  def affecter_salarie
    #affecter une demande à un gestionnaire allocataire
    @revision_pension.update(revision_affecter_salarie_params.merge(affecter_salarie_date: DateTime.now))
    redirect_to [:admin, @allocataire, @revision_pension], notice: 'Demande Affectée.'
  end

  def valider_ligne_carriere
    carriere = Carriere.find(params[:carriere_id])
    carriere.revision_pension = @revision_pension
    carriere.valide!
    redirect_to [:admin, @allocataire, @revision_pension], notice: 'Ligne Carrière validée'
  end

  def rejeter_ligne_carriere
    carriere = Carriere.find(params[:carriere_id])
    carriere.revision_pension = @revision_pension
    carriere.rejete!
    redirect_to [:admin, @allocataire, @revision_pension], notice: 'Ligne Carrière rejetée'
  end

  def delete_ligne_carriere
    carriere = Carriere.find(params[:carriere_id])
    carriere.destroy!
    redirect_to [:admin, @allocataire, @revision_pension], notice: 'Ligne Carrière rejetée'
  end

  #region : Workflow Validation REVISION PENSION
  #
  def soumettre
    #affecter une demande à un gestionnaire allocataire
    if @revision_pension.update(revision_commentaire_params)
      if @revision_pension.creation?
        @revision_pension.est_soumis!
      end
      @revision_pension.date_soumission = DateTime.now
      @revision_pension.traite_par = current_user
      @revision_pension.traite_le = DateTime.now
      @revision_pension.motif_retour = nil
      @revision_pension.save
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'La demande de revision est soumise'
    end
  end

  def soumettre_old
    if @revision_pension.creation?
      @revision_pension.est_soumis!
      @revision_pension.date_soumission = DateTime.now
      @revision_pension.traite_par = current_user
      @revision_pension.traite_le = DateTime.now
      @revision_pension.motif = nil
      @revision_pension.motif_retour = nil
      @revision_pension.save
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'La demande de revision est soumise'
    else
      redirect_to [:admin, @allocataire, @revision_pension]
    end

  end

  def instruire

    if current_user.can_instruction? and @revision_pension.ajouter_par.admin_agence != current_user.admin_agence
      flash[:error] = 'Vous n\'avez pas le droit de faire une action sur ce dossier'
      redirect_to [:admin, @revision_pension]
    end

    if @revision_pension.soumis?
      @revision_pension.est_instruit!
      @revision_pension.instruit_par = current_user
      @revision_pension.instruit_le = DateTime.now
      @revision_pension.motif = nil
      @revision_pension.motif_retour = nil
      @revision_pension.save
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'Demande Instruit'
    else
      redirect_to [:admin, @allocataire, @revision_pension]
    end
  end

  def soumettre_carriere
    if @revision_pension.instruit?
      @revision_pension.est_carriere_soumis!
      @revision_pension.traite_par = current_user
      @revision_pension.traite_le = DateTime.now
      @revision_pension.motif_retour = nil
      @revision_pension.save
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'Carrière soumis pour validation'
    else
      redirect_to [:admin, @allocataire, @revision_pension]
    end
  end

  def valider_cotisation
    if @revision_pension.cotisation_valide?
      redirect_to [:admin, @allocataire, @revision_pension]
    else
      @revision_pension.est_carriere_valide!
      @revision_pension.traite_par = current_user
      @revision_pension.traite_le = DateTime.now
      @revision_pension.motif = nil
      @revision_pension.motif_retour = nil
      @revision_pension.save
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'Carrière validée avec succés'

    end
  end

  def soumettre_recapitulatif
    if @revision_pension.cotisation_valide?
      @revision_pension.est_recap_soumis!
      @revision_pension.traite_par = current_user
      @revision_pension.traite_le = DateTime.now
      @revision_pension.motif = nil
      @revision_pension.motif_retour = nil
      @revision_pension.save
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'Recap soumis pour validation'
    else
      redirect_to [:admin, @allocataire, @revision_pension]
    end
  end

=begin
  def soumettre_recapitulatif
    if @revision_pension.cotisation_valide?
      redirect_to [:admin, @allocataire, @revision_pension]
    else
      @revision_pension.est_recap_valide!
      @revision_pension.traite_par = current_user
      @revision_pension.traite_le = DateTime.now
      @revision_pension.motif = nil
      @revision_pension.save
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'Recap soumis pour validation'
    end
  end
=end

  def valider_liquidation
    if @revision_pension.recap_soumis?
      @revision_pension.est_recap_valide!
      @revision_pension.traite_par = current_user
      @revision_pension.traite_le = DateTime.now
      @revision_pension.motif = nil
      @revision_pension.motif_retour = nil
      @revision_pension.save
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'Recap validée avec succés'
    else
      redirect_to [:admin, @allocataire, @revision_pension]
    end
  end

  def valider
    if @revision_pension.liquidation_valide?
      @revision_pension.est_dossier_valide!
      @revision_pension.valider_par = current_user
      @revision_pension.valider_le = DateTime.now
      @revision_pension.motif_retour = nil
      @revision_pension.save
      redirect_to [:admin, @allocataire, @revision_pension], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @allocataire, @revision_pension]
    end
  end

  def valider_directeur
    if @revision_pension.valider?
      @revision_pension.est_valide_cs!
      @revision_pension.traite_par = current_user
      @revision_pension.traite_le = DateTime.now
      @revision_pension.motif = nil
      @revision_pension.motif_retour = nil
      @revision_pension.save

      redirect_to [:admin, @allocataire, @revision_pension], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @allocataire, @revision_pension]
    end
  end

  def valider_revision
    if @revision_pension.valider_directeur?
      @revision_pension.est_valide_revision!
      @revision_pension.traite_par = current_user
      @revision_pension.traite_le = DateTime.now
      @revision_pension.motif = nil
      @revision_pension.motif_retour = nil
      @revision_pension.save

      montant_rappel = @revision_pension.montant_revisions.inject(0) { |sum, i| sum + i.montant }

      @revision_pension.allocataire.montant_rappel = montant_rappel

      redirect_to [:admin, @allocataire, @revision_pension], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @allocataire, @revision_pension]
    end
  end

  def rejeter
    if @revision_pension.liquidation_valide?
      @revision_pension.traite_le = DateTime.now
      @revision_pension.traite_par = current_user
      @revision_pension.motif = nil
      @revision_pension.motif_retour = nil
      @revision_pension.est_dossier_rejete!
      redirect_to [:admin, @revision_pension], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @revision_pension]
    end
  end

  # endregion

  def traitement_montant_revision
    @carrieres = Carriere.en_revision(@revision_pension.id)
    @carrieres_revision_cadre = @carrieres.valide.regime_cadre
    @carrieres_revision_general = @carrieres.valide.regime_general

    regime_general = Admin::TypeRegime.find_by(code: "GENERAL")
    regime_cadre = Admin::TypeRegime.find_by(code: "CADRE")

    @cumul_point_cadre = @carrieres_revision_cadre.sum(:points)

    @cumul_point_general = @carrieres_revision_general.sum(:points)

    unless @revision_pension.allocataire.date_jouissance.nil?
      dates = (Date.today.year..@revision_pension.allocataire.date_jouissance.year).to_a

      create_montant_revision(regime_cadre, @cumul_point_cadre, dates) unless @cumul_point_cadre.nil?
      create_montant_revision(regime_general, @cumul_point_general, dates) unless @cumul_point_general.nil?

      update_montant_revision

      calcul_montant_annee_restant(regime_cadre, @cumul_point_cadre) unless @cumul_point_cadre.nil?
      calcul_montant_annee_restant(regime_general, @cumul_point_general) unless @cumul_point_general.nil?
    end

  end

  def en_attente

  end

  def lettre_notification

    #@carrieres = Carriere.en_revision(@revision_pension.id)
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "lettre notification n°. #{@revision_pension.id}",
               page_size: 'A4',
               template: "admin/revisions/lettre_notification.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  private

  def calcul_montant_annee_restant(regime, cumul_point)
    unless @cumul_point_cadre.nil? or cumul_point <= 0

      debut_nombre_mois = (@revision_pension.allocataire.date_jouissance.next_year.year * 12) - (@revision_pension.allocataire.date_jouissance.year * 12 + @revision_pension.allocataire.date_jouissance.month)
      fin_nombre_mois = (Date.today.next_year.year * 12) - (Date.today.year * 12 + Date.today.month)

      montant_revision = MontantRevision.new
      montant_revision.annee = @revision_pension.allocataire.date_jouissance.year
      montant_revision.point_revision = cumul_point
      montant_revision.type_regime = regime
      montant_revision.revision_pension = @revision_pension

      date_debut = Date.parse("01-01-" + montant_revision.annee.to_s)
      date_fin = Date.parse("31-12-" + montant_revision.annee.to_s)
      bareme = montant_revision.type_regime.admin_bareme_pensions.find_by("date_debut_validite >= ? AND date_fin_validite <= ?", date_debut, date_fin)

      montant_revision.valeur_point_annuel = bareme.valeur_point_annuelle / 12 * debut_nombre_mois
      montant_revision.montant_revision = montant_revision.valeur_point_annuel * montant_revision.point_revision unless montant_revision.valeur_point_annuel.nil?
      montant_revision.save

      montant_revision = MontantRevision.new
      montant_revision.annee = Date.today.year
      montant_revision.point_revision = cumul_point_general
      montant_revision.type_regime = regime
      montant_revision.revision_pension = @revision_pension

      date_debut = Date.parse("01-01-" + montant_revision.annee.to_s)
      date_fin = Date.parse("31-12-" + montant_revision.annee.to_s)
      bareme = montant_revision.type_regime.admin_bareme_pensions.find_by("date_debut_validite >= ? AND date_fin_validite <= ?", date_debut, date_fin)

      montant_revision.valeur_point_annuel = bareme.valeur_point_annuelle / 12 * fin_nombre_mois
      montant_revision.montant_revision = montant_revision.valeur_point_annuel * montant_revision.point_revision unless montant_revision.valeur_point_annuel.nil?
      montant_revision.save

    end
  end

  def update_montant_revision
    montant_revisions = MontantRevision.all
    montant_revisions.each do |montant_revision|
      date_debut = Date.parse("01-01-" + montant_revision.annee.to_s)
      date_fin = Date.parse("31-12-" + montant_revision.annee.to_s)
      bareme = montant_revision.type_regime.admin_bareme_pensions.find_by("date_debut_validite >= ? AND date_fin_validite <= ?", date_debut, date_fin)
      montant_revision.valeur_point_annuel = bareme.valeur_point_annuelle
      montant_revision.montant_revision = montant_revision.valeur_point_annuel * montant_revision.point_revision unless montant_revision.valeur_point_annuel.nil?
      montant_revision.save
    end
  end

  def create_montant_revision(regime, cumul_point, dates)
    unless cumul_point.nil? or cumul_point <= 0
      dates.each do |annee|
        montant_revision = MontantRevision.new
        montant_revision.annee = annee
        montant_revision.type_regime = regime
        montant_revision.point_revision = cumul_point
        montant_revision.revision_pension = @revision_pension
        montant_revision.save
      end

    end
  end

  def set_revision_pension
    @revision_pension = @allocataire.revision_pensions.find(params[:id] || params[:revision_pension_id])
  end

  def revision_affecter_allocataire_params
    params.require(:revision_pension).permit(:affecter_allocataire)
  end

  def revision_commentaire_params
    params.require(:revision_pension).permit(:commentaire_allocataire, :document)
  end

  def revision_affecter_salarie_params
    params.require(:revision_pension).permit(:affecter_salarie)
  end

  def revision_pension_params
    params.require(:revision_pension).permit(:type_motif, :date_reception, :commentaire, :soumis_par_id, :motif_retour)
  end

  def carriere_params
    params.require(:carriere).permit(:date_entree, :date_sortie, :type_regime_id, :salaire, :ref_employeur, :exercice, :points, :salaire1, :salaire2, :motif)
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id])
  end

  def update_carriere
    unless @revision_pension.integration_carriere?
      carrieres = @allocataire.carrieres_prestation.rejete

      carrieres.each do |carriere|
        carriere.etat = :en_attente
        carriere.revision_pension = @revision_pension
        carriere.save!
      end
    end
  end

end
