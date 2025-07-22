class Admin::ExtinctionAllocatairesController < Admin::ApplicationController
  before_action :set_allocataire,except: [:en_attente_soumission, :en_attente_verification,:en_attente_affectation,:en_attente_validation, :edit, :update, :destroy, :show]
  before_action :set_extinction_allocataire, only: [:show, :edit, :update, :destroy, :soumettre, :affecter, :valider,:rejeter,:verifier]

  def index
    @extinction_allocataires = ExtinctionAllocataire.all.where('numero_allocataire = ? or numero_allocataire = ?',
                                                               @allocataire.numero_allocataire,
                                                               @allocataire.ipres_ancien_matric)
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires
  end

  def edit
    @allocataire = @extinction_allocataire.allocataire
  end

  def en_attente_soumission
    @extinction_allocataires = ExtinctionAllocataire.en_attente_soumission.where(ajoute_par: current_user.id)
  end

  def en_attente_affectation
    @extinction_allocataires = ExtinctionAllocataire.en_attente_affectation
  end

  def en_attente_verification
    @extinction_allocataires = ExtinctionAllocataire.en_attente_verification.where(affectation_allocataire: current_user.id)
  end

  def en_attente_validation
    @extinction_allocataires = ExtinctionAllocataire.en_attente_validation
  end
  
  def en_attente_affectation_allocataire
    @extinction_allocataires = ExtinctionAllocataire.en_attente_allocation.page(params[:page]).per(100)
  end

  def show
    @allocataire = @extinction_allocataire.allocataire
    @gestionnaires = User.gestionnaire_compte_allocataire.where.not(id: @extinction_allocataire.ajoute_par.id) # avoir la liste des gestionnaires
  end

  def new
      @extinction_allocataire = ExtinctionAllocataire.new
  end

  def create

    @extinction_allocataire = ExtinctionAllocataire.new(extinction_allocataire_params)
    @extinction_allocataire.numero_allocataire = @allocataire.numero_allocataire
    @extinction_allocataire.ajoute_par = current_user
    @extinction_allocataire.date_soumission = DateTime.now
    @extinction_allocataire.etat = :soumis

    respond_to do |format|
      if @extinction_allocataire.save!
        record_history("Demande de extinction allocataire",  @extinction_allocataire.etat) 
        format.html { redirect_to [:admin, @allocataire, @extinction_allocataire], notice: 'La demande de extinction_allocataire  a été bien créée.' }
        format.json { render :index, status: :created, location: @extinction_allocataire }
      else
        format.html { render :new }
        format.json { render json: @extinction_allocataire.errors, status: :unprocessable_entity }
      end
    end
  end

  def soumettre
    if @extinction_allocataire.creation?
      @extinction_allocataire.est_soumis!
      @extinction_allocataire.date_soumission = DateTime.now
      @extinction_allocataire.ajoute_par = current_user
      @extinction_allocataire.save
      redirect_to [:admin, @allocataire, @extinction_allocataire], notice: 'La demande a été soumise avec succés'
    else
      redirect_to [:admin,@allocataire,  @extinction_allocataire]
    end
  end

  def update
    respond_to do |format|
      if @extinction_allocataire.update(extinction_allocataire_params)
        format.html { redirect_to [:admin, @extinction_allocataire], notice: 'La demande de regularisation pension was successfully updated.' }
        format.json { render :show, status: :ok, location: @extinction_allocataire }
      else
        format.html { render :edit }
        format.json { render json: @extinction_allocataire.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @extinction_allocataire.destroy
    respond_to do |format|
      format.html { redirect_to admin_allocataire_extinction_allocataires_path(@extinction_allocataire.allocataire), notice: "La demande d'extinction a été supprimeée." }
      format.json { head :no_content }
    end
  end


  def affecter
    if @extinction_allocataire.update(extinction_allocataire_affecter_params.merge(affectation_allocataire_date: DateTime.now))
      record_history("Demande rextinction_allocataire",  @extinction_allocataire.etat) 
        respond_to do |format|
         
             format.html { redirect_to [:admin, @allocataire, @extinction_allocataire], notice: 'La demande de extinction_allocataire a été bien affectée.' }
             format.json { render :index, status: :created, location: @extinction_allocataire }
        end
    end
  end

  def verifier
    if @extinction_allocataire.soumis?
      @extinction_allocataire.est_verifie!
      @extinction_allocataire.date_verification = DateTime.now
      @extinction_allocataire.verifie_par = current_user
      @extinction_allocataire.save
      redirect_to [:admin, @allocataire, @extinction_allocataire], notice: 'Verification extinction allocataire validée avec succés'
    else
      redirect_to [:admin,@allocataire,  @extinction_allocataire]
    end
  end


  def valider
  if @extinction_allocataire.verifie?
      @extinction_allocataire.valide_par = current_user
      @extinction_allocataire.date_validation = DateTime.now
      @allocataire.date_eteint =  DateTime.now
      @allocataire.date_deces =  @extinction_allocataire.date_deces
      @allocataire.etat=:eteint
      #@allocataire.motif_extinction = @extinction_allocataire.motif_extinction
      @extinction_allocataire.est_dossier_valide!
      @allocataire.save
      respond_to do |format|
        if @extinction_allocataire.save
          record_history("Demande extinction_allocataire", @extinction_allocataire.etat) 
          format.html { redirect_to admin_allocataire_extinction_allocataires_path(@allocataire), notice: 'La demande de extinction_allocataire a été validée.' }
          format.json { render :index, status: :created, location: @extinction_allocataire }
        else
          format.html { render :new }
          format.json { render json: @extinction_allocataire.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to [:admin,@allocataire,  @extinction_allocataire]
    end
  end
 

  def rejeter
    if @extinction_allocataire.update(sextinction_allocataire_rejeter_params.merge(traite_par: current_user,
      traite_le: DateTime.now, etat: :rejete))
      record_history("Demande extinction_allocataire de pension",  @extinction_allocataire.etat) 
        respond_to do |format|
          
          format.html { redirect_to admin_allocataire_extinction_allocataires_path(@allocataire), notice: 'La demande de regularisation pension a été bien rejetée.' }
          format.json { render :index, status: :created, location: @extinction_allocataire }
        end
    end

  end





  private
  def set_extinction_allocataire
    @extinction_allocataire = ExtinctionAllocataire.find(params[:id]|| params[:extinction_allocataire_id])
  end

  def extinction_allocataire_params
    params.require(:extinction_allocataire).permit(:numero_allocataire, :date_deces, :motif_extinction)
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id])
  end
  def extinction_allocataire_affecter_params
    params.require(:extinction_allocataire).permit(:affectation_allocataire)
  end
  def extinction_allocataire_rejeter_params
    params.require(:extinction_allocataire).permit(:motif_rejet)
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

