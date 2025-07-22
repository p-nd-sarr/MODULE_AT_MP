class Admin::ModifierModePaiementsController < Admin::ApplicationController
  before_action :set_allocataire,except: [:mes_affectations,:toutes_les_demandes, :en_attente_soumission, :en_attente_verification,:en_attente_affectation,:en_attente_validation, :edit, :affectation_multiple, :en_attente_validation_agence, :toutes_les_demandes_en_agence]
  before_action :set_modifier_mode_paiement, except: [:index, :create, :new, :en_attente_soumission, :en_attente_verification, :en_attente_affectation,:en_attente_validation, :mes_affectations, :toutes_les_demandes, :affectation_multiple, :en_attente_validation_agence, :toutes_les_demandes_en_agence]
  
  def index
    @modifier_mode_paiements = @allocataire.modifier_mode_paiements
    @en_attente_soumissions = @modifier_mode_paiements.with_creation_state.page(params[:page]).per(100)
    @en_attentes_affectations = @modifier_mode_paiements.with_soumis_state.en_attente_affectation.page(params[:page]).per(100)
    @en_attentes_modif_soumis = @modifier_mode_paiements.with_soumis_state.where(affectation_allocataire: current_user.id)
    @en_attentes_validation_dossier = @modifier_mode_paiements.with_modif_soumis_state.page(params[:page]).per(100)
    @validees =  @modifier_mode_paiements.with_dossier_valide_state.page(params[:page]).per(100)
    @rejetees =  @modifier_mode_paiements.with_dossier_rejete_state.page(params[:page]).per(100)
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires allocataires
  end

  def toutes_les_demandes
    @q = ModifierModePaiement.all.ransack(params[:q])
    @total = @q.result.count
    @modifier_mode_paiements =  @q.result.order('created_at DESC')
    @modifier_mode_paiements = @modifier_mode_paiements.page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def en_attente_soumission
    @q = ModifierModePaiement.en_attente_soumission.where(ajoute_par: current_user.id).ransack(params[:q])
    @total = @q.result.count
    @modifier_mode_paiements =  @q.result.order('created_at DESC').page(params[:page]).per(100)
  end

  def en_attente_affectation
    @q = ModifierModePaiement.en_attente_affectation.ransack(params[:q])
    @total = @q.result.count
    @modifier_mode_paiements =  @q.result.order('created_at DESC').page(params[:page]).per(100)
  end

  def en_attente_verification
    @q = ModifierModePaiement.en_attente_verification.where(affectation_allocataire: current_user.id).ransack(params[:q])
    @total = @q.result.count
    @modifier_mode_paiements =  @q.result.order('created_at DESC').page(params[:page]).per(100)
  end

  def en_attente_validation
    @q = ModifierModePaiement.en_attente_validation.ransack(params[:q])
    @total = @q.result.count
    @modifier_mode_paiements =  @q.result.order('created_at DESC').page(params[:page]).per(100)
  end
  
  def en_attente_affectation_allocataire
    @q = ModifierModePaiement.en_attente_allocation.page(params[:page]).per(100).ransack(params[:q])
    @total = @q.result.count
    @modifier_mode_paiements =  @q.result.order('created_at DESC').page(params[:page]).per(100)

  end

  def mes_affectations
    @q = ModifierModePaiement.affectes_par(current_user.id).page(params[:page]).per(100).ransack(params[:q])
    @total = @q.result.count
    @modifier_mode_paiements =  @q.result.order('created_at DESC').page(params[:page]).per(100)
 
  end
  def toutes_les_demandes_en_agence
    @q = ModifierModePaiement.where(agence_creation: current_user.admin_agence).ransack(params[:q])
    @total = @q.result.count
    @modifier_mode_paiements =  @q.result.order('created_at DESC').page(params[:page]).per(100)
  end

  def en_attente_validation_agence
    @q = ModifierModePaiement.en_attente_validation_chef_agence.where(agence_creation: current_user.admin_agence).ransack(params[:q])
    @total = @q.result.count
    @modifier_mode_paiements =  @q.result.order('created_at DESC').page(params[:page]).per(100)
  end



  def show
    @gestionnaires = User.gestionnaire_compte_allocataire.where.not(id: @modifier_mode_paiement.ajoute_par.id) # avoir la liste des gestionnaires
  end

  def new
    @modifier_mode_paiement = ModifierModePaiement.new
  end


  def edit
    @allocataire = Allocataire.find_by_numero_allocataire(@modifier_mode_paiement.numero_allocataire)
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
        format.html { redirect_to [:admin, @allocataire, @modifier_mode_paiement], notice: ' Demande de changement de mode paiement a été avec succès.' }
        format.json { render :index, status: :created, location: @modifier_mode_paiement }
      else
        format.html { render :new }
        format.json { render json: @modifier_mode_paiement.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @modifier_mode_paiement.update(modifier_mode_paiement_params)
      redirect_to [:admin, @allocataire, @modifier_mode_paiement], notice: 'La demande de modification mode paiement est bien mise à jour.'
    else
      render :edit
    end
  end

  def valider_etat_civil_demandeur
    unless @modifier_mode_paiement.etat_civil_demandeur_valide!
      flash[:error] = "Error de validation"
    end
    redirect_to [:admin, @allocataire, @modifier_mode_paiement]
  end

  def valider_documents
    unless @modifier_mode_paiement.documents_valide!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:admin,@allocataire, @modifier_mode_paiement]
  end

  def soumettre
    if @modifier_mode_paiement.creation?
      @modifier_mode_paiement.est_soumis!
      @modifier_mode_paiement.date_soumission = DateTime.now
      @modifier_mode_paiement.soumis_par = current_user
      # @modifier_mode_paiement.traite_le = DateTime.now
      @modifier_mode_paiement.motif = nil
      @modifier_mode_paiement.save
      redirect_to [:admin, @allocataire, @modifier_mode_paiement], notice: 'La demande a été soumise avec succés'
    else
      redirect_to [:admin,@allocataire,  @modifier_mode_paiement]
    end

  end


  def soumettre_modification
    if @modifier_mode_paiement.soumis?
      @modifier_mode_paiement.est_modif_soumis!
      @modifier_mode_paiement.traite_par = current_user
      @modifier_mode_paiement.traite_le = DateTime.now
      @modifier_mode_paiement.motif = nil
      @modifier_mode_paiement.save
      redirect_to [:admin, @allocataire, @modifier_mode_paiement], notice: 'Les modification ont été soumises avec succés'
    else
      redirect_to [:admin,@allocataire,  @modifier_mode_paiement]
    end

  end

  def valider
    if @modifier_mode_paiement.modif_soumis?
     # @allocataire = Allocataire.find_by_numero_allocataire(@modifier_mode_paiement.numero_allocataire)
      @modifier_mode_paiement.est_dossier_valide!
      @modifier_mode_paiement.valider_par = current_user
      @modifier_mode_paiement.date_validation = DateTime.now
      if @modifier_mode_paiement.virement?
        saveChangementVirement(@allocataire, @modifier_mode_paiement)
      elsif @modifier_mode_paiement.mandant_postal?
        saveChangementMandat(@allocataire, @modifier_mode_paiement)
      elsif @modifier_mode_paiement.adresse_domicile?
        saveChangementDomicile(@allocataire, @modifier_mode_paiement)
      elsif @modifier_mode_paiement.caisse_ipres?
        saveChangementCaisse(@allocataire, @modifier_mode_paiement)
      else
        saveChangementModePaiement(@allocataire, @modifier_mode_paiement)
      end
      @modifier_mode_paiement.save
      redirect_to [:admin, @allocataire, @modifier_mode_paiement], notice: 'Les modification ont été validée avec succés'
    else
      redirect_to [:admin,@allocataire,  @modifier_mode_paiement]
    end
  end

  def affectation
    if @modifier_mode_paiement.update(modifier_mode_paiement_affecter_params.merge(affecte_par: current_user ,affectation_allocataire_date: DateTime.now))
      #record_history("Demande de modification d'adresse",  @modifier_mode_paiement.etat) 
      respond_to do |format|
        format.html { redirect_to [:admin, @allocataire, @modifier_mode_paiement], notice: 'La demande  a ete bien affectée.' }
        format.json { render :index, status: :created, location: @modifier_mode_paiement }
      end
    end
  end

  def retourner_process
    if @modifier_mode_paiement.soumis?
      @modifier_mode_paiement.update(soumis_par: nil,
                                date_soumission: nil)
      @modifier_mode_paiement.retour_creation!
    else
      if @modifier_mode_paiement.modif_soumis?
        @modifier_mode_paiement.update(traite_par: nil,
                                  traite_le: nil)
        @modifier_mode_paiement.retour_soumis!
      end
    end
    if @modifier_mode_paiement.update(modifier_mode_paiement_motifs_rejet_params.merge(traite_par: current_user,
                                                                           traite_le: DateTime.now))
      redirect_to [:admin, @allocataire, @modifier_mode_paiement], notice: 'Dossier a été retourné avec succés'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def destroy
    @modifier_mode_paiement.destroy
    respond_to do |format|
      format.html { redirect_to toutes_les_demandes_admin_modifier_mode_paiements_path, notice: 'Demande de modification mode paiement supprimée avec succés.' }
      format.json { head :no_content }
    end
  end

  def affectation_multiple
    update_selected(params[:at_ids],params[:user_id])
    respond_to do |format|
      format.html { redirect_to en_attente_affectation_admin_modifier_mode_paiements_path, notice: 'La selection a été bien affectée .'
     }
      format.json { head :no_content }
    end


  end
 
    


    private
    def modifier_mode_paiement_params
        params.require(:modifier_mode_paiement).permit(:mode_paiement,:adresse_domicile,
                                            :compte_bancaire_nom_banque, :date_debut_changement, :telephone, :numero_identification_nationale, 
                                            :date_debut_changement,:adresse_domicile, :admin_banque_agence_id,:compte_bancaire_cle_rib, :compte_bancaire_numero_compte,
                                            :rib, :attestation_non_engagement, :certificat_medical,:motif_virement,
                                            :mise_en_place_virement,:changement_de_banque, :changement_de_compte, :compte_bancaire_numero_compte2, :admin_agence_id)
    end
    
    def set_allocataire
      @allocataire = Allocataire.find(params[:allocataire_id] || params[:id])
    end

    def set_modifier_mode_paiement
        @modifier_mode_paiement = ModifierModePaiement.find(params[:id] || params[:modifier_mode_paiement_id])
    end
    def modifier_mode_paiement_affecter_params
        params.require(:modifier_mode_paiement).permit(:affectation_allocataire)
    end
    def modifier_mode_paiement_motifs_rejet_params
        params.require(:modifier_mode_paiement).permit(:motif)
    end

    def record_history(type_demande, etat)
      historique = Historique.new
      historique.evenement = type_demande
      historique.etat = etat
      historique.allocataire_id = @allocataire.id
      historique.user_id = current_user.id
      historique.save
    end

    def saveChangementVirement(allocataire, modifier_mode_paiement)
      logger.debug "Virement: #{@modifier_mode_paiement.attributes.inspect}"
      allocataire.mode_paiement = modifier_mode_paiement.mode_paiement
      allocataire.admin_banque_agence_id = modifier_mode_paiement.admin_banque_agence_id
      allocataire.compte_bancaire_cle_rib = modifier_mode_paiement.compte_bancaire_cle_rib
      allocataire.compte_bancaire_numero_compte = modifier_mode_paiement.compte_bancaire_numero_compte
      allocataire.save
    end

    def saveChangementMandat(allocataire, modifier_mode_paiement)
      allocataire.mode_paiement = modifier_mode_paiement.mode_paiement
      allocataire.adresse_rue = modifier_mode_paiement.adresse_domicile
      allocataire.numero_identification_nationale = modifier_mode_paiement.numero_identification_nationale
      allocataire.date_debut_changement = modifier_mode_paiement.date_debut_changement
      allocataire.telephone = modifier_mode_paiement.telephone
      allocataire.save
    end

    def saveChangementDomicile(allocataire, modifier_mode_paiement)
      allocataire.mode_paiement = modifier_mode_paiement.mode_paiement
      allocataire.adresse_domicile = modifier_mode_paiement.adresse_domicile
      allocataire.telephone = modifier_mode_paiement.telephone
      allocataire.save
    end

    def saveChangementCaisse(allocataire, modifier_mode_paiement)
      allocataire.mode_paiement = modifier_mode_paiement.mode_paiement
      allocataire.admin_agence_id = modifier_mode_paiement.admin_agence_id
      allocataire.save
    end

    def saveChangementModePaiement(allocataire, modifier_mode_paiement)
      logger.debug "ModePaiement: #{@modifier_mode_paiement.attributes.inspect}"
      allocataire.mode_paiement = modifier_mode_paiement.mode_paiement
      allocataire.telephone = modifier_mode_paiement.telephone unless modifier_mode_paiement.telephone.nil?
      allocataire.save
    end


    def update_selected(mp_selected, user)
      unless mp_selected.nil?
        mp_selected.each do |mp_id|
          mod_paiement = ModifierModePaiement.find(mp_id)
          mod_paiement.update(affectation_allocataire: user, affectation_allocataire_date: DateTime.now, affecte_par: current_user)
        
        end
      end
  
    end


    
end