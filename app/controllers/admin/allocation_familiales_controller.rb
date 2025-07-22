class Admin::AllocationFamilialesController < Admin::ApplicationController
  before_action :set_dossier_prestation, except: [:en_attente, :attente_validation, :valider, :rejeter, :rejeter_create, :index_all, :show, :attente_validation]
  before_action :set_allocation_familiale, except: [:index, :new, :create, :en_attente, :ajoutee, :index_all, :get_carrieres]
  # after_action :set_num_liquidation_genere, only: [:soumission_form]
  before_action :can_valide_operation, only: [:valider, :attente_validation]
  before_action :can_liquidate, only: [:soumettre]
  #after_action :set_num_liquidation_genere, only: [:soumettre]

  # GET /allocation_familiales
  # GET /allocation_familiales.json
  def index

    @q = @dossier_prestation.allocation_familiales.ransack(params[:q])
    @allocation_familiales = @q.result.order("annee, trimestre ASC").page(params[:page]).per(100)
    @enfantsEligibles = Enfant.where(numero_affiliation: @dossier_prestation.num_affiliation).eligible_allocation_familiale
  end

  def en_attente
    @allocation_familiales = AllocationFamiliale.en_attente.page(params[:page]).per(100)
  end

  def index_all
    @allocation_familiales = AllocationFamiliale.visible_for_admins.page(params[:page]).per(100)
  end

  def rejeter;

  end

  def rejeter_create
    if @allocation_familiale.update(allocation_familiale_rejet_params.merge(etat: :rejete,
                                                                            traite_par: current_user,
                                                                            traite_le: DateTime.now))
      redirect_to en_attente_admin_allocation_familiales_path, notice: 'Deamande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def retourner
    if current_user.chef_agence?
      @allocation_familiale.etat = :creation
    elsif current_user.comptable?
      @allocation_familiale.etat = :soumis
    end
    if @allocation_familiale.update(allocation_familiale_params.merge(retourne_par: current_user,
                                                                      date_retour: DateTime.now))
      redirect_to [:admin, @dossier_prestation, @allocation_familiale], notice: 'Allocation retournée avec succès !.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      redirect_to [:admin, @dossier_prestation, @allocation_familiale]
    end
  end

  def allocation_familiale_rejet_params
    params.require(:allocation_familiale).permit(:commentaire_rejet, :motif_rejet)
  end

  # GET /allocation_familiales/1
  # GET /allocation_familiales/1.json
  def show
    #@dossier_prestation = DossierPrestation.find(params[:id])
    @dossier_prestation = DossierPrestation.find(params[:dossier_prestation_id])
    @document_allocation_familiale = DocumentAllocatFamiliale.new
    @enfants = Enfant.where(numero_affiliation: @dossier_prestation.num_affiliation, id: @allocation_familiale.enfant)
  end

  # GET /allocation_familiales/new
  def new
    @allocation_familiale = AllocationFamiliale.new
  end

  # GET /allocation_familiales/1/edit
  def edit
    #edit
  end

  # POST /allocation_familiales
  # POST /allocation_familiales.json
  def create
    error = false
    @enfants = Enfant.where(numero_affiliation: @dossier_prestation.num_affiliation).eligible_allocation_familiale.eligible_plus

    @enfants.each do |enfant|
      @allocation_familiale = AllocationFamiliale.new(allocation_familiale_params)
      allocations = AllocationFamiliale.where(enfant_id: enfant.id).where(trimestre: @allocation_familiale.trimestre).where('extract(year from created_at) = ?', DateTime.now.year)
      if allocations.empty?
        @allocation_familiale.dossier_prestation = @dossier_prestation
        @allocation_familiale.ajoute_par = current_user
        @allocation_familiale.etat = :creation
        @allocation_familiale.enfant_id = enfant.id
        @allocation_familiale.date_ouverture_droit = Conjoint.where(numero_affiliation: @dossier_prestation.num_affiliation).premiere_date_mariage.pluck(:date_mariage).first

        unless @allocation_familiale.save
          error = true
          break
        end
      end
    end

    if error
      render :new
    else
      redirect_to [:admin, @dossier_prestation, @allocation_familiale], notice: 'Allocation familiale créé.'
    end
  end

  # PATCH/PUT /allocation_familiales/1
  # PATCH/PUT /allocation_familiales/1.json
  def update
    respond_to do |format|
      if @allocation_familiale.update(allocation_familiale_params)
        format.html { redirect_to [:admin, @dossier_prestation, @allocation_familiale], notice: 'Allocation familiale was successfully updated.' }
        format.json { render :show, status: :ok, location: @allocation_familiale }
      else
        format.html { render :edit }
        format.json { render json: @allocation_familiale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /allocation_familiales/1
  # DELETE /allocation_familiales/1.json
  def destroy
    @allocation_familiale.destroy
    respond_to do |format|
      format.html { redirect_to admin_dossier_prestation_allocation_familiales_path(@dossier_prestation), notice: 'Allocation familiale was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def valider_documents
    @allocation_familiale.document_valid!
    redirect_to [:admin, @dossier_prestation, @allocation_familiale]
  end

  def create_document
    @document_allocat_familiale = DocumentAllocatFamiliale.new(document_allocat_familiale_params)
    @document_allocat_familiale.allocation_familiale = @allocation_familiale
    @document_allocat_familiale.date_depot = Date.today

    if @document_allocat_familiale.save
      @allocation_familiale.document_valid!(false)
      redirect_to [:admin, @dossier_prestation, @allocation_familiale], notice: 'Le document est ajouté.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document."
      render :show
    end
  end

  def soumettre
    if @allocation_familiale.update(etat: :soumis, date_soumission: Date.today, date_liquidation: Date.today, soumis_par: current_user)
      @allocation_familiale.motif_retour = nil
      @allocation_familiale.retourne_par = nil
      @allocation_familiale.date_retour = nil
      if @allocation_familiale.montant_paiement.nil?
        @allocation_familiale.montant_paiement = @allocation_familiale.montant_a_payer
=begin
      else
        if @allocation_familiale.reinitialize_amount < @allocation_familiale.montant_paiement
          @allocation_familiale.montant_paiement = @allocation_familiale.reinitialize_amount
        end
=end
      end
      @allocation_familiale.save
      redirect_to admin_dossier_prestation_allocation_familiales_path(@dossier_prestation), notice: "La demande d'allocation est soumise."
    else
      flash[:error] = "Une erreur est survenue lors de la soumission : ", @allocation_familiale.errors.full_messages
      redirect_to admin_dossier_prestation_allocation_familiales_path(@dossier_prestation), notice: "La demande d'allocation est soumise."
    end
  end

  def can_soumettre
    if @allocation_familiale.dossier_prestation.pret_pour_soumission?
      flash[:error] = "Vous ne pouvez pas encore liquider cette allocation. Création dossier pas encore complet."
      redirect_to admin_dossier_prestation_allocation_familiale_path
    elsif current_user.admin_agence.id != @allocation_familiale.ajoute_par.admin_agence.id
      flash[:error] = "Vous ne pouvez pas soumettre cette prestation. Vous n'êtes pas abilité"
      redirect_to admin_dossier_prestation_allocation_familiale_path
    end
  end

  def soumission_form;
  end

  def calcul_montant

  end

  def valider
    if @allocation_familiale.dossier_prestation.valide? or @allocation_familiale.dossier_prestation.suspendu?
      @allocation_familiale.traite_par = current_user
      @allocation_familiale.traite_le = DateTime.now
      @allocation_familiale.date_validation = Date.today
      @allocation_familiale.valide!
      @allocation_familiale.save
      flash[:notice] = 'Prestation familiale validée.'
      redirect_to admin_dossier_prestation_allocation_familiales_path(@allocation_familiale.dossier_prestation)
    else
      flash[:error] = 'Vous devez valider le dossier avant de valider les allocations.'
      redirect_to admin_dossier_prestation_allocation_familiales_path(@allocation_familiale.dossier_prestation)
    end
  end

  def rejeter
    if @allocation_familiale.dossier_prestation.valide? or @allocation_familiale.dossier_prestation.suspendu?
      if @allocation_familiale.update(allocation_familiale_params)
        @allocation_familiale.traite_par = current_user
        @allocation_familiale.rejete_par = current_user
        @allocation_familiale.traite_le = DateTime.now
        @allocation_familiale.date_rejet = Date.today
        @allocation_familiale.rejete!
        @allocation_familiale.save
        flash[:notice] = 'Prestation familiale rejetée.'
        redirect_to admin_dossier_prestation_allocation_familiales_path(@allocation_familiale.dossier_prestation)
      end
    end
  end

  def attente_validation
    @allocation_familiale.valide!
    @allocation_familiale.traite_par = current_user
    @allocation_familiale.traite_le = DateTime.now
    @allocation_familiale.date_validation = Date.today
    @allocation_familiale.save
    flash[:notice] = 'Prestation familiale validée.'
    redirect_to allocation_en_attente_admin_dossier_prestations_path
  end

  def get_carrieres
    @carrieres = CarriereDossierPrestation.where(dossier_prestation_id: @dossier_prestation,annee: params[:annee]).order('trimestre asc')
  end

  private

  def set_num_liquidation_genere
    annee = Date.today.year
    if @allocation_familiale.numero_liquidation_generer.nil?
      @allocation_familiale.numero_liquidation_generer = params[:dossier_prestation_id] + "/" + params[:allocation_familiale_id] + "/" + "#{annee}/DOSSALFAM0001"
      @allocation_familiale.save
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_allocation_familiale
    @allocation_familiale = AllocationFamiliale.find(params[:id] || params[:allocation_familiale_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def allocation_familiale_params
    params.require(:allocation_familiale).permit(:debut_grossesse, :volet, :commentaire, :document, :trimestre, :annee, :enfant_id, :date_ouverture_droit, :commentaire_rejet, :motif_retour)
  end

  def set_dossier_prestation
    @dossier_prestation = DossierPrestation.find(params[:dossier_prestation_id])
  end

  def document_allocat_familiale_params
    params.require(:document_allocat_familiale).permit(:type_document, :document, :commentaire, :date_expiration_piece)
  end

  def soumission_allocation_familiale_params
    params.require(:allocation_familiale).permit(:condition_1, :condition_2)
  end

  def can_valide_operation
    migrated_allocation = @allocation_familiale.dossier_prestation.allocations_familiales_migrees.where.not(enfant_id: nil).find_by(annee: @allocation_familiale.annee, trimestre: @allocation_familiale.read_attribute_before_type_cast(:trimestre), enfant_id: @allocation_familiale.enfant.old_id)
    unless migrated_allocation.nil?
      flash[:error] = "Cette allocation a déjà été payée dans progress"
      redirect_to admin_dossier_prestation_allocation_familiales_path
      return
    end
    unless current_user.admin_agence.id == @allocation_familiale.ajoute_par.admin_agence.id
      flash[:error] = "Vous ne pouvez pas valider cette prestation. Vous n'est pas abilité."
      redirect_to admin_dossier_prestation_allocation_familiales_path
    end
  end

  def can_liquidate
    migrated_allocation = @allocation_familiale.dossier_prestation.allocations_familiales_migrees.where.not(enfant_id: nil).find_by(annee: @allocation_familiale.annee, trimestre: @allocation_familiale.read_attribute_before_type_cast(:trimestre), enfant_id: @allocation_familiale.enfant.old_id)
    unless migrated_allocation.nil?
      flash[:error] = "Cette allocation a déjà été payée dans progress"
      redirect_to admin_dossier_prestation_allocation_familiales_path
      return
    end
    if @allocation_familiale.after_hired_date?
      flash[:error] = "Cette allocation est postérieure à la date de fin de contrat"
      redirect_to admin_dossier_prestation_allocation_familiales_path
      return
    end
    if @allocation_familiale.echu? and !@allocation_familiale.get_reception_date.between?(@allocation_familiale.date_debut_validite, @allocation_familiale.date_fin_validite)
      flash[:error] = "Cette allocation est prescrite"
      redirect_to admin_dossier_prestation_allocation_familiales_path
      return
    end
    if !current_user.gestionnaire_compte_allocataire? or !@allocation_familiale.can_be_liquidate? or !@allocation_familiale.pret_pour_soumission?
      flash[:error] = "Vous ne pouvez pas soumettre cette allocation. Les conditions ne sont pas réunies!", @allocation_familiale.errors.full_messages
      redirect_to admin_dossier_prestation_allocation_familiales_path
    end
  end

end
