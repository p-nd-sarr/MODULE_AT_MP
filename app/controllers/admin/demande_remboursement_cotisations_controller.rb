class Admin::DemandeRemboursementCotisationsController < ApplicationController
  before_action :set_demande_remboursement_cotisation, except: [:index, :new, :create, :en_attente_instruction, :en_attente_affectation_salarie, :ajoutee, :en_attente_validation_salaire, :en_attente_validation_carriere, :en_attente_validation_allocataire, :recap_en_attente, :en_attente_affectation_allocataire, :en_attente_validation_recap, :destroy_document, :en_attente_validation_instruction, :en_attente_regularisation_remboursement, :bordereau_remboursement, :en_attente_validation, :en_attente_validation_inspection]

  # GET /demande_remboursement_cotisations
  # GET /demande_remboursement_cotisations.json
  def index
    @q = DemandeRemboursementCotisation.visible_for_admins.ransack(params[:q])
    @demande_remboursements = @q.result.order('created_at DESC').page(params[:page]).per(50)
  end

  def en_attente
    if current_user.chef_section_instruction?
      @demande_remboursements = DemandeRemboursementCotisation.where(workflow_state: :soumis).page(params[:page]).per(100)
    elsif current_user.chef_section_liquidation?
      @demande_remboursements = DemandeRemboursementCotisation.en_attente_allocation.page(params[:page]).per(100)
    elsif current_user.gestionnaire_compte_allocataire?
      @demande_remboursements = DemandeRemboursementCotisation.where(affectation_allocataire: current_user.id).can_affecte.page(params[:page]).per(100)
    elsif current_user.gestionnaire_compte_salarie?
      @demande_remboursements = DemandeRemboursementCotisation.where(affectation_salarie: current_user.id).can_affecte.page(params[:page]).per(100)
    elsif current_user.chef_service_allocation?
      @demande_remboursements = DemandeRemboursementCotisation.en_attente_allocation.page(params[:page]).per(100)
    elsif current_user.chef_service_allocation?
      @demande_remboursements = DemandeRemboursementCotisation.en_attente_allocation.page(params[:page]).per(100)
    elsif current_user.chef_service_cotisation?
      @demande_remboursements = DemandeRemboursementCotisation.en_attente_cotisation.page(params[:page]).per(100)
    elsif current_user.directeur_prestation?
      @demande_remboursements = DemandeRemboursementCotisation.where(workflow_state: :dossier_valide).page(params[:page]).per(100)
    elsif current_user.inspection?
      @demande_remboursements = DemandeRemboursementCotisation.where(workflow_state: :remboursement_regularise).page(params[:page]).per(100)
    else
      @demande_remboursements = DemandeRemboursementCotisation.with_soumis_state.page(params[:page]).per(100)
    end

    @demande_liquidations_en_attente = @demande_remboursements.en_attente.page(params[:page]).per(100)
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires allocataires
    @gestionnaires_salaries = User.gestionnaire_compte_salarie # avoir la liste des gestionnaires salaries
  end

  def en_attente_instruction
    @demande_remboursements = DemandeRemboursementCotisation.en_attente_instruction.page(params[:page]).per(100)
  end

  def en_attente_affectation_salarie
    @demande_remboursements = DemandeRemboursementCotisation.en_attente_salaire.page(params[:page]).per(100)
  end

  def en_attente_validation_salaire
    @demande_remboursements = DemandeRemboursementCotisation.where(affectation_salarie: current_user.id).can_affecte.page(params[:page]).per(100)
  end

  def en_attente_validation_carriere
    @demande_remboursements = DemandeRemboursementCotisation.with_carriere_soumis_state.page(params[:page]).per(100)
  end

  def en_attente_affectation_allocataire
    @demande_remboursements = DemandeRemboursementCotisation.en_attente_allocation.page(params[:page]).per(100)
  end

  def en_attente_validation_allocataire
    @demande_remboursements = DemandeRemboursementCotisation.where(affectation_allocataire: current_user.id).can_affecte.page(params[:page]).per(100)
  end

  def en_attente_validation_recap
    @demande_remboursements = DemandeRemboursementCotisation.with_recap_soumis_state.page(params[:page]).per(100)
  end

  def en_attente_validation
    @demande_remboursements = DemandeRemboursementCotisation.with_liquidation_valide_state.page(params[:page]).per(100)
  end

  def en_attente_regularisation_remboursement
    @demande_remboursements = DemandeRemboursementCotisation.with_dossier_valide_state.page(params[:page]).per(100)
  end

  def en_attente_validation_inspection
    @demande_remboursements = DemandeRemboursementCotisation.with_remboursement_regularise_state.page(params[:page]).per(100)
  end

  # GET /demande_remboursement_cotisations/1
  # GET /demande_remboursement_cotisations/1.json
  def show
    @gestionnaires = User.gestionnaire_compte_allocataire.where.not(id: @demande_remboursement_cotisation.ajoute_par.id) # avoir la liste des gestionnaires
    @gestionnaires_salaries = User.gestionnaire_compte_salarie # avoir la liste des gestionnaires
    @carriere = Carriere.new
  end

  # GET /demande_remboursement_cotisations/new
  def new
    @demande_remboursement_cotisation = DemandeRemboursementCotisation.new
  end

  # GET /demande_remboursement_cotisations/1/edit
  def edit
    #edit
  end

  # POST /demande_remboursement_cotisations
  # POST /demande_remboursement_cotisations.json
  def create
    @demande_remboursement_cotisation = DemandeRemboursementCotisation.new(demande_remboursement_cotisation_params)
    @demande_remboursement_cotisation.ajoute_par = current_user
    participant = Psrm::Participant.find_by(matric: @demande_remboursement_cotisation.numero_affiliation)
    @demande_remboursement_cotisation.nom = participant.nom unless participant.nil?
    @demande_remboursement_cotisation.prenom = participant.prenom unless participant.nil?
    if @demande_remboursement_cotisation.save
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'La demande de rembourement est créée.'
    else
      render :new
    end
  end

  # PATCH/PUT /demande_remboursement_cotisations/1
  # PATCH/PUT /demande_remboursement_cotisations/1.json
  def update
    respond_to do |format|
      if @demande_remboursement_cotisation.update(demande_remboursement_cotisation_params)
        format.html { redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Demande remboursement cotisation was successfully updated.' }
        format.json { render :show, status: :ok, location: @demande_remboursement_cotisation }
      else
        format.html { render :edit }
        format.json { render json: @demande_remboursement_cotisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /demande_remboursement_cotisations/1
  # DELETE /demande_remboursement_cotisations/1.json
  def destroy
    @demande_remboursement_cotisation.destroy
    respond_to do |format|
      format.html { redirect_to demande_remboursement_cotisations_url, notice: 'Demande remboursement cotisation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def valider_etat_civil_demandeur
    @demande_remboursement_cotisation.etat_civil_demandeur_valide!
    redirect_to [:admin, @demande_remboursement_cotisation]
  end

  def valider_documents
    unless @demande_remboursement_cotisation.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:admin, @demande_remboursement_cotisation]
  end

  def soumettre_ligne_carriere
    carriere_prestation = Carriere.find(params[:carriere_id])
    carriere_prestation.a_rembourse!
    create_ligne_remboursement(carriere_prestation)
    redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Ligne Remboursement cotisation soumise'
  end

  def annuler_ligne_carriere
    carriere_prestation = Carriere.find(params[:carriere_id])
    carriere_prestation.en_attente!
    carriere_prestation.remboursement_cotisation.remboursement_annulee!

    redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Soumission ligne remboursement cotisation annulée'
  end

  def valider_ligne_remboursement
    remboursement = RemboursementCotisation.find(params[:remboursement_id])
    remboursement.rembouresement_valide!
    remboursement.save!
    redirect_to [:admin, @demande_liquidation], notice: 'Ligne Remboursement cotisation validée'
  end

  def soumettre
    if @demande_remboursement_cotisation.creation?
      @demande_remboursement_cotisation.est_soumis!
      @demande_remboursement_cotisation.date_soumission = DateTime.now
      @demande_remboursement_cotisation.traite_par = current_user
      @demande_remboursement_cotisation.traite_le = DateTime.now
      @demande_remboursement_cotisation.motif = nil
      @demande_remboursement_cotisation.save
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'La demande de remboursement est soumise'
    else
      redirect_to [:admin, @demande_remboursement_cotisation]
    end
  end

  def instruire
    if @demande_remboursement_cotisation.soumis?
      @demande_remboursement_cotisation.est_instruit!
      @demande_remboursement_cotisation.instruit_par = current_user
      @demande_remboursement_cotisation.instruit_le = DateTime.now
      @demande_remboursement_cotisation.motif = nil
      @demande_remboursement_cotisation.save
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Demande Instruit'
    else
      redirect_to [:admin, @demande_remboursement_cotisation]
    end
  end

  def affecter_allocataire
    #affecter une demande à un gestionnaire allocataire
    if @demande_remboursement_cotisation.update(demande_remboursement_cotisation_affecter_allocataire_params.merge(affectation_allocataire_date: DateTime.now))
      redirect_to admin_demande_remboursement_cotisations_path, notice: 'Demande Affectée.'
    end
  end

  # region : affecter une demande à un/des gestionnaire salarie
  def affecter_salarie
    #affecter une demande à un gestionnaire allocataire
    @demande_remboursement_cotisation.update(demande_remboursement_cotisation_affecter_salarie_params.merge(affectation_salarie_date: DateTime.now))
    redirect_to admin_demande_remboursement_cotisations_path, notice: 'Demande Affectée.'
  end

  def soumettre_ligne_carriere
    carriere_prestation = Carriere.find(params[:carriere_id])
    carriere_prestation.a_rembourse!
    create_ligne_remboursement(carriere_prestation)
    redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Ligne Remboursement cotisation soumise'
  end

  def annuler_ligne_carriere
    carriere_prestation = Carriere.find(params[:carriere_id])
    carriere_prestation.en_attente! or carriere_prestation.rejete!
    carriere_prestation.remboursement_cotisation.remboursement_annulee!
    redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Soumission ligne remboursement cotisation annulée'
  end

  def activer_ligne_carriere
    carriere_prestation = Carriere.find(params[:carriere_id])
    carriere_prestation.rejete!
    carriere_prestation.etat = :en_attente
    carriere_prestation.save
    redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Soumission ligne remboursement cotisation activée'
  end

  def valider_ligne_remboursement
    remboursement = RemboursementCotisation.find(params[:remboursement_id])
    remboursement.rembouresement_valide!
    remboursement.save!
    redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Ligne Remboursement cotisation validée'
  end

  def valider_all_carrieres
    if @demande_remboursement_cotisation.carriere_soumis?
      remboursements = @demande_remboursement_cotisation.remboursement_cotisations
      unless remboursements.nil?
        remboursements.each do |remboursement|
          if remboursement.soumis?
            remboursement.valide!
          end
        end
      end
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Toutes les lignes de  remboursements validées avec succés!'
    else
      redirect_to [:admin, @demande_remboursement_cotisation]
    end
  end

  def soumettre_all_carrieres
    if @demande_remboursement_cotisation.instruit?
      carrieres_prestation = @demande_remboursement_cotisation.carrieres_prestation
      unless carrieres_prestation.nil?
        carrieres_prestation.each do |carriere|
          if carriere.en_attente? s
            create_ligne_remboursement(carriere)
            carriere.a_rembourse!
          end
        end
      end
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Tous les points carrières validés avec succés!'
    else
      redirect_to [:admin, @demande_remboursement_cotisation]
    end
  end

  def rejeter_ligne_remboursement
    remboursement = RemboursementCotisation.find(params[:remboursement_id])
    remboursement.remboursement_rejete!
    remboursement.save!
    redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Ligne Remboursement cotisation rejetée'
  end

  def valider_carriere
    if @demande_remboursement_cotisation.instruit?
      if @demande_remboursement_cotisation.est_carriere_soumis!
        redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Validation remboursements avec succés!'
      else
        redirect_to [:admin, @demande_remboursement_cotisation]
      end
    else
      redirect_to [:admin, @demande_remboursement_cotisation]
    end
  end

  def cotisation_valide
    if @demande_remboursement_cotisation.cotisation_valide?
      redirect_to [:admin, @demande_remboursement_cotisation]
    else
      @demande_remboursement_cotisation.est_carriere_valide!
      @demande_remboursement_cotisation.traite_par = current_user
      @demande_remboursement_cotisation.traite_le = DateTime.now
      @demande_remboursement_cotisation.motif = nil
      @demande_remboursement_cotisation.save
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Carrière validée avec succés'

    end
  end

  def valider_recapitulatif
    if @demande_remboursement_cotisation.cotisation_valide?
      @demande_remboursement_cotisation.est_recap_soumis!
      @demande_remboursement_cotisation.traite_par = current_user
      @demande_remboursement_cotisation.traite_le = DateTime.now
      @demande_remboursement_cotisation.motif = nil
      @demande_remboursement_cotisation.save
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Recap soumis pour validation'
    else
      redirect_to [:admin, @demande_remboursement_cotisation]
    end
  end

  def recap_valide
    if @demande_remboursement_cotisation.cotisation_valide?
      redirect_to [:admin, @demande_remboursement_cotisation]
    else
      @demande_remboursement_cotisation.est_recap_valide!
      @demande_remboursement_cotisation.traite_par = current_user
      @demande_remboursement_cotisation.traite_le = DateTime.now
      @demande_remboursement_cotisation.motif = nil
      @demande_remboursement_cotisation.save
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Recap soumis pour validation'
    end
  end

  def liquidation_valide
    if @demande_remboursement_cotisation.recap_soumis?
      @demande_remboursement_cotisation.est_recap_valide!
      @demande_remboursement_cotisation.traite_par = current_user
      @demande_remboursement_cotisation.traite_le = DateTime.now
      @demande_remboursement_cotisation.motif = nil
      @demande_remboursement_cotisation.save
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Recap validée avec succés'
    else
      redirect_to [:admin, @demande_remboursement_cotisation]
    end
  end

  def dossier_valide
    if @demande_remboursement_cotisation.liquidation_valide?
      puts "========> dossier_valide"
      @demande_remboursement_cotisation.est_dossier_valide!
      @demande_remboursement_cotisation.valider_par = current_user
      @demande_remboursement_cotisation.valider_le = DateTime.now
      @demande_remboursement_cotisation.motif = nil
      @demande_remboursement_cotisation.save
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @demande_remboursement_cotisation]
    end
  end

  def dossier_rejet
    if @demande_remboursement_cotisation.liquidation_valide?
      @demande_remboursement_cotisation.traite_le = DateTime.now
      @demande_remboursement_cotisation.traite_par = current_user
      @demande_remboursement_cotisation.motif = nil
      @demande_remboursement_cotisation.est_dossier_rejete!
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @demande_remboursement_cotisation]
    end
  end

  def regulariser_remboursement
    if @demande_remboursement_cotisation.dossier_valide?
      @demande_remboursement_cotisation.est_remboursement_regularise!
      @demande_remboursement_cotisation.save
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Dossier régularisé avec succés'
    else
      redirect_to [:admin, @demande_remboursement_cotisation]
    end
  end

  def validation_inspection
    if @demande_remboursement_cotisation.remboursement_regularise?
      @demande_remboursement_cotisation.est_valide_par_inspection!
      @demande_remboursement_cotisation.save
      redirect_to [:admin, @demande_remboursement_cotisation], notice: "Dossier validé par l'inspection avec succés"
    else
      redirect_to [:admin, @demande_remboursement_cotisation]
    end
  end

  def payment_order
    @op = OrdrePaiement.find_by(dossier: @demande_remboursement_cotisation)
    @employeur = @demande_remboursement_cotisation.participant.try(:psrm_employeur)
    @employee = @demande_remboursement_cotisation.participant
    @compta_transaction = ComptaTransaction.where(dossier_id: @demande_remboursement_cotisation.id, dossier_type: 'DemandeRemboursementCotisation').first
    respond_to do |format|
      format.pdf do
        render pdf: "Ordre de paiement N°. #{@op.id}",
               page_size: 'A4',
               template: "admin/demande_remboursement_cotisations/payment_order.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def dossier_rejet
    if @demande_remboursement_cotisation.liquidation_valide?
      @demande_remboursement_cotisation.traite_le = DateTime.now
      @demande_remboursement_cotisation.traite_par = current_user
      @demande_remboursement_cotisation.motif = nil
      @demande_remboursement_cotisation.est_dossier_rejete!
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Dossier rejeté avec succés'
    else
      redirect_to [:admin, @demande_remboursement_cotisation]
    end
  end

  def retourner_process
    if @demande_remboursement_cotisation.soumis?
      @demande_remboursement_cotisation.update(traite_par: nil,
                                               traite_le: nil)
      @demande_remboursement_cotisation.retour_creation!
    else
      if @demande_remboursement_cotisation.instruit?
        @demande_remboursement_cotisation.update(instruit_par: nil,
                                                 instruit_le: nil)
        @demande_remboursement_cotisation.retour_soumis!
      else
        if @demande_remboursement_cotisation.carriere_soumis?
          @demande_remboursement_cotisation.retour_instruit!
          @demande_remboursement_cotisation.update(traite_par: nil,
                                                   traite_le: nil)
        else
          if @demande_remboursement_cotisation.cotisation_valide?
            @demande_remboursement_cotisation.retour_carriere!
            @demande_remboursement_cotisation.update(traite_par: nil,
                                                     traite_le: nil)
          else
            if @demande_remboursement_cotisation.recap_soumis?
              @demande_remboursement_cotisation.retour_cotisation!
              @demande_remboursement_cotisation.update(traite_par: nil,
                                                       traite_le: nil)
            else
              if @demande_remboursement_cotisation.liquidation_valide?
                @demande_remboursement_cotisation.retour_recap!
                @demande_remboursement_cotisation.update(traite_par: nil,
                                                         traite_le: nil)
              end
            end
          end
        end
      end
    end
    if @demande_remboursement_cotisation.update(liquidation_retraite_rejet_params.merge(traite_par: current_user,
                                                                                        traite_le: DateTime.now))
      redirect_to admin_demande_remboursement_cotisations_path, notice: 'Deamande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def bordereau_remboursement
    @demande_remboursements = DemandeRemboursementCotisation.remboursement_regularise.page(params[:page]).per(100)
  end

  def show_recue_remboursement
    @demande_remboursement = DemandeRemboursementCotisation.find(params[:id] || params[:demande_remboursement_cotisation_id])

    respond_to do |format|
      format.pdf do
        render pdf: "Récue des remboursements de cotisation de N°. #{@demande_remboursement.id}",
               page_size: 'A4',
               template: "admin/demande_remboursement_cotisations/show_recue_remboursement.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def show_facture_remboursement
    @demande_remboursement = DemandeRemboursementCotisation.find(params[:id] || params[:demande_remboursement_cotisation_id])

    respond_to do |format|
      format.pdf do
        render pdf: "Récue des remboursements de cotisation de N°. #{@demande_remboursement.id}",
               page_size: 'A4',
               template: "admin/demande_remboursement_cotisations/show_facture_remboursement.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def ajouter_carriere
    @carriere = Carriere.new(carriere_params)
    @carriere.numero_affiliation = @demande_remboursement_cotisation.numero_affiliation
    @carriere.etat = :en_attente
    @carriere.salaire = @carriere.salaire1 + @carriere.salaire2

    if @carriere.save
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Carriere ajoutée.'
    else
      redirect_to [:admin, @demande_remboursement_cotisation], notice: 'Erreur sur la création.'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_demande_remboursement_cotisation
    @demande_remboursement_cotisation = DemandeRemboursementCotisation.visible_for_admins.find(params[:id] || params[:demande_remboursement_cotisation_id])
  rescue ActiveRecord::RecordNotFound => e
    @demande_remboursement_cotisation = current_user.demande_remboursement_cotisation_creees.find(params[:id] || params[:demande_remboursement_cotisation_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def demande_remboursement_cotisation_params
    params.require(:demande_remboursement_cotisation).permit(:numero_affiliation, :prenom, :nom, :date_naissance, :lieu_naissance,
                                                             :adresse_reception_allocation, :adresse_domicile, :email, :mode_paiement,
                                                             :compte_bancaire_nom_banque, :compte_bancaire_code_banque,
                                                             :compte_bancaire_code_guichet, :compte_bancaire_numero_compte, :etat,
                                                             :motif_remboursement, :periode_remboursement)
  end

  def demande_remboursement_cotisation_affecter_allocataire_params
    params.require(:demande_remboursement_cotisation).permit(:affectation_allocataire)
  end

  def demande_remboursement_cotisation_affecter_salarie_params
    params.require(:demande_remboursement_cotisation).permit(:affectation_salarie)
  end

  def create_ligne_remboursement(carriere)
    remboursement = RemboursementCotisation.find_by_carriere_id(carriere)
    if remboursement.nil?
      remboursement = RemboursementCotisation.find_or_create_by(
        carriere_id: carriere.id,
        numero_affiliation: carriere.numero_affiliation,
        date_entree: carriere.date_entree,
        date_sortie: carriere.date_sortie,
        type_regime_id: carriere.type_regime_id,
        salaire: carriere.salaire,
        ref_employeur: carriere.ref_employeur,
        etat: :soumis,
        ajouter_le: DateTime.now,
        ajoute_par: current_user,
        points: carriere.points,
        salaire1: carriere.salaire1,
        salaire2: carriere.salaire2,
        exercice: carriere.exercice
      )
    else
      remboursement.etat = :soumis
      puts "=====OK"
    end
    remboursement.save
  end

  def update_ligne_remboursement(carriere)
    remboursement = RemboursementCotisation.find_by_carriere_id(carriere)
    rembourement.etat = :en_attente
    remboursement.save

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

  def liquidation_retraite_rejet_params
    params.require(:demande_remboursement_cotisation).permit(:motif)
  end

  def carriere_params
    params.require(:carriere).permit(:date_entree, :date_sortie, :type_regime_id, :salaire, :ref_employeur, :exercice, :points, :salaire1, :salaire2)
  end
end
