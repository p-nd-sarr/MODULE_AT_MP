class Allocataire::RegularisationPensionsController < ApplicationController
  before_action :set_allocataire
  before_action :set_regularisation_pension, except: [:index, :create, :new]
  
  def index
    @regularisation_pensions = @allocataire.regularisation_pensions
    @en_attente_soumissions = @regularisation_pensions.with_creation_state.page(params[:page]).per(100)
    @en_attente_instruction = @regularisation_pensions.with_soumis_state.en_attente_affectation.page(params[:page]).per(100)
    @en_attentes_affectations = @regularisation_pensions.with_instruit_state.en_attente_affectation.page(params[:page]).per(100)
    @en_attentes_soumission_recap = @regularisation_pensions.with_instruit_state.where(affectation_allocataire: current_user.id)
    @en_attentes_validation_recap = @regularisation_pensions.with_recap_soumis_state
    @en_attentes_validation_dossier = @regularisation_pensions.with_recap_valide_state.page(params[:page]).per(100)
    @validees =  @regularisation_pensions.with_dossier_valide_state.page(params[:page]).per(100)
    @dossiers_regularises =  @regularisation_pensions.with_regularise_state.page(params[:page]).per(100)
    @rejetees =  @regularisation_pensions.with_dossier_rejete_state.page(params[:page]).per(100)
  end

  def show
    @gestionnaires = User.gestionnaire_compte_allocataire.where.not(id: @regularisation_pension.ajoute_par) # avoir la liste des gestionnaires
  end

  def new
    @regularisation_pension = RegularisationPension.new
    @regularisation_pension.numero_allocataire = @allocataire.numero_allocataire
    @regularisation_pension.prenom = @allocataire.prenom
    @regularisation_pension.nom = @allocataire.nom
  end

  def create

    @regularisation_pension = RegularisationPension.new(regularisation_pension_params)
    @regularisation_pension.ajoute_par = current_user
    @regularisation_pension.numero_allocataire = @allocataire.numero_allocataire
    @regularisation_pension.prenom = @allocataire.prenom
    @regularisation_pension.nom = @allocataire.nom
    respond_to do |format|
      if @regularisation_pension.save
        record_history("Demande regularisation de pension",  @regularisation_pension.etat) 
        format.html { redirect_to [:admin, @allocataire, @regularisation_pension], notice: 'La demande de regularisation pension a été bien créée.' }
      else
        format.html { render :new }
        
      end
    end
  end

  def update
    respond_to do |format|
      if @regularisation_pension.update(regularisation_pension_params)
        format.html { redirect_to [:admin, @allocataire, @regularisation_pension], notice: 'La demande de regularisation pension was successfully updated.' }
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
    redirect_to [:admin,@allocataire, @regularisation_pension]
  end

  def valider_documents
    unless @regularisation_pension.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:admin,@allocataire, @regularisation_pension]
  end

  def soumettre
    if @regularisation_pension.creation?
      @regularisation_pension.est_soumis!
      @regularisation_pension.date_soumission = DateTime.now
      @regularisation_pension.traite_par = current_user
      @regularisation_pension.traite_le = DateTime.now
      @regularisation_pension.motif = nil
      @regularisation_pension.save
      redirect_to [:admin, @allocataire, @regularisation_pension], notice: 'La demande de regularisation de pensions est soumise'
    else
      redirect_to [:admin,@allocataire,  @regularisation_pension]
    end

  end

  def instruire
    if @regularisation_pension.soumis?
      @regularisation_pension.est_instruit!
      @regularisation_pension.instruit_par = current_user
      @regularisation_pension.instruit_le = DateTime.now
      @regularisation_pension.motif = nil
      @regularisation_pension.save
      redirect_to [:admin,@allocataire, @regularisation_pension], notice: 'Demande Instruit'
    else
      redirect_to [:admin,@allocataire, @regularisation_pension]
    end
  end

  def retourner_process
    if @regularisation_pension.soumis?
      @regularisation_pension.update(traite_par: nil,
                                  traite_le: nil)
      @regularisation_pension.retour_creation!
    else
      if @regularisation_pension.instruit?
        @regularisation_pension.update(instruit_par: nil,
                                    instruit_le: nil)
        @regularisation_pension.retour_soumis!
      else
        if @regularisation_pension.carriere_soumis?
          @regularisation_pension.retour_instruit!
          @regularisation_pension.update(traite_par: nil,
                                      traite_le: nil)
        else
          if @regularisation_pension.cotisation_valide?
            @regularisation_pension.retour_carriere!
            @regularisation_pension.update(traite_par: nil,
                                        traite_le: nil)
          else
            if @regularisation_pension.recap_soumis?
              @regularisation_pension.retour_cotisation!
              @regularisation_pension.update(traite_par: nil,
                                          traite_le: nil)
            else
              if @regularisation_pension.liquidation_valide?
                @regularisation_pension.retour_recap!
                @regularisation_pension.update(traite_par: nil,
                                            traite_le: nil)
              end
            end
          end
        end
      end
    end
    if @regularisation_pension.update(regularisation_pension_motifRetouner_params.merge(traite_par: current_user,
                                                                           traite_le: DateTime.now))
      redirect_to admin_allocataire_regularisation_pensions_path, notice: 'Deamande traitée.'
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
      format.html { redirect_to [:admin, @allocataire], notice: 'La demande de regularisation pension was successfully destroyed.' }
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
    @regularisation_pension = RegularisationPension.find(params[:id]|| params[:regularisation_pension_id])
  end

  def regularisation_pension_params
    params.require(:regularisation_pension).permit(:numero_allocataire, :prenom, :nom, :motif_regularisation_pension, :attachment, :duree_suspension)
  end

  def set_allocataire
    @allocataire = current_user.allocataire
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
end

