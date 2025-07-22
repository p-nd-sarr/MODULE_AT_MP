# frozen_string_literal: true

class Admin::LiquidationRetraitesController < Admin::ApplicationController
  before_action :set_demande_liquidation, except: %i[index new create en_attente ajoutee carriere_en_attente recap_en_attente affecter_allocataire_all affecter_salarie_all destroy_document validation_en_attente dossiers_retournes demandes_affectees dossiers_incomplets]
  before_action :can_create?, only: %i[new create]

  def index
    @q = LiquidationRetraite.visible_for_admins.ransack(params[:q])
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
        @demande_liquidations_export = LiquidationRetraite.LiquidationRetraite.where(admin_agence_id: current_user.admin_agence.id).where(workflow_state: :soumis)
        @q = @demande_liquidations_export.ransack(params[:q])
        @demande_liquidations = @q.result
        @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

      else
        @demande_liquidations_export = LiquidationRetraite.where(workflow_state: :soumis)
        @q = @demande_liquidations_export.ransack(params[:q])
        @demande_liquidations = @q.result
        @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

      end
    elsif current_user.chef_section_liquidation?
      @demande_liquidations_export = LiquidationRetraite.en_attente_allocation
      @q = @demande_liquidations_export.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    elsif current_user.gestionnaire_compte_allocataire?
      @demande_liquidations_export = LiquidationRetraite.where(affectation_allocataire: current_user.id).can_affecte
      @q = @demande_liquidations_export.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    elsif current_user.gestionnaire_compte_salarie?
      @demande_liquidations_export = LiquidationRetraite.where(affectation_salarie: current_user.id).non_retourner.where(workflow_state: %i[instruit cotisation_valide])
      @q = @demande_liquidations_export.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    elsif current_user.chef_service_allocation?
      @demande_liquidations_export = LiquidationRetraite.en_attente_allocation
      @q = LiquidationRetraite.en_attente_allocation.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    elsif current_user.chef_service_cotisation?
      @demande_liquidations_export = LiquidationRetraite.en_attente_cotisation
      @q = LiquidationRetraite.en_attente_cotisation.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    elsif current_user.chef_agence?
      @demande_liquidations_export = LiquidationRetraite.with_soumis_state.where(agence_creation: current_user.admin_agence)
      @q = @demande_liquidations_export.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    else
      @demande_liquidations_export = LiquidationRetraite.with_soumis_state
      @q = @demande_liquidations_export.ransack(params[:q])
      @demande_liquidations = @q.result
      @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    end

    @demande_liquidations_en_attente = @demande_liquidations.en_attente.page(params[:page]).per(100)
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires allocataires
    @gestionnaires_salaries = User.gestionnaire_compte_salarie # avoir la liste des gestionnaires salaries
  end

  def validation_en_attente
    @demande_liquidations = LiquidationRetraite.with_liquidation_valide_state.includes(:agence_creation).page(params[:page]).per(100)
  end

  def carriere_en_attente
    @demande_liquidations = LiquidationRetraite.with_carriere_soumis_state.includes(:agence_creation).page(params[:page]).per(100)
  end

  def demandes_affectees
    @q = LiquidationRetraite.demandes_affectees.ransack(params[:q])
    @demande_liquidations = @q.result.includes(:agence_creation)
    @demande_liquidations = @demande_liquidations.page(params[:page]).per(100)

    @demande_liquidations_export = LiquidationRetraite.demandes_affectees
  end

  def recap_en_attente
    @demande_liquidations = LiquidationRetraite.with_recap_soumis_state.includes(:agence_creation).page(params[:page]).per(100)
  end

  def en_attente_validation
    @demande_liquidations = LiquidationRetraite.with_recap_soumis_state.includes(:agence_creation).page(params[:page]).per(100)
  end

  def ajoutee
    @demande_liquidations = current_user.liquidation_retraite_creees.includes(:agence_creation).page(params[:page]).per(100)
  end

  def dossiers_retournes
    if current_user.gestionnaire_compte_allocataire?
      @demande_liquidations = current_user.liquidation_retraite_creees.dossiers_retournes.page(params[:page]).per(100)
    elsif current_user.gestionnaire_compte_salarie?
      @demande_liquidations = LiquidationRetraite.mes_affectations_salarie(current_user.id).where(workflow_state: :instruit).dossiers_retournes.page(params[:page]).per(100)
    elsif current_user.chef_section_instruction?
      @demande_liquidations = LiquidationRetraite.where(workflow_state: :soumis).dossiers_retournes.page(params[:page]).per(100)
    else
      @demande_liquidations = LiquidationRetraite.dossiers_retournes.page(params[:page]).per(100)
    end
  end

  def dossiers_incomplets
    @demande_liquidations = LiquidationRetraite.dossiers_incomplets.page(params[:page]).per(100)
  end

  def show
    @document_demande_liquidation = DocumentLiquidationRetraite.new
    @gestionnaires = User.gestionnaire_compte_allocataire.where.not(id: @demande_liquidation.ajoute_par.id) # avoir la liste des gestionnaires
    @gestionnaires_salaries = User.gestionnaire_compte_salarie.where.not(id: @demande_liquidation.ajoute_par.id) # avoir la liste des gestionnaires

    @carriere = Carriere.new

    # tableau_rappel
  end

  def rejeter_create
    if @demande_liquidation.update(liquidation_retraite_rejet_params.merge(etat: :rejete,
                                                                           traite_par: current_user,
                                                                           traite_le: DateTime.now))
      redirect_to admin_liquidation_retraites_path, notice: 'Deamande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def new
    @demande_liquidation = LiquidationRetraite.new(numero_affiliation: params[:numero_affiliation])
  end

  def edit; end

  def create
    @demande_liquidation = LiquidationRetraite.new(demande_liquidation_params)

    @allocataire = Allocataire.find_by(numero_allocataire: @demande_liquidation.numero_affiliation)
    if @allocataire.nil?
      @demande_liquidation.ajoute_par = current_user
      @demande_liquidation.traite_par = current_user
      @demande_liquidation.documents_deposes_obligatoires = params[:documents_deposes_obligatoires]
      @demande_liquidation.documents_deposes_facultatifs = params[:documents_deposes_facultatifs]
      participant = Psrm::Participant.find_by(matric: @demande_liquidation.numero_affiliation)
      @demande_liquidation.nom = participant.try(:nom)
      @demande_liquidation.prenom = participant.try(:prenom)
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
    redirect_to admin_liquidation_retraites_path, notice: 'La demande de liquidation est supprimée.'
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
    if liquidation_retraite_rejet_params[:motif].nil?
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
      if @demande_liquidation.update(liquidation_retraite_rejet_params.merge(traite_par: current_user,
                                                                             traite_le: DateTime.now))
        redirect_to admin_liquidation_retraites_path, notice: 'Deamande traitée.'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        render :rejeter
      end
    end
  end

  def rejeter_process
    if @demande_liquidation.update(liquidation_retraite_rejet_params.merge(etat: :rejete,
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
    @document_demande_liquidation.liquidation_retraite = @demande_liquidation

    if @document_demande_liquidation.save
      @demande_liquidation.documents_valide!(false)
      redirect_to [:admin, @demande_liquidation], notice: 'Le document est ajouté.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document."
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def destroy_document
    @demande_liquidation = LiquidationRetraite.find(params[:liquidation_retraite_id])
    @document_demande_liquidation = DocumentLiquidationRetraite.find(params[:document_liquidation_retraites_id])
    @document_demande_liquidation.destroy
    redirect_to [:admin, @demande_liquidation], notice: 'Le document a été supprimé avec succès'
  end

  def show_facture
    @demande_liquidation = LiquidationRetraite.find(params[:id] || params[:liquidation_retraite_id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Récépissé demande de liquidation No. #{@demande_liquidation.id}",
               page_size: 'A4',
               template: 'admin/liquidation_retraites/show_facture.html.erb',
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
    if @demande_liquidation.update(liquidation_retraite_affecter_allocataire_params.merge(affectation_allocataire_date: DateTime.now))
      redirect_to admin_liquidation_retraites_path, notice: 'Demande réaffectée.'
    end
  end

  def affecter_allocataire_all
    if params['gestionnaires_ids'].nil?
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :en_attente
    else
      demande_liquidations = LiquidationRetraite.en_attente_allocation
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
      redirect_to admin_liquidation_retraites_path, notice: 'Affectation effectuée avec succés'
    end
  end

  # endregion

  # region : affecter une demande à un/des gestionnaire salarie
  def affecter_salarie
    # affecter une demande à un gestionnaire allocataire
    @demande_liquidation.update(liquidation_retraite_affecter_salarie_params.merge(affectation_salarie_date: DateTime.now))
    redirect_to admin_liquidation_retraites_path, notice: 'Demande Affectée.'
  end

  def update_fullname
    demande = LiquidationRetraite.find(@demande_liquidation.id)
    @demande_liquidation.update(update_full_name_params.merge(update_fullname_date: DateTime.now, update_fullname_par: current_user, update_fullname_commentaire: "#{demande.prenom} #{demande.nom}"))
    redirect_to admin_liquidation_retraites_path, notice: 'Nom et Prénom modifiés.'
  end

  def affecter_salarie_all
    if params['gestionnaires_ids'].nil?
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :en_attente
    else
      demande_liquidations = LiquidationRetraite.en_attente_cotisation
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
      redirect_to admin_liquidation_retraites_path, notice: 'Affectation effectuée avec succés'
    end
  end

  # endregion

  # region : valider toutes les infos de la demande
  def valider_etat_civil_demandeur
    @demande_liquidation.etat_civil_demandeur_valide!
    redirect_to [:admin, @demande_liquidation]
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
               template: 'admin/liquidation_retraites/lettre_notification.html.erb',
               layout: 'pdf.html',
               orientation: 'Landscape',
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def activer_dossier_incomplet
    if @demande_liquidation.update(liquidation_retraite_dossier_incomplet)
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
      redirect_to admin_liquidation_retraites_path
    end
  end

  def set_demande_liquidation
    @demande_liquidation = LiquidationRetraite.visible_for_admins.find(params[:id] || params[:liquidation_retraite_id])
  rescue ActiveRecord::RecordNotFound => e
    @demande_liquidation = current_user.liquidation_retraite_creees.find(params[:id] || params[:liquidation_retraite_id])
  end

  def demande_liquidation_params
    params.require(:liquidation_retraite).permit(:numero_affiliation, :type_retraite, :prenom, :nom,
                                                 :date_naissance, :lieu_naissance,
                                                 :adresse_reception_allocation, :adresse_domicile, :email,
                                                 :mode_paiement,
                                                 :compte_bancaire_cle_rib, :compte_bancaire_numero_compte, :etat,
                                                 :date_cessation_activite, :telephone, :admin_banque_agence_id,
                                                 :zone, :admin_region_id, :sexe, :admin_agence_id, :adresse_paiement,
                                                 :not_completed, :motif_not_completed, :cip_id, documents_deposes: [])
  end

  def liquidation_retraite_rejet_params
    params.require(:liquidation_retraite).permit(:motif)
  end

  def rejet_ligne_carriere_params
    params.require(:carriere).permit(:motif_rejet)
  end

  def commentaire_soumission_params
    params.require(:liquidation_retraite).permit(:commentaire_soumission)
  end

  def commentaire_instruction_params
    params.require(:liquidation_retraite).permit(:commentaire_instruction)
  end

  def commentaire_carriere_params
    params.require(:liquidation_retraite).permit(:commentaire_carriere)
  end

  def commentaire_validation_carriere_params
    params.require(:liquidation_retraite).permit(:commentaire_validation_carriere)
  end

  def commentaire_tableau_params
    params.require(:liquidation_retraite).permit(:commentaire_tableau)
  end

  def commentaire_validation_tableau_params
    params.require(:liquidation_retraite).permit(:commentaire_validation_tableau)
  end

  def commentaire_validation_params
    params.require(:liquidation_retraite).permit(:commentaire_validation)
  end

  def liquidation_retraite_affecter_allocataire_params
    params.require(:liquidation_retraite).permit(:affectation_allocataire, :commentaire_affectation_allocataire, :ajoute_par_id)
  end

  def liquidation_retraite_affecter_salarie_params
    params.require(:liquidation_retraite).permit(:affectation_salarie, :commentaire_affectation_salaire)
  end

  def update_full_name_params
    params.require(:liquidation_retraite).permit(:nom, :prenom)
  end

  def document_demande_liquidation_params
    params.require(:document_liquidation_retraite).permit(:type_document, :document, :commentaire)
  end

  def carriere_params
    params.require(:carriere).permit(:date_entree, :date_sortie, :type_regime_id, :salaire, :ref_employeur, :exercice, :points, :salaire1, :salaire2, :raison_sociale, :motif)
  end

  def peut_etre_edite!
    unless @demande_liquidation.creation?
      flash[:error] = 'Vous ne pouvez pas éditer une demande déjà soumise'
      redirect_to [:admin, @demande_liquidation]
    end
  end

  def can_add!
    unless current_user.can_add_liquidation_retraite?
      flash[:error] = "Vous ne pouvez pas ajouter une nouvelle demande de liquidation retraite. Il y'a déjà une ou des demandes en cours"
      redirect_to admin_liquidation_retraites_path
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

  def liquidation_retraite_dossier_incomplet
    params.require(:liquidation_retraite).permit(:not_completed, :motif_not_completed)
  end
end
