class Admin::ModifierAdressesController < Admin::ApplicationController
  before_action :set_allocataire,except: [:en_attente_soumission, :en_attente_verification,:en_attente_affectation,:en_attente_validation, :edit]
  before_action :set_modifier_adresse, except: [:index, :new, :create, :en_attente_soumission, :en_attente_verification,
                                                :en_attente_affectation,:en_attente_validation]
 
  def index
    @modifier_adresses = @allocataire.modifier_adresses
    @en_attente_soumissions = @modifier_adresses.with_creation_state.page(params[:page]).per(100)
    @en_attentes_affectations = @modifier_adresses.with_soumis_state.en_attente_affectation.page(params[:page]).per(100)
    @en_attentes_modif_soumis = @modifier_adresses.with_soumis_state.where(affectation_allocataire: current_user.id)
    @en_attentes_validation_dossier = @modifier_adresses.with_modif_soumis_state.page(params[:page]).per(100)
    @validees =  @modifier_adresses.with_dossier_valide_state.page(params[:page]).per(100)
    @rejetees =  @modifier_adresses.with_dossier_rejete_state.page(params[:page]).per(100)
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires allocataires
  end


  def en_attente_soumission
    @modifier_adresses = ModifierAdresse.en_attente_soumission.where(ajoute_par: current_user.id)
  end
  def en_attente_affectation
    @modifier_adresses = ModifierAdresse.en_attente_affectation
  end

  def en_attente_verification
    @modifier_adresses = ModifierAdresse.en_attente_verification.where(affectation_allocataire: current_user.id)
  end

  def en_attente_validation
    @modifier_adresses = ModifierAdresse.en_attente_validation
  end

  def edit
    @allocataire = Allocataire.find_by_numero_allocataire(@modifier_adresse.numero_allocataire)
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
     # @modifier_adresse.date_soumission = DateTime.now
      respond_to do |format|
        if @modifier_adresse.save
         # record_history("Demande de modification d'adresse",  @modifier_adresse.etat) 
          format.html { redirect_to [:admin, @allocataire, @modifier_adresse], notice: 'La demande de regularisation pension was successfully created.' }
          format.json { render :index, status: :created, location: @modifier_adresse }
        else
          format.html { render :new }
          format.json { render json: @modifier_adresse.errors, status: :unprocessable_entity }
        end
    end
  end


  def update
    if @modifier_adresse.update(modifier_adresse_params)
      redirect_to [:admin, @allocataire, @modifier_adresse], notice: 'La demande de modification adresse est bien mise à jour.'
    else
      render :edit
    end
  end

 

  def affectation
    if @modifier_adresse.update(modifier_adresse_affecter_params.merge(affectation_allocataire_date: DateTime.now))
      #record_history("Demande de modification d'adresse",  @modifier_adresse.etat) 
      respond_to do |format|
        format.html { redirect_to [:admin, @allocataire, @modifier_adresse], notice: 'La demande  a ete bien affectée.' }
        format.json { render :index, status: :created, location: @modifier_adresse }
      end
    end
  end
 

    def rejeter
      if @modifier_adresse.update(modifier_adresse_motifs_rejet_params.merge(traite_par: current_user,
        traite_le: DateTime.now, etat: :rejete))
        record_history("Demande de modification d'adresse",  @modifier_adresse.etat) 
        redirect_to admin_demandes_modifier_adresses_path, notice: 'Demande rejetée avec succes.'
      end
    end


    def valider_etat_civil_demandeur
      unless @modifier_adresse.etat_civil_demandeur_valide!
        flash[:error] = "Error de validation"
      end
      redirect_to [:admin,@allocataire, @modifier_adresse]
    end
  
    def valider_documents
      unless @modifier_adresse.documents_valide!
        flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
      end
      redirect_to [:admin,@allocataire, @modifier_adresse]
    end
  
    def soumettre
      if @modifier_adresse.creation?
        @modifier_adresse.est_soumis!
        @modifier_adresse.date_soumission = DateTime.now
        @modifier_adresse.soumis_par = current_user
        #@modifier_adresse.traite_le = DateTime.now
        @modifier_adresse.motif = nil
        @modifier_adresse.save
        redirect_to [:admin, @allocataire, @modifier_adresse], notice: 'La demande a été soumise avec succés'
      else
        redirect_to [:admin,@allocataire,  @modifier_adresse]
      end
  
    end
  
  
    def soumettre_modification
      if @modifier_adresse.soumis?
        @modifier_adresse.est_modif_soumis!
        #@modifier_adresse.traite_par = current_user
        #@modifier_adresse.traite_le = DateTime.now
        @modifier_adresse.motif = nil
        @modifier_adresse.save
        redirect_to [:admin, @allocataire, @modifier_adresse], notice: 'Les modification ont été soumises avec succés'
      else
        redirect_to [:admin,@allocataire,  @modifier_adresse]
      end
  
    end

    def valider
      if @modifier_adresse.modif_soumis?
        @allocataire = Allocataire.find_by_numero_allocataire(@modifier_adresse.numero_allocataire)
        @modifier_adresse.valider_par= current_user
        @modifier_adresse.date_validation = DateTime.now
        @modifier_adresse.est_dossier_valide!
        @allocataire.adresse_rue = @modifier_adresse.adresse_rue
        @allocataire.adresse_ville = @modifier_adresse.adresse_ville
        @allocataire.code_region = @modifier_adresse.code_region
        @allocataire.code_pays = @modifier_adresse.code_pays
        @allocataire.save!
        @modifier_adresse.save!
        redirect_to [:admin, @allocataire, @modifier_adresse], notice: 'Les modification ont été soumises avec succés'
      else
        redirect_to [:admin,@allocataire,  @modifier_adresse]
      end
    end

    def retourner_process
      if @modifier_adresse.soumis?
        @modifier_adresse.update(soumis_par: nil,
                                  date_soumission: nil)
        @modifier_adresse.retour_creation!
      else
        if @modifier_adresse.modif_soumis?
          @modifier_adresse.update(soumis_par: nil,
                                    date_soumission: nil)
          @modifier_adresse.retour_soumis!
        else
          if @modifier_adresse.dossier_valide?
            @modifier_adresse.soumis!
            @modifier_adresse.update(verifie_par: nil,
                                        verifie_le: nil)
          end
        end
      end
      if @modifier_adresse.update(modifier_adresse_motifs_rejet_params.merge(traite_par: current_user,
                                                                             traite_le: DateTime.now))
        redirect_to [:admin, @allocataire, @modifier_adresse], notice: 'Dossier a été retourné avec succés'
      else
        flash[:error] = 'Une erreur est survenue lors du traitement'
        render :rejeter
      end
    end
  
   

  private
  def modifier_adresse_params
    params.require(:modifier_adresse).permit(:numero_allocataire, :prenom, :nom, :adresse_rue,
                                        :adresse_ville, :code_region, :code_pays)
  end
  
  def set_allocataire
      @allocataire = Allocataire.find(params[:allocataire_id] || params[:id])
  end

  def set_modifier_adresse
      @modifier_adresse = ModifierAdresse.find(params[:id] || params[:modifier_adress_id])
  end

  def modifier_adresse_affecter_params
    params.require(:modifier_adresse).permit(:affectation_allocataire)
  end

  def modifier_adresse_motifs_rejet_params
    params.require(:modifier_adresse).permit(:motif)
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