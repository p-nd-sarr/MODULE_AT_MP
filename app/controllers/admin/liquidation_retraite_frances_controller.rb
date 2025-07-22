# frozen_string_literal: true

class Admin::LiquidationRetraiteFrancesController < Admin::ApplicationController
  before_action :set_demande_liquidation, except: %i[index new create en_attente ajoutee carriere_en_attente recap_en_attente affecter_allocataire_all affecter_salarie_all destroy_document validation_en_attente dossiers_retournes demandes_affectees dossiers_incomplets]
  before_action :can_create?, only: %i[new create]

  def index
    @q = LiquidationRetraiteFrance.visible_for_admins.ransack(params[:q])
    @demande_liquidations = @q.result.includes(:agence_creation)
    @total = @demande_liquidations.count
    @demande_liquidations = @demande_liquidations.order('created_at DESC')
    unless params[:format] == 'xlsx'
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)
    end
  end

  def en_attente
    if current_user.chef_section_instruction?
      if current_user.can_instruction?
        @demande_liquidations_export = LiquidationRetraiteFrance.LiquidationRetraiteFrance.where(admin_agence_id: current_user.admin_agence.id).where(workflow_state: :soumis)
        @q = @demande_liquidations_export.ransack(params[:q])
        @demande_liquidations = @q.result
        @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

      else
        @demande_liquidations_export = LiquidationRetraiteFrance.where(workflow_state: :soumis)
        @q = @demande_liquidations_export.ransack(params[:q])
        @demande_liquidations = @q.result
        @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

      end
    elsif current_user.chef_section_liquidation?
      @demande_liquidations_export = LiquidationRetraiteFrance.en_attente_allocation
      @q = @demande_liquidations_export.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    elsif current_user.gestionnaire_compte_allocataire?
      @demande_liquidations_export = LiquidationRetraiteFrance.where(affectation_allocataire: current_user.id).can_affecte
      @q = @demande_liquidations_export.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    elsif current_user.gestionnaire_compte_salarie?
      @demande_liquidations_export = LiquidationRetraiteFrance.where(affectation_salarie: current_user.id).non_retourner.where(workflow_state: %i[instruit cotisation_valide])
      @q = @demande_liquidations_export.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    elsif current_user.chef_service_prest_ext?
      @demande_liquidations_export = LiquidationRetraiteFrance.en_attente_allocation
      @q = LiquidationRetraiteFrance.en_attente_allocation.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    elsif current_user.chef_service_cotisation?
      @demande_liquidations_export = LiquidationRetraiteFrance.en_attente_cotisation
      @q = LiquidationRetraiteFrance.en_attente_cotisation.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    elsif current_user.chef_agence?
      @demande_liquidations_export = LiquidationRetraiteFrance.with_soumis_state.where(agence_creation: current_user.admin_agence)
      @q = @demande_liquidations_export.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    else
      @demande_liquidations_export = LiquidationRetraiteFrance.with_soumis_state
      @q = @demande_liquidations_export.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    end

    @demande_liquidations_en_attente = @demande_liquidations.en_attente.page(params[:page]).per(100)
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires allocataires
    @gestionnaires_salaries = User.gestionnaire_compte_salarie # avoir la liste des gestionnaires salaries
  end

  def validation_en_attente
    @demande_liquidations = LiquidationRetraiteFrance.with_liquidation_valide_state.includes(:agence_creation).page(params[:page]).per(100)
  end

  def carriere_en_attente
    @demande_liquidations = LiquidationRetraiteFrance.with_carriere_soumis_state.includes(:agence_creation).page(params[:page]).per(100)
  end

  def demandes_affectees
    @q = LiquidationRetraiteFrance.demandes_affectees.ransack(params[:q])
    @demande_liquidations = @q.result.includes(:agence_creation)
    @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    @demande_liquidations_export = LiquidationRetraiteFrance.demandes_affectees
  end

  def recap_en_attente
    @demande_liquidations = LiquidationRetraiteFrance.with_recap_soumis_state.includes(:agence_creation).page(params[:page]).per(100)
  end

  def en_attente_validation
    @demande_liquidations = LiquidationRetraiteFrance.with_recap_soumis_state.includes(:agence_creation).page(params[:page]).per(100)
  end

  def ajoutee
    @demande_liquidations = current_user.liquidation_retraite_france_creees.includes(:agence_creation).page(params[:page]).per(100)
  end

  def dossiers_retournes
    if current_user.gestionnaire_compte_allocataire?
      @demande_liquidations = current_user.liquidation_retraite_france_creees.dossiers_retournes.page(params[:page]).per(100)
    elsif current_user.gestionnaire_compte_salarie?
      @demande_liquidations = LiquidationRetraiteFrance.mes_affectations_salarie(current_user.id).where(workflow_state: :instruit).dossiers_retournes.page(params[:page]).per(100)
    elsif current_user.chef_section_instruction?
      @demande_liquidations = LiquidationRetraiteFrance.where(workflow_state: :soumis).dossiers_retournes.page(params[:page]).per(100)
    else
      @demande_liquidations = LiquidationRetraiteFrance.dossiers_retournes.page(params[:page]).per(100)
    end
  end

  def dossiers_incomplets
    @demande_liquidations = LiquidationRetraiteFrance.dossiers_incomplets.page(params[:page]).per(100)
  end

  def show
    @document_demande_liquidation = DocumentLiquidationRetraite.new
    @gestionnaires = User.gestionnaire_compte_allocataire.where.not(id: @demande_liquidation.ajoute_par.id) # avoir la liste des gestionnaires
    @gestionnaires_salaries = User.gestionnaire_compte_salarie.where.not(id: @demande_liquidation.ajoute_par.id) # avoir la liste des gestionnaires

    @carriere = Carriere.new

    @employeur_ext = EmployeurExterieur.new
    @employeur_exts = EmployeurExterieur.all
    @carrieres_exterieure = CarrieresExterieure.new
    @carrieres_exterieures = @demande_liquidation.carrieres_exterieures
    @periode_assurancePR = PeriodeAssurance.new
    @periode_assurances_PR = @demande_liquidation.periode_assurances.pays_residence
    # @periode_assurances_PR = PeriodeAssurance.where(liquidation_retraite_france: :@demande_liquidation, type_periode: :pays_residence)
    @periode_assuranceSP = PeriodeAssurance.new
    @periode_assurances_SP = @demande_liquidation.periode_assurances.second_pays

    @revenu_conjoint = RevenuConjoint.new
    @revenu_conjoints = @demande_liquidation.revenu_conjoints
    @bien_pers_conjoint = BienPersConjoint.new
    @bien_pers_conjoints = @demande_liquidation.bien_pers_conjoints
    @donation_conjoint = DonationConjoint.new
    @donation_conjoints = @demande_liquidation.donation_conjoints

    @cfs_conjoint = CfsConjoint.new
    @cfs_conjoints = @demande_liquidation.cfs_conjoints

    @cfs_enfant = CfsEnfant.new
    # @cfs_enfants = @demande_liquidation.cfs_enfants
    @cfs_enfants = CfsEnfant.where(liquidation_retraite_france_id: @demande_liquidation.id)
    @cfs_enfants_direct = @demande_liquidation.cfs_enfants.where(filiation: :direct)
    @cfs_enfants_indirect = @demande_liquidation.cfs_enfants.where(filiation: :indirect)
    @cfs_correspondance = CfsCorrespondance.new
    @cfs_correspondances = @demande_liquidation.cfs_correspondances
    # tableau_rappel
  end

  def rejeter_create
    if @demande_liquidation.update(liquidation_retraite_france_rejet_params.merge(etat: :rejete,
                                                                                  traite_par: current_user,
                                                                                  traite_le: DateTime.now))
      redirect_to admin_liquidation_retraite_frances_path, notice: 'Deamande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def new
    @demande_liquidation = LiquidationRetraiteFrance.new(numero_affiliation: params[:numero_affiliation])
  end

  def edit; end

  def create
    @demande_liquidation = LiquidationRetraiteFrance.new(demande_liquidation_params)

    @allocataire = Allocataire.find_by(numero_allocataire: @demande_liquidation.numero_affiliation)
    if @allocataire.nil?
      @demande_liquidation.ajoute_par = current_user
      @demande_liquidation.traite_par = current_user
      @demande_liquidation.documents_deposes_obligatoires = params[:documents_deposes_obligatoires]
      @demande_liquidation.documents_deposes_facultatifs = params[:documents_deposes_facultatifs]
      participant = Psrm::Participant.find_by(matric: @demande_liquidation.numero_affiliation)
      if participant
        @demande_liquidation.nom = participant.try(:nom)
        @demande_liquidation.prenom = participant.try(:prenom)
        @demande_liquidation.update_numero_trouve!(true)
        @demande_liquidation.update_affiliation!(true)
      end
      @demande_liquidation.date_jouissance = @demande_liquidation.date_cessation_activite
      if @demande_liquidation.save
        redirect_to [:admin, @demande_liquidation], notice: 'La demande de liquidation est créée.'
      else
        render :new
      end
    else
      flash[:error] = 'Allocataire existe déjà'
      render :new
    end
  end

  def update
    if @demande_liquidation.update(demande_liquidation_params)
      @demande_liquidation.etat_civil_demandeur_valide!(false)
      @demande_liquidation.documents_deposes_obligatoires = params[:documents_deposes_obligatoires]
      @demande_liquidation.documents_deposes_facultatifs = params[:documents_deposes_facultatifs]
      @demande_liquidation.save
      redirect_to [:admin, @demande_liquidation], notice: 'La demande de liquidation est bien mise à jour.'
    else
      render :edit
    end
  end

  def destroy
    @demande_liquidation.destroy
    redirect_to admin_liquidation_retraite_frances_path, notice: 'La demande de liquidation est supprimée.'
  end

  def ajouter_employeur_ext
    @employeur = EmployeurExterieur.new(employeur_ext_params)
    if @employeur.save
      redirect_to [:admin, @demande_liquidation], notice: 'Employeur ajoutée.'
    else
      redirect_to [:admin, @demande_liquidation], notice: 'Erreur sur la création.'
    end
  end

  def ajouter_carrires_prest_exterieure
    @carrieres_exterieure = CarrieresExterieure.new(carrieres_prest_exterieure_params)
    @carrieres_exterieure.liquidation_retraite_france = @demande_liquidation
    @carrieres_exterieure.etat = :en_attente
    @carrieres_exterieure.retraite!

    if @carrieres_exterieure.save
      redirect_to [:admin, @demande_liquidation], notice: 'Carriere ajoutée.'
    else
      redirect_to [:admin, @demande_liquidation], notice: 'Erreur sur la création.'
    end
  end

  def destroy_carrieres_exterieure
    @carrieres_exterieure = CarrieresExterieure.find(params[:carrieres_exterieure_id])
    @carrieres_exterieure.destroy
    redirect_to [:admin, @demande_liquidation], notice: 'Suppression faite avec succès.'
  end

  def ajouter_revenu_conjoint
    @revenu_conjoint = RevenuConjoint.new(revenu_conjoint_params)
    @revenu_conjoint.liquidation_retraite_france = @demande_liquidation

    if @revenu_conjoint.save
      redirect_to [:admin, @demande_liquidation], notice: 'Revenu du conjoint ajouté.'
    else
      redirect_to [:admin, @demande_liquidation], notice: 'Erreur sur la création.'
    end
  end

  def destroy_revenu_conjoint
    @revenu_conjoint = RevenuConjoint.find(params[:revenu_conjoint_id])
    @revenu_conjoint.destroy
    redirect_to [:admin, @demande_liquidation], notice: 'Suppression faite avec succès.'
  end

  def ajouter_cfs_conjoint
    @cfs_conjoint = CfsConjoint.new(cfs_conjoint_params)
    @cfs_conjoint.liquidation_retraite_france = @demande_liquidation
    @cfs_conjoint.ajoute_par_id = current_user.id
    @cfs_conjoint.numero_securite_sociale = @demande_liquidation.numero_securite_sociale
    unless @demande_liquidation.numero_affiliation.nil?
      @cfs_conjoint.numero_affiliation = @demande_liquidation.numero_affiliation
    end
    @cfs_conjoint.etat = :valide
    @cfs_conjoint.prenom_salarie = @demande_liquidation.prenom
    @cfs_conjoint.nom_salarie = @demande_liquidation.nom
    unless @demande_liquidation.numero_piece.nil?
      @cfs_conjoint.nin = @demande_liquidation.numero_piece
    end
    if @demande_liquidation.celibataire?
      @cfs_conjoint.etat_civil = :celibataire
    elsif @demande_liquidation.marie?
      @cfs_conjoint.etat_civil = :marie
    end
    unless @demande_liquidation.regime_matrimoniale.nil?
      @cfs_conjoint.regime_matrimoniale = @demande_liquidation.regime_matrimoniale
    end
    unless @demande_liquidation.nombre_femmes.nil?
      @cfs_conjoint.nombre_femmes = @demande_liquidation.nombre_femmes
    end

    if @cfs_conjoint.save
      redirect_to [:admin, @demande_liquidation], notice: 'Ajout conjoint reussi.'
    else
      # render :ajouter_cfs_conjoint
      redirect_to [:admin, @demande_liquidation], notice: 'Erreur sur la création.'
    end
  end

  def destroy_cfs_conjoint
    @cfs_conjoint = CfsConjoint.find(params[:cfs_conjoint_id])
    @cfs_conjoint.destroy
    redirect_to [:admin, @demande_liquidation], notice: 'Suppression faite avec succès.'
  end

  def details_cfs_conjoint
    @cfs_conjoint_details = CfsConjoint.find(params[:cfs_conjoint_id])
  end

  # def valider_conjoint
  #   @cfs_conjoint.valide!
  #   flash[:notice] = 'Demande traitée'
  #   redirect_to [:admin, @demande_liquidation], notice: 'Validation conjoint reussie.'
  # end
  #
  # def rejeter_conjoint
  #   @cfs_conjoint.rejete!
  #   flash[:notice] = "Demande traitée"
  #   redirect_to [:admin, @demande_liquidation], notice: 'Rejet conjoint reussi.'
  # end

  def ajouter_cfs_enfant
    @cfs_enfant = CfsEnfant.new(cfs_enfant_params)
    @cfs_enfant.liquidation_retraite_france = @demande_liquidation
    @cfs_enfant.ajoute_par_id = current_user.id
    #@@cfs_enfant.etat = :creation

    if @cfs_enfant.save
      redirect_to [:admin, @demande_liquidation], notice: 'Ajout enfant réussi.'
    else
      redirect_to [:admin, @demande_liquidation], notice: 'Erreur sur la création.'
    end
  end

  def destroy_cfs_enfant
    @cfs_enfant = CfsEnfant.find(params[:cfs_enfant_id])
    @cfs_enfant.destroy
    redirect_to [:admin, @demande_liquidation], notice: 'Suppression faite avec succès.'
  end

  def ajouter_donation_conjoint
    @donation_conjoint = DonationConjoint.new(donation_conjoint_params)
    @donation_conjoint.liquidation_retraite_france = @demande_liquidation

    if @donation_conjoint.save
      redirect_to [:admin, @demande_liquidation], notice: 'Donation de bien du conjoint ajoutée.'
    else
      redirect_to [:admin, @demande_liquidation], notice: 'Erreur sur la création.'
    end
  end

  def destroy_donation_conjoint
    @donation_conjoint = DonationConjoint.find(params[:donation_conjoint_id])
    @donation_conjoint.destroy
    redirect_to [:admin, @demande_liquidation], notice: 'Suppression faite avec succès.'
  end

  def ajouter_bien_pers_conjoint
    @bien_pers_conjoint = BienPersConjoint.new(bien_pers_conjoint_params)
    @bien_pers_conjoint.liquidation_retraite_france = @demande_liquidation

    if @bien_pers_conjoint.save
      redirect_to [:admin, @demande_liquidation], notice: 'Bien du conjoint ajouté.'
    else
      redirect_to [:admin, @demande_liquidation], notice: 'Erreur sur la création.'
    end
  end

  def destroy_bien_pers_conjoint
    @bien_pers_conjoint = BienPersConjoint.find(params[:bien_pers_conjoint_id])
    @bien_pers_conjoint.destroy
    redirect_to [:admin, @demande_liquidation], notice: 'Suppression faite avec succès.'
  end

  def ajouter_periode_assurance_PR
    @periode_assurancePR = PeriodeAssurance.new(periode_assurance_params)
    @periode_assurancePR.liquidation_retraite_france = @demande_liquidation
    @periode_assurancePR.pays_residence!
    @periode_assurancePR.retraite!

    if @periode_assurancePR.save
      redirect_to [:admin, @demande_liquidation], notice: 'Période dans le pays de résidence ajoutée.'
    else
      redirect_to [:admin, @demande_liquidation], notice: 'Erreur sur la création.'
    end
  end

  def ajouter_periode_assurance_SP
    @periode_assuranceSP = PeriodeAssurance.new(periode_assurance_params)
    @periode_assuranceSP.liquidation_retraite_france = @demande_liquidation
    @periode_assuranceSP.second_pays!
    @periode_assuranceSP.retraite!

    if @periode_assuranceSP.save
      redirect_to [:admin, @demande_liquidation], notice: 'Période dans le second pays ajoutée.'
    else
      redirect_to [:admin, @demande_liquidation], notice: 'Erreur à la création.'
    end
  end

  def destroy_periode_assurance
    @periode_assurance = PeriodeAssurance.find(params[:periode_assurance_id])
    @periode_assurance.destroy
    redirect_to [:admin, @demande_liquidation], notice: 'Suppression faite avec succès.'
  end

  def ajouter_cfs_correspondance
    @cfs_correspondance = CfsCorrespondance.new(cfs_correspondance_params)
    @cfs_correspondance.liquidation_retraite_france = @demande_liquidation
    @cfs_correspondance.date = DateTime.now
    @cfs_correspondance.numero_dossier = @demande_liquidation.num_dossier
    @cfs_correspondance.ajoute_par_id = current_user.id

    if @cfs_correspondance.save
      redirect_to [:admin, @demande_liquidation], notice: 'La correspondance a bien été ajoutée.'
    else
      redirect_to [:admin, @demande_liquidation], error: 'Erreur à la création.'
    end
  end

  def destroy_cfs_correspondance
    @cfs_correspondance = CfsCorrespondance.find(params[:cfs_correspondance_id])
    @cfs_correspondance.destroy
    redirect_to [:admin, @demande_liquidation], notice: 'Suppression faite avec succès.'
  end

  ##############
  #
  #
  #
  def soumettre_action
    if @demande_liquidation.creation?
      if @demande_liquidation.update(commentaire_soumission_params.merge(motif: nil))
        @demande_liquidation.date_soumission = DateTime.now
        @demande_liquidation.traite_par = current_user
        @demande_liquidation.traite_le = DateTime.now
        @demande_liquidation.motif = nil
        @demande_liquidation.est_soumis!
        @demande_liquidation.save
        redirect_to [:admin, @demande_liquidation], notice: 'La demande de liquidation est soumise'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @demande_liquidation]
      end

    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def instruire_action
    if current_user.can_instruction? && (@demande_liquidation.ajoute_par.admin_agence != current_user.admin_agence)
      flash[:error] = 'Vous n\'avez pas le droit de faire une action sur ce dossier'
      redirect_to [:admin, @demande_liquidation]
    end

    if @demande_liquidation.soumis?
      if @demande_liquidation.update(commentaire_instruction_params.merge(motif: nil))

        @demande_liquidation.traite_par = current_user
        @demande_liquidation.instruit_par = current_user
        @demande_liquidation.instruit_le = DateTime.now
        @demande_liquidation.est_instruit!
        @demande_liquidation.save
        redirect_to [:admin, @demande_liquidation], notice: 'Demande Instruit'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @demande_liquidation]
      end
    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def valider_carriere_action
    if @demande_liquidation.instruit?
      if @demande_liquidation.update(commentaire_carriere_params.merge(motif: nil))

        @demande_liquidation.soumission_carriere_par = current_user
        @demande_liquidation.date_soumission_carriere = DateTime.now
        @demande_liquidation.motif = nil
        @demande_liquidation.est_carriere_soumis!
        @demande_liquidation.date_generation = DateTime.now # Ajouter la date de generation de la lettre de notification de la liquidation
        @demande_liquidation.save

        redirect_to [:admin, @demande_liquidation], notice: 'Carrière soumis pour validation'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @demande_liquidation]
      end
    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def cotisation_valide_action
    if @demande_liquidation.cotisation_valide?
      redirect_to [:admin, @demande_liquidation]
    else
      if @demande_liquidation.update(commentaire_validation_carriere_params.merge(motif: nil))
        @demande_liquidation.validation_carriere_par = current_user
        @demande_liquidation.traite_par = current_user
        @demande_liquidation.date_validation_carriere = DateTime.now
        @demande_liquidation.motif = nil
        @demande_liquidation.est_carriere_valide!
        @demande_liquidation.save
        redirect_to [:admin, @demande_liquidation], notice: 'Carrière validée avec succés'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @demande_liquidation]
      end

    end
  end

  def valider_recapitulatif_action
    if @demande_liquidation.cotisation_valide?
      if @demande_liquidation.update(commentaire_tableau_params.merge(motif: nil))

        @demande_liquidation.soumission_validation_par = current_user
        @demande_liquidation.traite_par = current_user
        @demande_liquidation.date_soumission_validation = DateTime.now
        @demande_liquidation.est_recap_soumis!
        @demande_liquidation.save
        redirect_to [:admin, @demande_liquidation], notice: 'Recap soumis pour validation'

      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @demande_liquidation]
      end
    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def liquidation_valide_action
    if @demande_liquidation.recap_soumis?
      if @demande_liquidation.update(commentaire_validation_tableau_params.merge(motif: nil))

        @demande_liquidation.validation_liquidation_par = current_user
        @demande_liquidation.traite_par = current_user
        @demande_liquidation.date_validation_liquidation = DateTime.now
        @demande_liquidation.motif = nil
        @demande_liquidation.est_recap_valide!
        @demande_liquidation.save

        redirect_to [:admin, @demande_liquidation], notice: 'Recap validée avec succés'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        redirect_to [:admin, @demande_liquidation]
      end

    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def dossier_valide_action
    if @demande_liquidation.update!(commentaire_validation_params.merge(motif: nil))

      @demande_liquidation.traite_par = current_user
      if @demande_liquidation.est_dossier_valide!
        @demande_liquidation.valider_par = current_user
        @demande_liquidation.valider_le = DateTime.now
        @demande_liquidation.traite_le = DateTime.now
        @demande_liquidation.save
      elsif @demande_liquidation.halted?
        flash[:error] = @demande_liquidation.halted_because
      else
        flash[:error] = 'Une erreur est survenue lors de la validation du dossier'
      end
      redirect_to [:admin, @demande_liquidation], notice: 'Dossier validé avec succés'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      redirect_to [:admin, @demande_liquidation]
    end
  end

  ##############

  def retourner_process
    if liquidation_retraite_france_rejet_params[:motif].nil?
      flash[:error] = 'Motif du retour est obligataoire!'
      redirect_to [:admin, @demande_liquidation]
    else
      if @demande_liquidation.soumis?
        @demande_liquidation.update(traite_par: current_user,
                                    traite_le: nil)
        @demande_liquidation.retour_creation!
      elsif @demande_liquidation.instruit?
        @demande_liquidation.update(instruit_par: nil,
                                    traite_par: current_user,
                                    instruit_le: nil)
        @demande_liquidation.retour_soumis!
      elsif @demande_liquidation.carriere_soumis?

        @demande_liquidation.update(traite_par: current_user,
                                    traite_le: nil)
        @demande_liquidation.retourner_all_carrieres(@demande_liquidation.carrieres_prestation)
        @demande_liquidation.retour_instruit!
      elsif @demande_liquidation.cotisation_valide?
        @demande_liquidation.update(traite_par: current_user,
                                    traite_le: nil)
        @demande_liquidation.retour_carriere!
      elsif @demande_liquidation.recap_soumis?
        @demande_liquidation.update(affecter_allocataire: nil,
                                    traite_par: current_user,
                                    traite_le: nil)
        @demande_liquidation.retour_cotisation!
      elsif @demande_liquidation.liquidation_valide?
        @demande_liquidation.update(traite_par: current_user,
                                    traite_le: nil)
        @demande_liquidation.retour_recap!
      end
      if @demande_liquidation.update(liquidation_retraite_france_rejet_params.merge(traite_par: current_user,
                                                                                    traite_le: DateTime.now))
        redirect_to admin_liquidation_retraite_frances_path, notice: 'Deamande traitée.'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        render :rejeter
      end
    end
  end

  def rejeter_process
    if @demande_liquidation.update(liquidation_retraite_france_rejet_params.merge(etat: :rejete,
                                                                                  traite_par: current_user,
                                                                                  traite_le: DateTime.now))
      redirect_to [:admin, @demande_liquidation], notice: 'Demande rejetée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def rejeter_ligne_carriere
    carriere_prestation = Carriere.find(params[:carriere_id])
    # carriere_prestation.rejete!
    # redirect_to [:admin, @demande_liquidation]

    if carriere_prestation.update(rejet_ligne_carriere_params.merge(etat: :rejete))
      redirect_to [:admin, @demande_liquidation], notice: 'ligne de carriere rejetée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def rembourser_ligne_carriere
    carriere_prestation = Carriere.find(params[:carriere_id])
    carriere_prestation.a_rembourse!
    @demande_liquidation.touch
    redirect_to [:admin, @demande_liquidation]
  end

  def create_document
    @document_demande_liquidation = DocumentLiquidationRetraite.new(document_demande_liquidation_params)
    @document_demande_liquidation.liquidation_retraite_france = @demande_liquidation

    if @document_demande_liquidation.save
      @demande_liquidation.documents_valide!(false)
      redirect_to [:admin, @demande_liquidation], notice: 'Le document est ajouté.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document."
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def destroy_document
    @demande_liquidation = LiquidationRetraiteFrance.find(params[:liquidation_retraite_france_id])
    @document_demande_liquidation = DocumentLiquidationRetraite.find(params[:document_liquidation_retraites_id])
    @document_demande_liquidation.destroy
    redirect_to [:admin, @demande_liquidation], notice: 'Le document a été supprimé avec succès'
  end

  def show_facture
    @demande_liquidation = LiquidationRetraiteFrance.find(params[:id] || params[:liquidation_retraite_france_id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Récépissé demande de liquidation No. #{@demande_liquidation.num_dossier}",
               page_size: 'A4',
               template: 'admin/liquidation_retraite_frances/show_facture.html.erb',
               layout: 'pdf.html',
               orientation: 'Landscape',
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def show_formulaire
    @demande_liquidation = LiquidationRetraiteFrance.find(params[:id] || params[:liquidation_retraite_france_id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Formulaire de liaison N° SE 341-11 : #{@demande_liquidation.num_dossier}",
               page_size: 'A3',
               template: 'admin/liquidation_retraite_frances/show_formulaire.html.erb',
               layout: 'pdf.html',
               orientation: 'Landscape',
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  # region : affecter une demande à un/des gestionnaire allocataire

  def affecter_allocataire
    # affecter une demande à un gestionnaire allocataire
    if @demande_liquidation.update(liquidation_retraite_france_affecter_allocataire_params.merge(affectation_allocataire_date: DateTime.now))
      redirect_to admin_liquidation_retraite_frances_path, notice: 'Demande réaffectée.'
    end
  end

  def affecter_allocataire_all
    if params['gestionnaires_ids'].nil?
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :en_attente
    else
      demande_liquidations = LiquidationRetraiteFrance.en_attente_allocation
      gestionnaires_id = params['gestionnaires_ids'].split(',')
      unless gestionnaires_id.nil? && !demande_liquidations.empty?
        demande_liquidations.each do |demande_liquidation|
          gestionnaires_id = params['gestionnaires_ids'].split(',')
          gestionnaires_id.delete(demande_liquidation.ajoute_par.id)
          demande_liquidation.affectation_allocataire = (gestionnaires_id - [demande_liquidation.ajoute_par_id]).sample
          demande_liquidation.affectation_allocataire_date = DateTime.now
          # demande_liquidation.etat = :traitement_en_cours
          demande_liquidation.save
        end
      end
      redirect_to admin_liquidation_retraite_frances_path, notice: 'Affectation effectuée avec succés'
    end
  end

  # endregion

  # region : affecter une demande à un/des gestionnaire salarie
  def affecter_salarie
    # affecter une demande à un gestionnaire allocataire
    @demande_liquidation.update(liquidation_retraite_france_affecter_salarie_params.merge(affectation_salarie_date: DateTime.now))
    redirect_to admin_liquidation_retraite_frances_path, notice: 'Demande Affectée.'
  end

  def update_fullname
    demande = LiquidationRetraiteFrance.find(@demande_liquidation.id)
    @demande_liquidation.update(update_full_name_params.merge(update_fullname_date: DateTime.now, update_fullname_par: current_user, update_fullname_commentaire: "#{demande.prenom} #{demande.nom}"))
    redirect_to admin_liquidation_retraite_frances_path, notice: 'Nom et Prénom modifiés.'
  end

  def affecter_salarie_all
    if params['gestionnaires_ids'].nil?
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :en_attente
    else
      demande_liquidations = LiquidationRetraiteFrance.en_attente_cotisation
      gestionnaires_id = params['gestionnaires_ids'].split(',')

      unless gestionnaires_id.nil?
        demande_liquidations.each do |demande_liquidation|
          gestionnaires_id = params['gestionnaires_ids'].split(',')
          gestionnaires_id.delete(demande_liquidation.ajoute_par.id)
          demande_liquidation.affectation_salarie = (gestionnaires_id - [demande_liquidation.ajoute_par_id]).sample
          demande_liquidation.affectation_salarie_date = DateTime.now
          demande_liquidation.carriere_valide = true
          demande_liquidation.save
        end
      end
      redirect_to admin_liquidation_retraite_frances_path, notice: 'Affectation effectuée avec succés'
    end
  end

  # endregion

  # region : valider toutes les infos de la demande
  def valider_etat_civil_demandeur
    @demande_liquidation.etat_civil_demandeur_valide!
    redirect_to [:admin, @demande_liquidation]
  end

  def valider_ligne_carriere_ext
    carriere = CarrieresExterieure.find(params[:carrieres_exterieure_id])
    carriere.valide!
    redirect_to [:admin, @cfs_reversion_veuve], notice: 'ligne de carriere exterieure validée avec succés'
  end

  def valider_epouses
    @demande_liquidation.epouses_valide!
    redirect_to [:admin, @demande_liquidation]
  end

  def valider_enfants
    @demande_liquidation.enfants_valide!
    redirect_to [:admin, @demande_liquidation]
  end

  def valider_carriere
    if @demande_liquidation.instruit?
      # @demande_liquidation.carriere_valide!
      @demande_liquidation.est_carriere_soumis!
      @demande_liquidation.soumission_carriere_par = current_user
      @demande_liquidation.date_soumission_carriere = DateTime.now
      @demande_liquidation.motif = nil
      @demande_liquidation.save
      flash[:notice] = 'Carrière soumis pour validation'
      redirect_to [:admin, @demande_liquidation]
    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def valider_documents
    unless @demande_liquidation.documents_valide!
      flash[:error] = 'Veuillez déposer tous les documents requis avant la validation'
    end
    redirect_to [:admin, @demande_liquidation]
  end

  def valider_assur_residence_valid
    @demande_liquidation.assur_residence_valide!
    redirect_to [:admin, @demande_liquidation]
  end

  def valider_assur_second_pays_valid
    @demande_liquidation.assur_second_pays_valide!
    redirect_to [:admin, @demande_liquidation]
  end

  def valider_ressources_conjoint_valid
    @demande_liquidation.ressources_conjoint_valide!
    redirect_to [:admin, @demande_liquidation]
  end

  def valider_activite_prof_valid
    if @demande_liquidation.instruit?
      @demande_liquidation.activite_prof_valide!
      if @demande_liquidation.est_carriere_soumis!
        redirect_to [:admin, @demande_liquidation], notice: 'Validation carrières en France avec succés!'
      else
        redirect_to [:admin, @demande_liquidation]
      end
    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  # endregion

  # region : valider carriere
  def valider_all_carrieres
    if @demande_liquidation.instruit?
      carrieres_prestation = @demande_liquidation.carrieres_prestation
      carrieres_prestation&.each do |carriere|
        carriere.valide! if carriere.en_attente?
      end
      @demande_liquidation.touch
      redirect_to [:admin, @demande_liquidation], notice: 'Tous les points carrières validés avec succés!'
    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def valider_ligne_carriere
    carriere_prestation = Carriere.find(params[:carriere_id])
    carriere_prestation.valide!
    @demande_liquidation.touch
    redirect_to [:admin, @demande_liquidation]
  end

  # endregion

  # region : Workflow Validation DOSSIER LIQUIDATION

  def soumettre
    if @demande_liquidation.creation?
      @demande_liquidation.date_soumission = DateTime.now
      @demande_liquidation.traite_par = current_user
      @demande_liquidation.traite_le = DateTime.now
      @demande_liquidation.motif = nil
      @demande_liquidation.est_soumis!
      @demande_liquidation.save
      redirect_to [:admin, @demande_liquidation], notice: 'La demande de liquidation est soumise'
    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def instruire
    if @demande_liquidation.soumis?
      @demande_liquidation.traite_par = current_user
      @demande_liquidation.instruit_par = current_user
      @demande_liquidation.instruit_le = DateTime.now
      @demande_liquidation.motif = nil
      @demande_liquidation.est_instruit!
      @demande_liquidation.save
      redirect_to [:admin, @demande_liquidation], notice: 'Demande Instruit'
    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def carriere_valide
    @demande_liquidation.soumission_carriere_par = current_user
    @demande_liquidation.traite_par = current_user
    @demande_liquidation.date_soumission_carriere = DateTime.now
    @demande_liquidation.motif = nil
    @demande_liquidation.carriere_valide!
    @demande_liquidation.save
    flash[:notice] = 'Carrière soumis pour validation'
    redirect_to [:admin, @demande_liquidation]
  end

  def cotisation_valide
    if @demande_liquidation.cotisation_valide?
      redirect_to [:admin, @demande_liquidation]
    else
      @demande_liquidation.validation_carriere_par = current_user
      @demande_liquidation.traite_par = current_user
      @demande_liquidation.date_validation_carriere = DateTime.now
      @demande_liquidation.motif = nil
      @demande_liquidation.est_carriere_valide!
      @demande_liquidation.save
      redirect_to [:admin, @demande_liquidation], notice: 'Carrière validée avec succés'

    end
  end

  def valider_recapitulatif
    if @demande_liquidation.cotisation_valide?
      @demande_liquidation.soumission_validation_par = current_user
      @demande_liquidation.traite_par = current_user
      @demande_liquidation.date_soumission_validation = DateTime.now
      @demande_liquidation.motif = nil
      @demande_liquidation.est_recap_soumis!
      @demande_liquidation.save
      redirect_to [:admin, @demande_liquidation], notice: 'Recap soumis pour validation'
    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def recap_valide
    if @demande_liquidation.cotisation_valide?
      redirect_to [:admin, @demande_liquidation]
    else
      @demande_liquidation.validation_liquidation_par = current_user
      @demande_liquidation.traite_par = current_user
      @demande_liquidation.date_validation_liquidation = DateTime.now
      @demande_liquidation.motif = nil
      @demande_liquidation.est_recap_valide!
      @demande_liquidation.save
      redirect_to [:admin, @demande_liquidation], notice: 'Recap soumis pour validation'
    end
  end

  def liquidation_valide
    if @demande_liquidation.recap_soumis?
      @demande_liquidation.validation_liquidation_par = current_user
      @demande_liquidation.traite_par = current_user
      @demande_liquidation.date_validation_liquidation = DateTime.now
      @demande_liquidation.motif = nil
      @demande_liquidation.est_recap_valide!
      @demande_liquidation.save
      redirect_to [:admin, @demande_liquidation], notice: 'Recap validée avec succés'
    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def dossier_valide
    if @demande_liquidation.liquidation_valide?
      @demande_liquidation.traite_par = current_user
      if @demande_liquidation.est_dossier_valide!
        @demande_liquidation.valider_par = current_user
        @demande_liquidation.valider_le = DateTime.now
        @demande_liquidation.traite_le = DateTime.now
        @demande_liquidation.save
        flash[:notice] = 'Dossier validé avec succés'
      elsif @demande_liquidation.halted?
        flash[:error] = @demande_liquidation.halted_because
      else
        flash[:error] = 'Une erreur est survenue lors de la validation du dossier'
      end
    end
    redirect_to [:admin, @demande_liquidation]
  end

  def dossier_rejet
    if @demande_liquidation.liquidation_valide?
      @demande_liquidation.traite_le = DateTime.now
      @demande_liquidation.traite_par = current_user
      @demande_liquidation.motif = nil
      @demande_liquidation.est_dossier_rejete!
      @demande_liquidation.save
      redirect_to [:admin, @demande_liquidation], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @demande_liquidation]
    end
  end

  # endregion

  def ajouter_carriere
    @carriere = Carriere.new(carriere_params)
    puts "======> #{@carriere.raison_sociale}"
    # Ajouter validation Raison sociale doit pas être vide
    @carriere.numero_affiliation = @demande_liquidation.numero_affiliation
    @carriere.etat = :en_attente
    @carriere.salaire = @carriere.salaire1 + @carriere.salaire2

    if @carriere.save
      redirect_to [:admin, @demande_liquidation], notice: 'Carriere ajoutée.'
    else
      redirect_to [:admin, @demande_liquidation], notice: 'Erreur sur la création.'
    end
  end

  def lettre_notification
    tableau_rappel

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "lettre notification n°. #{@demande_liquidation.id}",
               page_size: 'A4',
               template: 'admin/liquidation_retraite_frances/lettre_notification.html.erb',
               layout: 'pdf.html',
               orientation: 'Landscape',
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def activer_dossier_incomplet
    if @demande_liquidation.update(liquidation_retraite_france_dossier_incomplet)
      redirect_to [:admin, @demande_liquidation], notice: 'Modification effectuée avec succés.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      redirect_to [:admin, @demande_liquidation]
    end
  end

  private

  def tableau_rappel
    if @demande_liquidation.current_state > :carriere_soumis
      d_jouissance = @demande_liquidation.calcul_date_jouissance
      montant_d_jouissance = @demande_liquidation.calcul_allocation(d_jouissance) + @demande_liquidation.calcul_subvention(d_jouissance)
      nombre_mois = (@demande_liquidation.date_validation.year * 12 + @demande_liquidation.date_validation.month) - (d_jouissance.year * 12 + d_jouissance.month)

      nombre_jours = (d_jouissance.end_of_month.day - d_jouissance.day).to_i

      @tableau_rappel = []

      @montant_first_month = (([nombre_jours, 30].min * montant_d_jouissance) / 30).ceil

      @montant_total_rappel = @montant_first_month

      @date_prochain_rappel = d_jouissance + 1.month

      @tableau_rappel << "#{d_jouissance.strftime('%d/%m/%Y')} - #{d_jouissance.end_of_month.strftime('%d/%m/%Y')} | #{format_cfa @montant_first_month}"

      (1..nombre_mois + 1).each do
        montant = @demande_liquidation.calcul_allocation(@date_prochain_rappel) + @demande_liquidation.calcul_subvention(@date_prochain_rappel)
        @tableau_rappel << "#{@date_prochain_rappel.beginning_of_month.strftime('%d/%m/%Y')} - #{@date_prochain_rappel.end_of_month.strftime('%d/%m/%Y')}  | #{format_cfa montant}"
        @montant_total_rappel += montant
        @date_prochain_rappel += 1.month
      end
    end
  end

  def can_soumettre_operation
    unless current_user.can_allocataire? && (current_user.admin_agence == @demande_liquidation.ajoute_par.admin_agence)
      flash[:error] = "Vous ne pouvez pas valider ce dossier de prestation. Vous n'est pas abilité."
      redirect_to admin_liquidation_retraite_frances_path
    end
  end

  def set_demande_liquidation
    @demande_liquidation = LiquidationRetraiteFrance.visible_for_admins.find(params[:id] || params[:liquidation_retraite_france_id])
  rescue ActiveRecord::RecordNotFound => e
    @demande_liquidation = current_user.liquidation_retraite_france_creees.find(params[:id] || params[:liquidation_retraite_france_id])
  end

  def demande_liquidation_params
    params.require(:liquidation_retraite_france).permit(:numero_affiliation, :type_retraite, :prenom, :nom,
                                                        :date_naissance, :lieu_naissance,
                                                        :adresse_reception_allocation, :adresse_domicile, :email,
                                                        :mode_paiement,
                                                        :compte_bancaire_cle_rib, :compte_bancaire_numero_compte, :etat,
                                                        :date_cessation_activite, :telephone, :admin_banque_agence_id,
                                                        :zone, :admin_region_id, :sexe, :admin_agence_id, :adresse_paiement,
                                                        :not_completed, :motif_not_completed, :nom_jeune_fille,
                                                        :adresse_residence, :numero_securite_sociale, :prenom_pere, :prenom_mere, :nom_pere, :nom_mere, :nationalite_id, :num_immatric_ipres,
                                                        :num_immatric_cfs, :situation_familiale, :date_mariage, :date_situation_fam, :date_ouverture, :nature, :inapte,
                                                        :date_depart_inapt, :date_decision_inapt, :titulaire_pens_invalidite, :titre_reg_gl, :titre_reg_agric, :titre_reg_minier,
                                                        :titre_reg_special, :institution_reg_spec, :num_pension_inapt, :date_cess_act_sn, :total_an_carriere_sn, :date_cess_act_fr,
                                                        :total_an_carriere_fr, :sens_convention, :decide_points, :decide_montant_annuel, :decide_date,
                                                        :user_id, :type_piece, :motif_rejet, :numero_piece, :precision_carriere,
                                                        :adresse_postale, :admin_banque_agence_id, :admin_agence_id,
                                                        :admin_region_id, :agence_creation_id, :numero_dossier, :carriere_conjoint, :salaire_trimestre_conjoint,
                                                        :salaire_annuel_conjoint, :date_cess_act_conjoint, :avantage_viellesse_conjoint, :nature_avantage_conjoint,
                                                        :nom_instit_deb_conjoint, :adresse_instit_deb_conjoint, :numero_pension_conjoint,
                                                        :montant_pension_conjoint, :autres_revenus_conjoint, :biens_perso_conjoint, :biens_donation_conjoint,
                                                        documents_deposes: [],)
  end

  def liquidation_retraite_france_rejet_params
    params.require(:liquidation_retraite_france).permit(:motif)
  end

  def rejet_ligne_carriere_params
    params.require(:carriere).permit(:motif_rejet)
  end

  def commentaire_soumission_params
    params.require(:liquidation_retraite_france).permit(:commentaire_soumission)
  end

  def commentaire_instruction_params
    params.require(:liquidation_retraite_france).permit(:commentaire_instruction)
  end

  def commentaire_carriere_params
    params.require(:liquidation_retraite_france).permit(:commentaire_carriere)
  end

  def commentaire_validation_carriere_params
    params.require(:liquidation_retraite_france).permit(:commentaire_validation_carriere)
  end

  def commentaire_tableau_params
    params.require(:liquidation_retraite_france).permit(:commentaire_tableau)
  end

  def commentaire_validation_tableau_params
    params.require(:liquidation_retraite_france).permit(:commentaire_validation_tableau)
  end

  def commentaire_validation_params
    params.require(:liquidation_retraite_france).permit(:commentaire_validation)
  end

  def liquidation_retraite_france_affecter_allocataire_params
    params.require(:liquidation_retraite_france).permit(:affectation_allocataire, :commentaire_affectation_allocataire, :ajoute_par_id)
  end

  def liquidation_retraite_france_affecter_salarie_params
    params.require(:liquidation_retraite_france).permit(:affectation_salarie, :commentaire_affectation_salaire)
  end

  def update_full_name_params
    params.require(:liquidation_retraite_france).permit(:nom, :prenom)
  end

  def document_demande_liquidation_params
    params.require(:document_liquidation_retraite_france).permit(:type_document, :document, :commentaire)
  end

  def carriere_params
    params.require(:carriere).permit(:date_entree, :date_sortie, :type_regime_id, :salaire, :ref_employeur, :exercice, :points, :salaire1, :salaire2, :raison_sociale, :motif)
  end

  def revenu_conjoint_params
    params.require(:revenu_conjoint).permit(:liquidation_retraite_france_id, :nature, :montant_trimestriel, :montant_annuel)
  end

  def bien_pers_conjoint_params
    params.require(:bien_pers_conjoint).permit(:liquidation_retraite_france_id, :description, :valeur_actuelle, :situation_departement, :lieu_imposition, :revenu_cadastral)
  end

  def donation_conjoint_params
    params.require(:donation_conjoint).permit(:liquidation_retraite_france_id, :description, :valeur_actuelle, :situation_departement, :nom_beneficiaire, :adresse_beneficiaire, :quantite, :date_donation)
  end

  def cfs_conjoint_params
    params.require(:cfs_conjoint).permit(:liquidation_retraite_france_id, :prenom, :nom, :date_naissance, :lieu_naissance,
                                         :nationalite_id, :prenom_mere, :nom_mere, :prenom_pere, :nom_pere, :numero_securite_sociale,
                                         :date_mariage, :situation, :date_deces, :etat, :ajoute_par_id,
                                         :user_id, :date_etablissement_mariage, :date_jugement_suppletif, :nin, :code_etat_civil,
                                         :extrait_naissance, :certificat_mariage, :certificat_deces, :certificat_divorce, :numero_affiliation, :est_enceinte, :numero_registre,
                                         :est_salarie, :numero_salarie, :type_piece, :numero_piece, :piece_identite, :sex,
                                         :date_delivrance_piece, :date_expiration_piece, :matric_conjoint, :nin_generer,
                                         :prenom_salarie, :nom_salarie, :regime_matrimoniale, :etat_conjoint, :etat_civil, :date_delivrance_piece_salarie,
                                         :rang_conjoint, :date_naissance_salarie, :date_divorce, :date_deces, :date_transcription, :nombre_femmes, :numero_jugement_mariage, :numero_trouve)
  end

  def cfs_enfant_params
    params.require(:cfs_enfant).permit(:liquidation_retraite_france_id, :prenom, :nom, :date_naissance, :lieu_naissance,
                                       :filiation, :situation, :date_deces, :etat, :ajoute_par_id)
  end

  def periode_assurance_params
    params.require(:periode_assurance).permit(:liquidation_retraite_france_id, :date_debut, :date_fin, :trimestre_assurance, :trimestre_equivalente, :type_periode)
  end

  def cfs_correspondance_params
    params.require(:cfs_correspondance).permit(:liquidation_retraite_france_id, :type_lettre, :provenance, :numero_correspondance,
                                               :numero_dossier, :numero_reference, :objet, :titre_destinataire, :lettre,
                                               :destinataire, :adresse_destinataire, :expediteur, :date, :corps, :titre_demandeur,
                                               :piece_jointe, :nature_piece_jointe, :etat, :ajoute_par_id)
  end

  def carrieres_prest_exterieure_params
    params.require(:carrieres_exterieure).permit(:liquidation_retraite_france_id, :date_debut, :date_fin, :salaire, :employeur_exterieur_id, :type_regime_id, :salaire, :ref_employeur, :exercice, :points, :salaire1, :salaire2)
  end

  def employeur_ext_params
    params.require(:employeur_exterieur).permit(:prenom_employeur, :nom_employeur, :email, :adresse, :raison_sociale, :telephone)
  end

  def peut_etre_edite!
    unless @demande_liquidation.creation?
      flash[:error] = 'Vous ne pouvez pas éditer une demande déjà soumise'
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def can_add!
    unless current_user.can_add_liquidation_retraite_france?
      flash[:error] = "Vous ne pouvez pas ajouter une nouvelle demande de liquidation retraite. Il y'a déjà une ou des demandes en cours"
      redirect_to admin_liquidation_retraite_frances_path
    end
  end

  def rejet(demande)
    return :creation if demande.soumis?
    return :soumis if demande.instruit?
    return :instruit if demande.carriere_valide?
    return :carriere_valide if demande.cotisation_valide?
    return :cotisation_valide if demande.recap_valide?
    return :recap_valide if demande.liquidation_valide?
    return :liquidation_valide if demande.dossier_valide?
  end

  def can_create?
    unless current_user.gestionnaire_compte_allocataire?
      flash[:error] = 'Seul les gestionnaires de compte allocataire peuvent accéder à cette ressource'
      redirect_back(fallback_location: root_path)
    end
  end

  def liquidation_retraite_france_dossier_incomplet
    params.require(:liquidation_retraite_france).permit(:not_completed, :motif_not_completed)
  end
end
