class Admin::SuspensionAllocatairesController < Admin::ApplicationController
  before_action :set_allocataire,except: [:en_attente_soumission, :en_attente_verification,:en_attente_affectation,:en_attente_validation]
  before_action :set_suspension_allocataire, only: [:show, :edit, :update, :destroy, :soumettre, :affecter, :valider, :regulariser,:rejeter,:verifier]

  def index
    @suspension_allocataires = SuspensionAllocataire.all.where(numero_allocataire: @allocataire.numero_allocataire)
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires
  end

  def en_attente_soumission
    @suspension_allocataires = SuspensionAllocataire.en_attente_soumission.where(ajoute_par: current_user.id)
  end
  def en_attente_affectation
    @suspension_allocataires = SuspensionAllocataire.en_attente_affectation
  end

  def en_attente_verification
    @suspension_allocataires = SuspensionAllocataire.en_attente_verification.where(affectation_allocataire: current_user.id)
  end

  def en_attente_validation
    @suspension_allocataires = SuspensionAllocataire.en_attente_validation
  end
  
  def en_attente_affectation_allocataire
    @suspension_allocataires = ModifierModePaiement.en_attente_allocation.page(params[:page]).per(100)
  end

  def show
    @gestionnaires = User.gestionnaire_compte_allocataire.where.not(id: @suspension_allocataire.ajoute_par.id) # avoir la liste des gestionnaires
  end

  def new
      @suspension_allocataire = SuspensionAllocataire.new
  end

  def create

    @suspension_allocataire = SuspensionAllocataire.new(suspension_allocataire_params)
    @suspension_allocataire.numero_allocataire = @allocataire.numero_allocataire
    @suspension_allocataire.ajoute_par = current_user
    @suspension_allocataire.prenom = @allocataire.prenom
    @suspension_allocataire.nom = @allocataire.nom
    @suspension_allocataire.date_soumission = DateTime.now
    @suspension_allocataire.etat = :soumis

    respond_to do |format|
      if @suspension_allocataire.save!
        record_history("Demande de suspension allocataire",  @suspension_allocataire.etat) 
        format.html { redirect_to [:admin, @allocataire, @suspension_allocataire], notice: 'La demande de suspension_allocataire  a été bien créée.' }
        format.json { render :index, status: :created, location: @suspension_allocataire }
      else
        format.html { render :new }
        format.json { render json: @suspension_allocataire.errors, status: :unprocessable_entity }
      end
    end
  end

  def soumettre
    if @suspension_allocataire.creation?
      @suspension_allocataire.est_soumis!
      @suspension_allocataire.date_soumission = DateTime.now
      @suspension_allocataire.ajoute_par = current_user
      @suspension_allocataire.save
      redirect_to [:admin, @allocataire, @suspension_allocataire], notice: 'La demande a été soumise avec succés'
    else
      redirect_to [:admin,@allocataire,  @suspension_allocataire]
    end
  end

  def update
    respond_to do |format|
      if @suspension_allocataire.update(suspension_allocataire)
        format.html { redirect_to [:admin, @allocataire, @suspension_allocataire], notice: 'La demande de regularisation pension was successfully updated.' }
        format.json { render :show, status: :ok, location: @suspension_allocataire }
      else
        format.html { render :edit }
        format.json { render json: @suspension_allocataire.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @suspension_allocataire.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @allocataire], notice: 'La demande de regularisation pension was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def affecter
    if @suspension_allocataire.update(suspension_allocataire_affecter_params.merge(affectation_allocataire_date: DateTime.now))
      record_history("Demande regularisation de pension",  @suspension_allocataire.etat) 
        respond_to do |format|
         
             format.html { redirect_to [:admin, @allocataire, @suspension_allocataire], notice: 'La demande de suspension a été bien affectée.' }
             format.json { render :index, status: :created, location: @suspension_allocataire }
        end
    end
  end

  def verifier
    if @suspension_allocataire.soumis?
      @suspension_allocataire.est_verifie!
      @suspension_allocataire.date_verification = DateTime.now
      @suspension_allocataire.verifie_par = current_user
      @suspension_allocataire.save
      redirect_to [:admin, @allocataire, @suspension_allocataire], notice: 'Verification suspension validée avec succés'
    else
      redirect_to [:admin,@allocataire,  @suspension_allocataire]
    end
  end


  def valider
  if @suspension_allocataire.verifie?
      @suspension_allocataire.est_dossier_valide!
      @suspension_allocataire.valide_par = current_user
      @suspension_allocataire.date_validation = DateTime.now
      @allocataire.date_suspension =  DateTime.now
      @allocataire.etat=:suspendus
      @allocataire.motif_suspension = @suspension_allocataire.motif_suspension
      @allocataire.save
      respond_to do |format|
        if @suspension_allocataire.save
          record_history("Demande suspension_allocataire",  @suspension_allocataire.etat) 
          format.html { redirect_to admin_allocataire_suspension_allocataires_path(@allocataire), notice: 'La demande de suspension_allocataire a été validée.' }
          format.json { render :index, status: :created, location: @suspension_allocataire }
        else
          format.html { render :new }
          format.json { render json: @suspension_allocataire.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to [:admin,@allocataire,  @suspension_allocataire]
    end
  end
 

  def rejeter
    if @suspension_allocataire.update(suspension_allocataire_rejeter_params.merge(traite_par: current_user,
      traite_le: DateTime.now, etat: :rejete))
      record_history("Demande suspension_allocataire de pension",  @suspension_allocataire.etat) 
        respond_to do |format|
          
          format.html { redirect_to admin_allocataire_suspension_allocataires_path(@allocataire), notice: 'La demande de regularisation pension a été bien rejetée.' }
          format.json { render :index, status: :created, location: @suspension_allocataire }
        end
    end

  end





  private
  def set_suspension_allocataire
    @suspension_allocataire = SuspensionAllocataire.find(params[:id]|| params[:suspension_allocataire_id])
  end

  def suspension_allocataire_params
    params.require(:suspension_allocataire).permit(:numero_allocataire, :prenom, :nom, :motif_suspension, :attachment)
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id])
  end
  def suspension_allocataire_affecter_params
    params.require(:suspension_allocataire).permit(:affectation_allocataire)
  end
  def suspension_allocataire_rejeter_params
    params.require(:suspension_allocataire).permit(:motif_rejet)
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

