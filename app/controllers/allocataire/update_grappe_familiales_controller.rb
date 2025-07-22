class Allocataire::UpdateGrappeFamilialesController < Allocataire::ApplicationController
    before_action :set_grappe_familiale, except: [:index, :new, :create, :ajouter_declaration]
    before_action :peut_etre_edite!, except: [:index, :new, :create, :show,:ajouter_declaration]
    before_action :can_add!, only: [:new, :create, :ajouter_declaration]
    before_action :set_allocataire

    def index
      @update_grappe_familiales = UpdateGrappeFamiliale.all.where(numero_allocataire: current_user.numero_salarie)
      @update_grappe_conjoints=UpdateGrappeFamiliale.where.not("conjoint_id IS ?", nil)
      @update_grappe_enfants=UpdateGrappeFamiliale.where.not("enfant_id IS ?", nil)
    end

    def ajouter_declaration
      @conjoints = current_user.conjoints
      @enfants = current_user.enfants 
    end
    def show
      
        @conjoints = current_user.conjoints
        @enfants = current_user.enfants 
      end
    
      def new
        @type = params[:type]
        @etat = params[:etat]
        @update_grappe_familiale = UpdateGrappeFamiliale.new
        @update_grappe_familiale.num_affiliation = current_user.numero_salarie
        if @type == "enfant"
          @enfant = Enfant.find(params[:id])
          @update_grappe_familiale.enfant_id = @enfant.id
          @update_grappe_familiale.prenom = @enfant.prenom
          @update_grappe_familiale.nom = @enfant.nom
        else
          @conjoint = Conjoint.find(params[:id])
          @update_grappe_familiale.conjoint_id = @conjoint.id
          @update_grappe_familiale.prenom = @conjoint.prenom
          @update_grappe_familiale.nom = @conjoint.nom
        end
      end
    
      def edit; end
    
      # POST /salarie/conjoints
  # POST /salarie/conjoints.json
  def create
    @etat = params[:etat]
    @type = params[:type]

    @update_grappe_familiale = UpdateGrappeFamiliale.new(update_grappe_familiale_params)

    @update_grappe_familiale.user = current_user
    @update_grappe_familiale.ajoute_par = current_user
    @update_grappe_familiale.num_affiliation = current_user.numero_salarie
    @update_grappe_familiale.date_soumission = DateTime.now

    if @etat == "divorce"
      @update_grappe_familiale.etat = :soumis
      @update_grappe_familiale.type_demande = :divorce
    else
      @update_grappe_familiale.etat = :soumis
      @update_grappe_familiale.type_demande = :deces
    end
    respond_to do |format|
      if @update_grappe_familiale.save!
        #record_history("Demande de mise à jour grappe familiale",  @update_grappe_familiale.etat) 
        format.html { redirect_to [:allocataire, @update_grappe_familiale], notice: 'La demande de mise à jour de la grappe a été bien créée.' }
        format.json { render :index, status: :created, location: @update_grappe_familiale }
      else
        format.html { render :new }
        format.json { render json: @update_grappe_familiale.errors, status: :unprocessable_entity }
      end
    end
  end
    
      def update
        if @update_grappe_familiale.update(deces_conjoint_params)
          redirect_to [:allocataire, @update_grappe_familiale], notice: 'Dossier prestation was successfully updated.'
        else
          render :edit
        end
      end
    
      def destroy
        @update_grappe_familiale.destroy
        redirect_to [:allocataire, @update_grappe_familiale], notice: 'Dossier prestation was successfully destroyed.'
      end
      def create_document
        @document_grappe_familiale = DocumentGrappeFamiliale.new(document_grappe_familiale_params)
        @document_grappe_familiale.deces_conjoint = @deces_conjoint
        @document_grappe_familiale.date_depot = Date.today
    
        if @document_grappe_familiale.save
          @update_grappe_familiale.document_valid!(false)
          redirect_to [:allocataire, @update_grappe_familiale], notice: 'Le document est ajouté.'
        else
          flash[:error] = "Une erreur est survenue lors de l'ajout du document."
          render :show
        end
      end
    
      def soumettre
        if @update_grappe_familiale.update(soumission_deces_conjoint_params.merge(etat: :soumis, date_soumission: Date.today))
          redirect_to [:allocataire, @update_grappe_familiale], notice: 'Le dossier de prestation est soumis !'
        else
          render :soumission_form
        end
      end
    
      def soumission_form; end
    
      private
    
      def set_grappe_familiale
        @update_grappe_familiale = UpdateGrappeFamiliale.find(params[:id] || params[:update_grappe_familiale_id])
      end
    
      # Never trust parameters from the scary internet, only allow the white list through.
      def update_grappe_familiale_params
        params.require(:update_grappe_familiale).permit(:num_affiliation, :prenom, :nom, :date_deces,
                                                        :lieu_deces, :etat, :adresse_domicile, :date_soumission,
                                                        :date_validation, :num_dossier, :conjoint_id, :enfant_id, :attachment)
      end
      def set_allocataire
        @allocataire = Allocataire.find_by_numero_allocataire(current_user.numero_salarie)
      end

      def set_etat
        params.require(:update_grappe_familiale).permit(:etat)
      end
    
      def soumission_deces_conjoint_params
        params.require(:update_grappe_familiale).permit(:condition_1, :condition_2, :condition_3)
      end
    
      def document_grappe_familiale_params
        params.require(:document_grappe_familiale).permit( :type_document, :document, :commentaire)
      end
    
      def peut_etre_edite!
        unless @update_grappe_familiale.creation?
          flash[:error] = "Vous ne pouvez pas éditer un dossier déjà soumis"
          redirect_to [:allocataire, @update_grappe_familiale]
        end
      end
    
      def can_add!
        unless current_user.can_add_dossier_prestation?
          flash[:error] = "Vous ne pouvez pas ajouter un nouveau dossier de prestation. Il y'a déjà un en cours"
          redirect_to allocataire_deces_conjoints_path
        end
      end
    end
    