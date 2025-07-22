class Admin::RegularisationPensionsController < Admin::ApplicationController
  before_action :set_allocataire, only: [:new, :create, :index]
  before_action :set_beneficiary, only: [:update_beneficiary, :edit_beneficiary]
  before_action :set_regularisation_pension, except: [:index, :create, :new, :en_attente_soumission, :en_attente_instruction, :en_attente_affectation, :en_attente_verification, :en_attente_validation_recap, :en_attente_validation_chef_service, :en_attente_validation_chef_agence, :en_attente_regularisation,
                                                      :edit_beneficiary, :update_beneficiary, :en_attente_valider_directeur, :toutes_les_demandes, :en_attente_validation_chef_section, :en_attente_validation_inspection]

  def index
    @q = @allocataire.regularisation_pensions.ransack(params[:q])
    @regularisation_pensions = @q.result.order('created_at DESC').page(params[:page]).per(100)
  end

  def toutes_les_demandes
    @q = RegularisationPension.all.ransack(params[:q])
    @total = @q.result.count
    @regularisation_pensions = @q.result.order('created_at DESC')
    @regularisation_pensions = @regularisation_pensions.page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def show
    @gestionnaires = User.gestionnaire_compte_allocataire.where.not(id: @regularisation_pension.ajoute_par) # avoir la liste des gestionnaires

  end

  def en_attente_soumission
    @q = RegularisationPension.with_creation_state.where(ajoute_par: current_user.id).ransack(params[:q])
    @total = @q.result.count
    @regularisation_pensions = @q.result.order('created_at DESC').page(params[:page]).per(100)
  end



  def en_attente_valider_directeur
    @q = RegularisationPension.en_attente_validation_dp.ransack(params[:q])
    @total = @q.result.count
    @regularisation_pensions = @q.result.order('date_validation_service').page(params[:page]).per(100)
  end


  def en_attente_validation_recap
    @q = RegularisationPension.with_recap_soumis_state.ransack(params[:q])
    @total = @q.result.count
    @regularisation_pensions = @q.result.order('created_at DESC').page(params[:page]).per(100)
  end

  def en_attente_validation_chef_service
    @q = RegularisationPension.en_attente_validation_chef_service.ransack(params[:q])
    @total = @q.result.count
    @regularisation_pensions = @q.result.order('created_at DESC').page(params[:page]).per(100)
  end

  def en_attente_validation_chef_agence
    @q = RegularisationPension.en_attente_validation_chef_agence.meme_agence(current_user.agence.id).ransack(params[:q])
    @total = @q.result.count
    @regularisation_pensions = @q.result.order('created_at DESC').page(params[:page]).per(100)
  end

  def en_attente_regularisation
    @q = RegularisationPension.with_dossier_valide_state.ransack(params[:q])
    @total = @q.result.count
    @regularisation_pensions = @q.result.order('created_at DESC').page(params[:page]).per(100)
  end

  def en_attente_validation_chef_section
    @q = RegularisationPension.en_attente_validation_chef_section.ransack(params[:q])
    @total = @q.result.count
    @regularisation_pensions = @q.result.order('created_at DESC').page(params[:page]).per(100)
  end

  def en_attente_validation_inspection
    @q = RegularisationPension.en_attente_validation_inspection.ransack(params[:q])
    @total = @q.result.count
    @regularisation_pensions = @q.result.order('date_validation_dp').page(params[:page]).per(100)
  end

  def en_attente_instruction
    @q = RegularisationPension.en_attente_validation_chef_agence.meme_agence(current_user.agence.id).ransack(params[:q])
    @total = @q.result.count
    @regularisation_pensions = @q.result.order('created_at DESC').page(params[:page]).per(100)

  end



  

  def new
    @regularisation_pension = RegularisationPension.new
    @regularisation_pension.numero_allocataire = @allocataire.numero_allocataire
    @regularisation_pension.prenom = @allocataire.prenom
    @regularisation_pension.nom = @allocataire.nom
  end

  def edit
    @allocataire = @regularisation_pension.allocataire
  end

  def create
    @regularisation_pension = RegularisationPension.new(regularisation_pension_params)
    @regularisation_pension.ajoute_par = current_user
    @regularisation_pension.numero_allocataire = @allocataire.numero_allocataire
    @regularisation_pension.prenom = @allocataire.prenom
    @regularisation_pension.nom = @allocataire.nom
    respond_to do |format|
      if @regularisation_pension.save
        record_history("Demande regularisation de pension", @regularisation_pension.etat)
        format.html { redirect_to [:admin, @regularisation_pension], notice: 'La demande de regularisation pension a été bien créée.' }
      else
        format.html { render :new }

      end
    end
  end

  def new_beneficiary
    @beneficiary = RegBeneficiary.new
    @allocataire = @regularisation_pension.allocataire
  end

  def edit_beneficiary
    @allocataire = @beneficiary.regularisation_pension.allocataire
    @regularisation_pension = @beneficiary.regularisation_pension
  end

  def create_beneficiary
    @beneficiary = RegBeneficiary.new(beneficiary_params_params)
    @beneficiary.regularisation_pension = @regularisation_pension
    respond_to do |format|
      if @beneficiary.save
        format.html { redirect_to [:admin, @regularisation_pension], notice: 'Le bénéficiaire a été créé avec succès!.' }
      else
        flash[:error] = 'Erreur lors de la création', @beneficiary.errors.full_messages
        format.html { redirect_to [:admin, @regularisation_pension] }
      end
    end
  end

  def update_beneficiary
    respond_to do |format|
      if @beneficiary.update(beneficiary_params_params)
        format.html { redirect_to [:admin, @beneficiary.regularisation_pension], notice: 'Le bénéficiaire a été modifié avec succès!.' }
      else
        flash[:error] = 'Erreur lors de la modification'
        format.html { redirect_to [:admin, @beneficiary.regularisation_pension] }
      end
    end
  end

  def update
    respond_to do |format|
      if @regularisation_pension.update(regularisation_pension_params)
        format.html { redirect_to [:admin, @regularisation_pension], notice: 'La demande de regularisation pension was successfully updated.' }
        format.json { render :show, status: :ok, location: @regularisation_pension }
      else
        format.html { render :edit }
        format.json { render json: @regularisation_pension.errors, status: :unprocessable_entity }
      end
    end
  end

  def valider_etat_civil_demandeur
    unless @regularisation_pension.etat_civil_demandeur_valide!
      flash[:error] = "Error de validation"
    end
    redirect_to [:admin, @allocataire, @regularisation_pension]
  end

  def valider_beneficiaire
    unless @regularisation_pension.beneficiaire_valide!
      flash[:error] = "Error de validation"
    end
    redirect_to [:admin, @allocataire, @regularisation_pension]
  end

  def valider_documents
    unless @regularisation_pension.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:admin, @allocataire, @regularisation_pension]
  end

  # region : soumettre impayes
  def soumettre_all_impayes
    if @regularisation_pension.creation?
      op_impayes = @regularisation_pension.regularisation_impayes
      unless op_impayes.nil?
        op_impayes.each do |op|
          op.soumettre if op.en_attente?
        end
      end
      redirect_to [:admin, @regularisation_pension], notice: 'Tous les lignes sont validés avec succés!'
    else
      redirect_to [:admin, @regularisation_pension]
    end
  end

  def annuler_ligne_impaye
    op_impaye = RegularisationImpaye.find(params[:regularisation_impaye_id])
    op_impaye.annuler
    redirect_to [:admin, @regularisation_pension], notice: 'Ligne impayée rejetée avec succés'
  end


  # region : valider impayes
  def valider_all_impayes
    if @regularisation_pension.creation? and (current_user == @regularisation_pension.ajoute_par)
      op_impayes = @regularisation_pension.regularisation_impayes
      unless op_impayes.nil?
        op_impayes.each do |op|
          op.valider if op.en_attente?
        end
      end
      redirect_to [:admin, @regularisation_pension], notice: 'Toutes les lignes sont validés avec succés!'
    else
      redirect_to [:admin, @regularisation_pension]
    end
  end

  def valider_ligne_impaye
    op_impaye = RegularisationImpaye.find(params[:regularisation_impaye_id])
    op_impaye.valider
    redirect_to [:admin, @regularisation_pension], notice: 'Ligne impayée validée avec succés'
  end

  def soumettre
    if @regularisation_pension.creation?
      if @regularisation_pension.creer_au_siege?
        @regularisation_pension.est_soumis_chef_section_liquidation!
      else
        @regularisation_pension.est_soumis_chef_agence!
      end
      @regularisation_pension.date_soumission = DateTime.now
      @regularisation_pension.soumis_par = current_user
      @regularisation_pension.motif = nil
      @regularisation_pension.save
      redirect_to [:admin, @regularisation_pension], notice: 'La demande de regularisation de pensions est soumise'
    else
      redirect_to [:admin,@allocataire,  @regularisation_pension]
    end

  end

  def valider_chef_agence
    if @regularisation_pension.soumis_chef_agence?
      @regularisation_pension.est_soumis_chef_section_liquidation!
      @regularisation_pension.validation_agence_par = current_user
      @regularisation_pension.date_validation_agence = DateTime.now
      @regularisation_pension.motif = nil
      @regularisation_pension.save
      redirect_to [:admin, @regularisation_pension], notice: 'La demande de regularisation de pensions est soumise'
    else
      redirect_to [:admin,@regularisation_pension]
    end
  end

  def valider_chef_section
    if @regularisation_pension.soumis_chef_section_liquidation?
      @regularisation_pension.est_soumis_chef_service!
      @regularisation_pension.validation_chef_section_par = current_user
      @regularisation_pension.date_validation_chef_section = DateTime.now
      @regularisation_pension.motif = nil
      @regularisation_pension.save
      redirect_to [:admin, @regularisation_pension], notice: 'La demande de regularisation de pensions est soumise'
    else
      redirect_to [:admin,@regularisation_pension]
    end
  end

  def valider_chef_service
    if @regularisation_pension.soumis_chef_service?
      @regularisation_pension.est_soumis_directeur!
      @regularisation_pension.validation_service_par = current_user
      @regularisation_pension.date_validation_service = DateTime.now
      @regularisation_pension.motif = nil
      @regularisation_pension.save
      redirect_to [:admin, @regularisation_pension], notice: 'La demande de regularisation de pensions est soumise'
    else
      redirect_to [:admin,@regularisation_pension]
    end
  end

  def valider_directeur
    if @regularisation_pension.soumis_directeur?
      @regularisation_pension.est_soumis_inspection!
      @regularisation_pension.validation_direction_par = current_user
      @regularisation_pension.date_validation_dp = DateTime.now
      @regularisation_pension.motif = nil
      @regularisation_pension.save
      redirect_to [:admin, @regularisation_pension], notice: 'La demande de regularisation de pensions est soumise'
    else
      redirect_to [:admin,@regularisation_pension]
    end
  end

  def valider_inspection
    allocataire = Allocataire.find_by(numero_allocataire: @regularisation_pension.numero_allocataire)
    if @regularisation_pension.soumis_inspection?
      @regularisation_pension.est_validation_inspection!
      @regularisation_pension.validation_inspection_par = current_user
      @regularisation_pension.date_validation_inspection = DateTime.now
      if allocataire.suspendus?
        puts "========> dossier_valide", allocataire.inspect
        allocataire.etat = :actif
        allocataire.save
      end
      @regularisation_pension.motif = nil
      @regularisation_pension.save
      redirect_to [:admin, @regularisation_pension], notice: 'La demande de regularisation de pensions a éte bien validée'
    else
      redirect_to [:admin,@regularisation_pension]
    end
  end



  def retourner_process
    if @regularisation_pension.soumis_chef_agence?
      initial_etat_impayes(@regularisation_pension.regularisation_impayes)
      @regularisation_pension.update(date_soumission: nil,
                                  soumis_par: nil)
      @regularisation_pension.retour_creation!
    else
      if @regularisation_pension.soumis_chef_section_liquidation? and !@regularisation_pension.creer_au_siege?
        @regularisation_pension.update(date_validation_chef_section: nil)
        @regularisation_pension.retour_soumis_chef_agence!
      else
        if @regularisation_pension.soumis_chef_section_liquidation? and @regularisation_pension.creer_au_siege?
          @regularisation_pension.retour_creation!
          initial_etat_impayes(@regularisation_pension.regularisation_impayes)
          @regularisation_pension.update(date_soumission: nil,
                                               soumis_par: nil)
        else
          if @regularisation_pension.soumis_chef_service?
            @regularisation_pension.retour_soumis_chef_section_liquidation!
            @regularisation_pension.update(date_validation_chef_section: nil,
                                            validation_chef_section_par: nil)
          else
            if @regularisation_pension.soumis_directeur?
              @regularisation_pension.retour_soumis_chef_service!
              @regularisation_pension.update(date_validation_service: nil,
                                                validation_service_par: nil)
            else
              if @regularisation_pension.soumis_inspection?
                @regularisation_pension.retour_soumis_directeur!
                @regularisation_pension.update(date_validation_inspection: nil,
                                               validation_inspection_par: nil)
              end
            end
          end
        end
      end
    end
    if @regularisation_pension.update(regularisation_pension_motifRetouner_params.merge(traite_par: current_user,
                                                                           traite_le: DateTime.now))
      redirect_to [:admin,@regularisation_pension], notice: 'Deamande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def affecter_allocataire
    #affecter une demande à un gestionnaire allocataire
    if @regularisation_pension.update(regularisation_pension_affecter_allocataire_params.merge(affectation_allocataire_date: DateTime.now))
      redirect_to admin_allocataire_regularisation_pensions_path, notice: 'Demande Affectée.'
    end
  end



  def valider_recapitulatif
    if @regularisation_pension.instruit?
      @regularisation_pension.est_recap_soumis!
      @regularisation_pension.traite_par = current_user
      @regularisation_pension.traite_le = DateTime.now
      @regularisation_pension.motif = nil
      @regularisation_pension.save
      redirect_to [:admin,@allocataire, @regularisation_pension], notice: 'Recap soumis pour validation'
    else
      redirect_to [:admin,@allocataire, @regularisation_pension]
    end
  end

  def recap_valide
    if @regularisation_pension.cotisation_valide?
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
    if @regularisation_pension.recap_soumis?
      @regularisation_pension.est_recap_valide!
      @regularisation_pension.traite_par = current_user
      @regularisation_pension.traite_le = DateTime.now
      @regularisation_pension.motif = nil
      @regularisation_pension.save
      redirect_to [:admin, @allocataire, @regularisation_pension], notice: 'Recap validée avec succés'
    else
      redirect_to [:admin, @allocataire, @regularisation_pension]
    end
  end

  def dossier_valide
    if @regularisation_pension.recap_valide?
      puts "========> dossier_valide"
      @regularisation_pension.est_dossier_valide!
      @regularisation_pension.valider_par = current_user
      @regularisation_pension.date_validation = DateTime.now
      @regularisation_pension.motif = nil
      @allocataire.etat=:actif
      @allocataire.save!
      @regularisation_pension.save
     
      redirect_to [:admin,@allocataire, @regularisation_pension], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin,@allocataire, @regularisation_pension]
    end
  end

  def regulariser
    if @regularisation_pension.dossier_valide?
      puts "========> dossier_valide"
      @regularisation_pension.est_regularise!
      @regularisation_pension.traite_par = current_user
      @regularisation_pension.traite_le = DateTime.now
      @regularisation_pension.motif = nil
      @regularisation_pension.save
      redirect_to [:admin,@allocataire, @regularisation_pension], notice: 'Dossier regularisé avec succés'
    else
      redirect_to [:admin,@allocataire, @regularisation_pension]
    end
  end
  
  def dossier_rejet
    if @regularisation_pension.liquidation_valide?
      @regularisation_pension.traite_le = DateTime.now
      @regularisation_pension.traite_par = current_user
      @regularisation_pension.motif = nil
      @regularisation_pension.est_dossier_rejete!
      redirect_to [:admin, @allocataire, @regularisation_pension], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin,@allocataire, @regularisation_pension]
    end
  end

  def destroy
    @regularisation_pension.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @regularisation_pension.allocataire], notice: 'La demande de regularisation pension was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def lettre_notification
    @regularisation_pension = RegularisationPension.find(params[:id] || params[:regularisation_pension_id])
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "lettre notification n°. #{@regularisation_pension.id}",
               page_size: 'A4',
               template: "admin/regularisation_pensions/lettre_notification.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  private

  def set_regularisation_pension
    @regularisation_pension = RegularisationPension.find(params[:id] || params[:regularisation_pension_id])
  end

  def regularisation_pension_params
    params.require(:regularisation_pension).permit(:numero_allocataire, :prenom, :nom, :motif_regularisation_pension, :attachment, :duree_suspension, :date_suspension_allocataire, :date_fin_regularisation, :date_debut_regularisation, :autre_montant, :comment_gestionnaire)
  end

  def beneficiary_params_params
    params.require(:reg_beneficiary).permit(:prenom, :nom, :date_naissance, :nin, :telephone)
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id] || params[:id])
  end

  def set_beneficiary
    @beneficiary = RegBeneficiary.find(params[:id_beneficiary])
  end

  def regulation_pension_affecter_params
    params.require(:regularisation_pension).permit(:affectation_allocataire)
  end

  def regularisation_pension_rejeter_params
    params.require(:regularisation_pension).permit(:motif_rejet)
  end

  def regularisation_pension_motifRetouner_params
    params.require(:regularisation_pension).permit(:motif)
  end

  def record_history(type_demande, etat)
    historique = Historique.new
    historique.evenement = type_demande
    historique.etat = etat
    historique.allocataire_id = @allocataire.id
    historique.user_id = current_user.id
    historique.save
  end

  def regularisation_pension_affecter_allocataire_params
    params.require(:regularisation_pension).permit(:affectation_allocataire)
  end

  def initial_etat_impayes(op_impayes)
    puts "INIT OKKKK"
    unless op_impayes.nil?
      op_impayes.each do |op|
        op.mettre_en_attente
      end
    end
   
  end

end
