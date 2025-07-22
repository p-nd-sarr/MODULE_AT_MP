class Allocataire::ModifierModePaiementsController < Allocataire::ApplicationController
  before_action :set_allocataire
  before_action :set_modifier_mode_paiement, except: [:index, :create, :new]
  
  def index
    @modifier_mode_paiements = ModifierModePaiement.all.where(numero_allocataire: current_user.numero_salarie)
    @en_attente_soumissions = @modifier_mode_paiements.with_creation_state.page(params[:page]).per(100)
    @en_attentes_affectations = @modifier_mode_paiements.with_soumis_state.en_attente_affectation.page(params[:page]).per(100)
    @en_attentes_modif_soumis = @modifier_mode_paiements.with_soumis_state.where(affectation_allocataire: current_user.id)
    @en_attentes_validation_dossier = @modifier_mode_paiements.with_modif_soumis_state.page(params[:page]).per(100)
    @validees =  @modifier_mode_paiements.with_dossier_valide_state.page(params[:page]).per(100)
    @rejetees =  @modifier_mode_paiements.with_dossier_rejete_state.page(params[:page]).per(100)
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires allocataires
  end

  def en_attente_affectation_allocataire
    @modifier_mode_paiements = ModifierModePaiement.en_attente_allocation.page(params[:page]).per(100)
  end

  def show
    @gestionnaires = User.gestionnaire_compte_allocataire.where.not(id: @modifier_mode_paiement.ajoute_par.id) # avoir la liste des gestionnaires
  end


  def new
    @modifier_mode_paiement = ModifierModePaiement.new
  end

  def create
    @modifier_mode_paiement = ModifierModePaiement.new(modifier_mode_paiement_params)
    @modifier_mode_paiement.numero_allocataire = @allocataire.numero_allocataire
    @modifier_mode_paiement.prenom = @allocataire.prenom
    @modifier_mode_paiement.nom = @allocataire.nom
    @modifier_mode_paiement.ajoute_par = current_user
    respond_to do |format|
      if @modifier_mode_paiement.save
        #record_history("Demande de modification du mode de paiement",  @modifier_mode_paiement.etat) 
        format.html { redirect_to [:allocataire, @modifier_mode_paiement], notice: 'La demande de regularisation pension was successfully created.' }
        format.json { render :index, status: :created, location: @modifier_mode_paiement }
      else
        format.html { render :new }
        format.json { render json: @modifier_mode_paiement.errors, status: :unprocessable_entity }
      end
    end
  end

  def valider_etat_civil_demandeur
    unless @modifier_mode_paiement.etat_civil_demandeur_valide!
      flash[:error] = "Error de validation"
    end
    redirect_to [:allocataire, @modifier_mode_paiement]
  end

  def valider_documents
    unless @modifier_mode_paiement.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:allocataire, @modifier_mode_paiement]
  end
    private
    def modifier_mode_paiement_params
        params.require(:modifier_mode_paiement).permit(:mode_paiement,
                                            :compte_bancaire_nom_banque, :compte_bancaire_code_banque,
                                            :compte_bancaire_code_guichet, :compte_bancaire_numero_compte,
                                            :rib, :attestation_non_engagement, :certificat_medical,:motif_virement)
    end
    
    def set_allocataire
      @allocataire = current_user.allocataire
    end

    def set_modifier_mode_paiement
        @modifier_mode_paiement = ModifierModePaiement.find(params[:id] || params[:modifier_mode_paiement_id])
    end
    def modifier_mode_paiement_affecter_params
        params.require(:modifier_mode_paiement).permit(:affectation_allocataire)
    end
  

    def record_history(type_demande, etat)
      historique = Historique.new
      historique.evenement = type_demande
      historique.etat = etat
      historique.allocataire_id = @allocataire.id
      historique.user_id = current_user.id
      historique.save
    end
    
end