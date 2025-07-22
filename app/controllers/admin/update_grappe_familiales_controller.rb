class Admin::UpdateGrappeFamilialesController < Admin::ApplicationController
  before_action :set_update_grappe_familiale, only: [:show, :edit, :update, :destroy, :valider, :rejeter, :affectation]
  before_action :set_allocataire

  # GET /salarie/conjoints
  # GET /salarie/conjoints.json

  def index
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires allocataires
    @update_grappe_conjoints = UpdateGrappeFamiliale.all.where(num_affiliation: @allocataire.numero_allocataire).where.not("conjoint_id IS ?", nil)
    @update_grappe_enfants = UpdateGrappeFamiliale.all.where(num_affiliation: @allocataire.numero_allocataire).where.not("enfant_id IS ?", nil)
  end

  def list_grappe_familiale
    @conjoints = Conjoint.all.where(numero_affiliation: @allocataire.numero_allocataire)
    @enfants = Enfant.all.where(numero_affiliation: @allocataire.numero_allocataire)
  end

  def en_attente
    @conjoints = UpdateGrappeFamiliale.creation.page(params[:page]).per(100)
    render :index
  end

  # GET /salarie/conjoints/1
  # GET /salarie/conjoints/1.json
  def show
    #show
  end

  def valider
    @update_grappe_familiale.valide!
    @update_grappe_familiale.traite_par = current_user
    @update_grappe_familiale.traite_le = DateTime.now
    @update_grappe_familiale.date_validation = DateTime.now
    @update_grappe_familiale.save
    @conjoint = @update_grappe_familiale.conjoint
    @enfant = @update_grappe_familiale.enfant

    if @conjoint.nil?
      @enfant.deces!
      unless @enfant.allocataire_retraire.nil?
        # @enfant.allocataire_retraire.recalculer_points_majoration
        AllocataireSuiviModification.create(allocataire: @enfant.allocataire_retraire,
                                            commentaire: "Décès de l'enfant #{@enfant.full_name} ##{@enfant.id}",
                                            date_validation: DateTime.now,
                                            dossier_revision: @update_grappe_familiale,
                                            impacte_montant_paiement: true)
      end
    else
      if @update_grappe_familiale.divorce?
        @conjoint.divorce!
      else
        @conjoint.deces!
      end
    end

    flash[:notice] = 'Demande traitée'
    redirect_to admin_update_grappe_familiales_path
  end


  def valider_conjoint
    @update_grappe_familiale = UpdateGrappeFamiliale.find(params[:id] || params[:update_grappe_familiale_id])
    @conjoint = Conjoint.find(@update_grappe_familiale.conjoint_id)
    @update_grappe_familiale.traite_par = current_user
    @update_grappe_familiale.date_validation = DateTime.now
    @update_grappe_familiale.etat = :valide
    if @update_grappe_familiale.type_demande == "deces"
      @conjoint.etat = :deces
    else
      @conjoint.etat = :divorce
    end
    @conjoint.save
    if @update_grappe_familiale.save
      record_history("valider_update_grappe_conjoint", @update_grappe_familiale.etat)
      redirect_to admin_toutes_les_demandes_path, notice: 'Demande de modification validée.'
    end

  end

  def valider_enfant
    @update_grappe_familiale = UpdateGrappeFamiliale.find(params[:id] || params[:update_grappe_familiale_id])
    @enfant = Enfant.find(@update_grappe_familiale.enfant_id)
    @update_grappe_familiale.traite_par = current_user
    @update_grappe_familiale.date_validation = DateTime.now
    @update_grappe_familiale.etat = :valide
    @enfant.etat = :deces
    @enfant.save

    if @update_grappe_familiale.save
      record_history("valider_update_grappe_enfant", @update_grappe_familiale.etat)
      redirect_to admin_toutes_les_demandes_path, notice: 'Demande de modification validée.'
    end

  end


  def rejeter
    if @update_grappe_familiale.update(update_grappe_familiale_motifs_rejet_params.merge(traite_par: current_user,
                                                                                         traite_le: DateTime.now, etat: :rejete))
      record_history("Demande de mise à jour grappe familiale ", @update_grappe_familiale.etat)
      respond_to do |format|

        format.html { redirect_to [:admin, @allocataire, @update_grappe_familiale], notice: 'La demande de mise à jour grappe familiale ete bien rejetée.' }
        format.json { render :index, status: :created, location: @update_grappe_familiale }
      end
    end

  end

  def affectation
    if @update_grappe_familiale.update(update_grappe_familiale_affecter_params.merge(affectation_allocataire_date: DateTime.now, etat: :affecte))
      record_history("Demande mise à jour grappe familiale", @update_grappe_familiale.etat)
      respond_to do |format|

        format.html { redirect_to [:admin, @allocataire, @update_grappe_familiale], notice: 'La demande de mise à jour grappe fmiliale a été bien affectée.' }
        format.json { render :index, status: :created, location: @update_grappe_familiale }
      end
    end
  end

  # GET /salarie/conjoints/new
  def new
    @type = params[:type]
    @etat = params[:etat]
    @update_grappe_familiale = UpdateGrappeFamiliale.new
    @update_grappe_familiale.num_affiliation = @allocataire.numero_allocataire
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

  # GET /salarie/conjoints/1/edit
  def edit
    #edit
  end

  # POST /salarie/conjoints
  # POST /salarie/conjoints.json
  def create
    @etat = params[:etat]
    @type = params[:type]

    @update_grappe_familiale = UpdateGrappeFamiliale.new(update_grappe_familiale_params)

    @update_grappe_familiale.user = current_user
    @update_grappe_familiale.ajoute_par = current_user
    @update_grappe_familiale.num_affiliation = @allocataire.numero_allocataire
    @update_grappe_familiale.date_soumission = DateTime.now

    if @etat == "divorce"
      @update_grappe_familiale.etat = :soumis
      @update_grappe_familiale.type_demande = :divorce
    else
      @update_grappe_familiale.etat = :soumis
      @update_grappe_familiale.type_demande = :deces
    end
    respond_to do |format|
      if @update_grappe_familiale.save
        record_history("Demande de mise à jour grappe familiale", @update_grappe_familiale.etat)
        format.html { redirect_to [:admin, @allocataire, @update_grappe_familiale], notice: 'La demande de mise à jour de la grappe a été bien créée.' }
        format.json { render :index, status: :created, location: @update_grappe_familiale }
      else
        format.html { render :new }
        format.json { render json: @update_grappe_familiale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /salarie/conjoints/1
  # PATCH/PUT /salarie/conjoints/1.json
  def update
    if @update_grappe_familiale.update(conjoint_params)
      redirect_to [:admin, @update_grappe_familiale], notice: 'Conjoint was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /salarie/conjoints/1
  # DELETE /salarie/conjoints/1.json
  def destroy
    @update_grappe_familiale.destroy
    redirect_to admin_grappe_familiales_path, notice: 'Conjoint was successfully destroyed.'
  end


  private


  # Use callbacks to share common setup or constraints between actions.
  def set_update_grappe_familiale
    @update_grappe_familiale = UpdateGrappeFamiliale.find(params[:id] || params[:update_grappe_familiale_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def update_grappe_familiale_params
    params.require(:update_grappe_familiale).permit(:num_affiliation, :prenom, :nom, :date_deces,
                                                    :lieu_deces, :etat, :adresse_domicile, :date_soumission,
                                                    :date_validation, :num_dossier, :conjoint_id, :enfant_id, :attachment)
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id] || params[:id])
  end


  def record_history(type_demande, etat)
    historique = Historique.new
    historique.evenement = type_demande
    historique.etat = etat
    historique.allocataire_id = @allocataire.id
    historique.user_id = current_user.id
    historique.save
  end

  def update_grappe_familiale_affecter_params
    params.require(:update_grappe_familiale).permit(:affectation_allocataire)
  end

  def update_grappe_familiale_motifs_rejet_params
    params.require(:update_grappe_familiale).permit(:motif_rejet)
  end
end
