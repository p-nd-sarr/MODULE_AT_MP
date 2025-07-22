class Allocataire::ModifierAdressesController < Allocataire::ApplicationController
  before_action :set_allocataire
  before_action :set_modifier_adresse, except: [:index, :new, :create]
 
  def index
    @modifier_adresses = ModifierAdresse.all.where(numero_allocataire: current_user.numero_salarie)
    @en_attente_soumissions = @modifier_adresses.with_creation_state.page(params[:page]).per(100)
    @en_attentes_affectations = @modifier_adresses.with_soumis_state.en_attente_affectation.page(params[:page]).per(100)
    @en_attentes_modif_soumis = @modifier_adresses.with_soumis_state.where(affectation_allocataire: current_user.id)
    @en_attentes_validation_dossier = @modifier_adresses.with_modif_soumis_state.page(params[:page]).per(100)
    @validees =  @modifier_adresses.with_dossier_valide_state.page(params[:page]).per(100)
    @rejetees =  @modifier_adresses.with_dossier_rejete_state.page(params[:page]).per(100)
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires allocataires
  end

  def show
    @gestionnaires = User.gestionnaire_compte_allocataire.where.not(id: @modifier_adresse.ajoute_par.id) # avoir la liste des gestionnaires
  end


  def new
      @modifier_adresse = ModifierAdresse.new
      @modifier_adresse.numero_allocataire = @allocataire.numero_allocataire
      @modifier_adresse.prenom = @allocataire.prenom
      @modifier_adresse.nom = @allocataire.nom
  end

  def create

      @modifier_adresse = ModifierAdresse.new(modifier_adresse_params)
      @modifier_adresse.numero_allocataire = @allocataire.numero_allocataire
      @modifier_adresse.prenom = @allocataire.prenom
      @modifier_adresse.nom = @allocataire.nom
      @modifier_adresse.ajoute_par = current_user
      @modifier_adresse.code_pays = "SN"
      @modifier_adresse.code_region = "DK"
      @modifier_adresse.date_soumission = DateTime.now
      respond_to do |format|
        if @modifier_adresse.save
         # record_history("Demande de modification d'adresse",  @modifier_adresse.etat) 
          format.html { redirect_to [:allocataire, @modifier_adresse], notice: 'La demande de regularisation pension was successfully created.' }
          format.json { render :index, status: :created, location: @modifier_adresse }
        else
          format.html { render :new }
          format.json { render json: @modifier_adresse.errors, status: :unprocessable_entity }
        end
    end
  end

 




    def valider_etat_civil_demandeur
      unless @modifier_adresse.etat_civil_demandeur_valide!
        flash[:error] = "Error de validation"
      end
      redirect_to [:allocataire, @modifier_adresse]
    end
  
    def valider_documents
      unless @modifier_adresse.documents_valide!
        flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
      end
      redirect_to [:allocataire, @modifier_adresse]
    end
  

  
   

  private
  def modifier_adresse_params
    params.require(:modifier_adresse).permit(:numero_allocataire, :prenom, :nom, :adresse_rue,
                                        :adresse_ville, :code_region, :code_pays)
  end
  
  def set_allocataire
    @allocataire = current_user.allocataire
  end

  def set_modifier_adresse
      @modifier_adresse = ModifierAdresse.find(params[:id] || params[:modifier_adress_id])
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