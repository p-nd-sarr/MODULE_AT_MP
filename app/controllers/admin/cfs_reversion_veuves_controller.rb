class Admin::CfsReversionVeuvesController < Admin::ApplicationController
  before_action :set_cfs_reversion_veuve, except: [:index, :new, :create, :en_attente, :ajoutee, :carriere_en_attente, :recap_en_attente,
                                                     :affecter_allocataire_all, :affecter_salarie_all, :destroy_document, :en_attente_instruction,
                                                      :en_attente_affectation_salarie, :en_attente_validation_salaire,:en_attente_validation_carriere,
                                                      :en_attente_affectation_allocataire,:en_attente_validation_recap, :en_attente_validation_recap,
                                                      :recap_en_attente, :en_attente_validation_allocataire, :en_attente_validation]

  # GET /cfs_reversion_veuves
  # GET /cfs_reversion_veuves.json
  def index
    #@cfs_reversion_veuves = PrestationExtFrance.all
    @q = CfsReversionVeuve.all.ransack(params[:q])
    @cfs_reversion_veuves = @q.result.order('created_at DESC').page(params[:page]).per(100)
  end

  def en_attente
    if current_user.chef_section_instruction?
      @cfs_reversion_veuves = CfsReversionVeuve.where(workflow_state: :soumis).page(params[:page]).per(100)
    elsif current_user.chef_section_liquidation?
      @cfs_reversion_veuves = CfsReversionVeuve.en_attente_allocation.page(params[:page]).per(100)
    elsif current_user.gestionnaire_compte_allocataire?
      @cfs_reversion_veuves = CfsReversionVeuve.where(affectation_allocataire: current_user.id).can_affecte.page(params[:page]).per(100)
    elsif current_user.gestionnaire_compte_salarie?
      @cfs_reversion_veuves = CfsReversionVeuve.where(affectation_salarie: current_user.id).can_affecte.page(params[:page]).per(100)
    elsif current_user.chef_service_allocation?
      @cfs_reversion_veuves = CfsReversionVeuve.en_attente_allocation.page(params[:page]).per(100)
    elsif current_user.chef_service_cotisation?
      @cfs_reversion_veuves = CfsReversionVeuve.en_attente_cotisation.page(params[:page]).per(100)
    else
      @cfs_reversion_veuves = CfsReversionVeuve.with_soumis_state.page(params[:page]).per(100)
    end

    @cfs_reversion_veuves_en_attente = @cfs_reversion_veuves.en_attente.page(params[:page]).per(100)
    @gestionnaires = User.gestionnaire_allocataire # avoir la liste des gestionnaires allocataires
    @gestionnaires_salaries = User.gestionnaire_compte_salarie # avoir la liste des gestionnaires salaries
  end
  def en_attente_instruction
    @cfs_reversion_veuves = CfsReversionVeuve.en_attente_instruction.page(params[:page]).per(100)
  end

  def en_attente_affectation_salarie
    @cfs_reversion_veuves = CfsReversionVeuve.en_attente_salaire.page(params[:page]).per(100)
  end

  def en_attente_validation_salaire
    @cfs_reversion_veuves = CfsReversionVeuve.where(affectation_salarie: current_user.id).can_affecte.page(params[:page]).per(100)
  end

  def en_attente_validation_carriere
    @cfs_reversion_veuves = CfsReversionVeuve.with_carriere_soumis_state.page(params[:page]).per(100)
  end

  def en_attente_affectation_allocataire
    @cfs_reversion_veuves = CfsReversionVeuve.en_attente_allocation.page(params[:page]).per(100)
  end

  def en_attente_validation_allocataire
    @cfs_reversion_veuves = CfsReversionVeuve.where(affectation_allocataire: current_user.id).can_affecte.page(params[:page]).per(100)
  end

  def en_attente_validation_recap
    @cfs_reversion_veuves = CfsReversionVeuve.with_recap_soumis_state.page(params[:page]).per(100)
  end

  def en_attente_validation
    @cfs_reversion_veuves = CfsReversionVeuve.with_liquidation_valide_state.page(params[:page]).per(100)
  end

  def carriere_en_attente
    @cfs_reversion_veuves = CfsReversionVeuve.with_carriere_soumis_state.page(params[:page]).per(100)
  end

  def recap_en_attente
    @cfs_reversion_veuves = CfsReversionVeuve.with_recap_soumis_state.page(params[:page]).per(100)
  end

  def ajoutee
    @cfs_reversion_veuves = current_user.cfs_reversion_veuve_creees.page(params[:page]).per(100)
  end

  # GET /cfs_reversion_veuves/1
  # GET /cfs_reversion_veuves/1.json
  def show
    @enfants = Enfant.where(numero_affiliation: @cfs_reversion_veuve.numero_affiliation)
    @conjoints = Conjoint.where(numero_affiliation: @cfs_reversion_veuve.numero_affiliation)

    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires
    @gestionnaires_salaries = User.gestionnaire_compte_salarie # avoir la liste des gestionnaires

    # @carriere = Carriere.new
    # @employeur_ext = EmployeurExterieur.new
    # @carrieres_exterieures = CarrieresExterieure.new

    @carriere = Carriere.new
    @carrieres = Carriere.where(numero_affiliation: @cfs_reversion_veuve.numero_affiliation)
    @employeur_ext = EmployeurExterieur.new
    @employeur_exts = EmployeurExterieur.all
    @carrieres_exterieure = CarrieresExterieure.new
    @carrieres_exterieures = @cfs_reversion_veuve.carrieres_exterieures
    @periode_assurancePR = PeriodeAssurance.new
    @periode_assurances_PR = @cfs_reversion_veuve.periode_assurances.pays_residence
    @periode_assuranceSP = PeriodeAssurance.new
    @periode_assurances_SP = @cfs_reversion_veuve.periode_assurances.second_pays
  end

  def valider
    @cfs_reversion_veuve.valide!
    @cfs_reversion_veuve.traite_par = current_user
    @cfs_reversion_veuve.traite_le = DateTime.now
    @cfs_reversion_veuve.date_validation = Date.today
    @cfs_reversion_veuve.save
    flash[:notice] = 'Dossier validé avec succés.'
    redirect_to [:admin, @cfs_reversion_veuve]
  end

  def rejeter;

  end

  def rejeter_create
    if @cfs_reversion_veuve.update(cfs_reversion_veuve_rejet_params.merge(etat: :rejete,
                                                                              traite_par: current_user,
                                                                              traite_le: DateTime.now))
      redirect_to admin_cfs_reversion_veuves_path, notice: 'Dossier traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  # GET /cfs_reversion_veuves/new
  def new
    @cfs_reversion_veuve = CfsReversionVeuve.new
    #@cfs_reversion_veuve = PrestationExtFrance.new(numero_affiliation: params[:numero_affiliation])
  end

  # GET /cfs_reversion_veuves/1/edit
  def edit
    #edit
  end

  # POST /cfs_reversion_veuves
  # POST /cfs_reversion_veuves.json
  def create
    @cfs_reversion_veuve = CfsReversionVeuve.new(cfs_reversion_veuve_params)

    @cfs_reversion_veuve.ajoute_par = current_user
    #@dossier_prestation.etat = :creation
    if @cfs_reversion_veuve.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Le dossier de Prestation Extérieure/CFS est créé.'
    else
      render :new
    end

  end

  # PATCH/PUT /cfs_reversion_veuves/1
  # PATCH/PUT /cfs_reversion_veuves/1.json
  def update
    if @cfs_reversion_veuve.update(cfs_reversion_veuve_params)
      @cfs_reversion_veuve.etat_civil_demandeur_valide!(false)
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Le dossier est bien mis à jour.'
    else
      render :edit
    end
  end

  # DELETE /cfs_reversion_veuves/1
  # DELETE /cfs_reversion_veuves/1.json
  def destroy
    @cfs_reversion_veuve.destroy
    redirect_to admin_cfs_reversion_veuves_path, notice: 'Le dossier est supprimé.'
  end

  def retourner_process
    if @cfs_reversion_veuve.soumis?
      @cfs_reversion_veuve.update(traite_par: nil,
                                  traite_le: nil)
      @cfs_reversion_veuve.retour_creation!
    else
      if @cfs_reversion_veuve.instruit?
        @cfs_reversion_veuve.update(instruit_par: nil,
                                    instruit_le: nil)
        @cfs_reversion_veuve.retour_soumis!
      else
        if @cfs_reversion_veuve.carriere_soumis?
          @cfs_reversion_veuve.retour_instruit!
          @cfs_reversion_veuve.update(traite_par: nil,
                                      traite_le: nil)
        else
          if @cfs_reversion_veuve.cotisation_valide?
            @cfs_reversion_veuve.retour_carriere!
            @cfs_reversion_veuve.update(traite_par: nil,
                                        traite_le: nil)
          else
            if @cfs_reversion_veuve.recap_soumis?
              @cfs_reversion_veuve.retour_cotisation!
              @cfs_reversion_veuve.update(traite_par: nil,
                                          traite_le: nil)
            else
              if @cfs_reversion_veuve.prestation_valide?
                @cfs_reversion_veuve.retour_recap!
                @cfs_reversion_veuve.update(traite_par: nil,
                                            traite_le: nil)
              end
            end
          end
        end
      end
    end
    if @cfs_reversion_veuve.update(cfs_reversion_veuve_rejet_params.merge(traite_par: current_user,
                                                                           traite_le: DateTime.now))
      redirect_to admin_cfs_reversion_veuves_path, notice: 'Dossier de prestation traité.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def rejeter_ligne_carriere
    carriere_prestation = Carriere.find(params[:carriere_id])
    carriere_prestation.rejete!
    redirect_to [:admin, @cfs_reversion_veuve]
  end

  def show_facture
    @cfs_reversion_veuve = CfsReversionVeuve.find(params[:id] || params[:cfs_reversion_veuve_id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Récépissé Dossier PE/CFS No. #{@cfs_reversion_veuve.id}",
               page_size: 'A4',
               template: "admin/cfs_reversion_veuves/show_facture.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end


  # region : affecter une demande à un/des gestionnaire allocataire

  def affecter_allocataire
    #affecter une demande à un gestionnaire allocataire
    if @cfs_reversion_veuve.update(cfs_reversion_veuve_affecter_allocataire_params.merge(affectation_allocataire_date: DateTime.now))
      redirect_to admin_cfs_reversion_veuves_path, notice: 'Demande Affectée.'
    end
  end

  def affecter_allocataire_all

    if params["gestionnaires_ids"].nil?
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :en_attente
    else
      cfs_reversion_veuves = CfsReversionVeuve.en_attente_allocation
      gestionnaires_id = params["gestionnaires_ids"].split(",")

      unless gestionnaires_id.nil? and (not cfs_reversion_veuves.empty?)
        cfs_reversion_veuves.each do |cfs_reversion_veuve|
          cfs_reversion_veuve.affectation_allocataire = gestionnaires_id.sample
          cfs_reversion_veuve.affectation_allocataire_date = DateTime.now
          #cfs_reversion_veuve.etat = :traitement_en_cours
          cfs_reversion_veuve.save
        end
      end

      redirect_to admin_cfs_reversion_veuves_path, notice: 'Affectation effectuée avec succés'
    end
  end

  #endregion

  # region : affecter une demande à un/des gestionnaire salarie
  def affecter_salarie
    #affecter une demande à un gestionnaire allocataire
    @cfs_reversion_veuve.update(cfs_reversion_veuve_affecter_salarie_params.merge(affectation_salarie_date: DateTime.now))
    redirect_to admin_cfs_reversion_veuves_path, notice: 'Demande Affectée.'
  end

  def affecter_salarie_all
    if params["gestionnaires_ids"].nil?
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :en_attente
    else
      cfs_reversion_veuves = CfsReversionVeuve.en_attente_cotisation
      gestionnaires_id = params["gestionnaires_ids"].split(",")

      unless gestionnaires_id.nil?
        cfs_reversion_veuves.each do |cfs_reversion_veuve|
          cfs_reversion_veuve.affectation_salarie = gestionnaires_id.sample
          cfs_reversion_veuve.affectation_salarie_date = DateTime.now
          cfs_reversion_veuve.carriere_valide = true
          cfs_reversion_veuve.save
        end
      end
      redirect_to admin_cfs_reversion_veuves_path, notice: 'Affectation effectuée avec succés'
    end
  end

  def valider_ligne_carriere_ext
    carriere = CarrieresExterieure.find(params[:carrieres_exterieure_id])
    carriere.valide!
    redirect_to [:admin, @cfs_reversion_veuve], notice: 'ligne de carriere exterieure validée avec succés'
  end
  #endregion

  # region : valider toutes les infos du dossier
  def valider_etat_civil_demandeur
    @cfs_reversion_veuve.etat_civil_demandeur_valide!(true)
    redirect_to [:admin, @cfs_reversion_veuve]
  end

  def valider_grappe_familiale
    @cfs_reversion_veuve.grappe_fam_valide!
    redirect_to [:admin, @cfs_reversion_veuve]
  end

  def valider_epouses
    @cfs_reversion_veuve.valide_epouses!
    redirect_to [:admin, @cfs_reversion_veuve]
  end

  def valider_enfants
    @cfs_reversion_veuve.valide_enfants!
    redirect_to [:admin, @cfs_reversion_veuve]
  end

  def valider_assur_residence_valid
    @cfs_reversion_veuve.assur_residence_valide!
    redirect_to [:admin, @cfs_reversion_veuve]
  end

  def valider_assur_second_pays_valid
    @cfs_reversion_veuve.assur_second_pays_valide!
    redirect_to [:admin, @cfs_reversion_veuve]
  end

  def valider_activite_prof_valid
    if @cfs_reversion_veuve.instruit?
      @cfs_reversion_veuve.activite_prof_valide!
      if @cfs_reversion_veuve.est_carriere_soumis!
        redirect_to [:admin, @cfs_reversion_veuve], notice: 'Validation carrières avec succés!'
      else
        redirect_to [:admin, @cfs_reversion_veuve]
      end
    else
      redirect_to [:admin, @cfs_reversion_veuve]
    end
  end

  def valider_documents
    unless @cfs_reversion_veuve.document_valid!
      flash[:error] = "Veuillez déposer tous les documents requis avant la validation"
    end
    redirect_to [:admin, @cfs_reversion_veuve]
  end

  # endregion

  # region : valider carriere
  def valider_all_carrieres
    if @cfs_reversion_veuve.instruit?
      carrieres_prestation = @cfs_reversion_veuve.carrieres_prestation
      unless carrieres_prestation.nil?
        carrieres_prestation.each do |carriere|
          carriere.valide!
        end
      end
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Tous les points carrières validés avec succés!'
    else
      redirect_to [:admin, @cfs_reversion_veuve]
    end
  end

  def valider_ligne_carriere
    carriere_prestation = Carriere.find(params[:carriere_id])
    carriere_prestation.valide!
    redirect_to [:admin, @cfs_reversion_veuve]
  end

  # endregion


  # region : Workflow Validation DOSSIER 

  def soumettre
    if @cfs_reversion_veuve.creation?
      @cfs_reversion_veuve.est_soumis!
      @cfs_reversion_veuve.date_soumission = DateTime.now
      @cfs_reversion_veuve.traite_par = current_user
      @cfs_reversion_veuve.soumis_par = current_user
      @cfs_reversion_veuve.traite_le = DateTime.now
      @cfs_reversion_veuve.motif_rejet = nil
      @cfs_reversion_veuve.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Le dossier est soumis'
    else
      redirect_to [:admin, @cfs_reversion_veuve]
    end
  end

  def soumission_form;
  end


  def instruire
    if @cfs_reversion_veuve.soumis?
      @cfs_reversion_veuve.est_instruit!
      @cfs_reversion_veuve.instruit_par = current_user
      @cfs_reversion_veuve.instruit_le = DateTime.now
      @cfs_reversion_veuve.motif_rejet = nil
      @cfs_reversion_veuve.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Dossier Instruit'
    else
      redirect_to [:admin, @cfs_reversion_veuve]
    end
  end

  def carriere_valide
    @cfs_reversion_veuve.carriere_valide!
    @cfs_reversion_veuve.traite_par = current_user
    @cfs_reversion_veuve.traite_le = DateTime.now
    @cfs_reversion_veuve.save
    @cfs_reversion_veuve.traite_par = current_user
    @cfs_reversion_veuve.traite_le = DateTime.now
    @cfs_reversion_veuve.motif_rejet = nil
    @cfs_reversion_veuve.save
    flash[:notice] = 'Carrière soumis pour validation'
    redirect_to [:admin, @cfs_reversion_veuve]
  end

  def cotisation_valide
    if @cfs_reversion_veuve.cotisation_valide?
      redirect_to [:admin, @cfs_reversion_veuve]
    else
      @cfs_reversion_veuve.est_carriere_valide!
      @cfs_reversion_veuve.traite_par = current_user
      @cfs_reversion_veuve.traite_le = DateTime.now
      @cfs_reversion_veuve.motif_rejet = nil
      @cfs_reversion_veuve.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Carrière validée avec succés'

    end
  end

  def valider_recapitulatif
    if @cfs_reversion_veuve.cotisation_valide?
      @cfs_reversion_veuve.est_recap_soumis!
      @cfs_reversion_veuve.traite_par = current_user
      @cfs_reversion_veuve.traite_le = DateTime.now
      @cfs_reversion_veuve.motif_rejet = nil
      @cfs_reversion_veuve.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Recap soumis pour validation'
    else
      redirect_to [:admin, @cfs_reversion_veuve]
    end
  end

  def recap_valide
    if @cfs_reversion_veuve.cotisation_valide?
      redirect_to [:admin, @cfs_reversion_veuve]
    else
      @cfs_reversion_veuve.est_recap_valide!
      @cfs_reversion_veuve.traite_par = current_user
      @cfs_reversion_veuve.traite_le = DateTime.now
      @cfs_reversion_veuve.motif_rejet = nil
      @cfs_reversion_veuve.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Recap soumis pour validation'
    end
  end

  def liquidation_valide
    if @cfs_reversion_veuve.recap_soumis?
      @cfs_reversion_veuve.est_recap_valide!
      @cfs_reversion_veuve.traite_par = current_user
      @cfs_reversion_veuve.traite_le = DateTime.now
      @cfs_reversion_veuve.motif_rejet = nil
      @cfs_reversion_veuve.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Recap validée avec succés'
    else
      redirect_to [:admin, @cfs_reversion_veuve]
    end
  end

  def dossier_valide
    if @cfs_reversion_veuve.liquidation_valide?
      puts "========> dossier_valide"
      @cfs_reversion_veuve.est_dossier_valide!
      @cfs_reversion_veuve.valide_par = current_user
      @cfs_reversion_veuve.date_validation = DateTime.now
      @cfs_reversion_veuve.motif_rejet = nil
      @cfs_reversion_veuve.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @cfs_reversion_veuve]
    end
  end

  def dossier_rejet
    if @cfs_reversion_veuve.liquidation_valide?
      @cfs_reversion_veuve.traite_le = DateTime.now
      @cfs_reversion_veuve.traite_par = current_user
      @cfs_reversion_veuve.motif_rejet = nil
      @cfs_reversion_veuve.est_dossier_rejete!
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Dossier validé avec succés'
    else
      redirect_to [:admin, @cfs_reversion_veuve]
    end
  end

  # endregion


  def ajouter_carriere
    @carriere = Carriere.new(carriere_params)
    @carriere.numero_affiliation = @cfs_reversion_veuve.numero_affiliation
    @carriere.etat = :en_attente
    @carriere.salaire = @carriere.salaire1 + @carriere.salaire2

    if @carriere.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Carriere ajoutée.'
    else
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Erreur sur la création.'
    end
  end

  def ajouter_carrires_prest_exterieure
    @carriere = Carriere.new(carriere_params)
    @carriere.numero_affiliation = @cfs_reversion_veuve.numero_affiliation
    @carriere.etat = :en_attente
    @carriere.salaire = @carriere.salaire1 + @carriere.salaire2

    if @carriere.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Carriere ajoutée.'
    else
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Erreur sur la création.'
    end
  end

  def ajouter_periode_assurance_PR
    @periode_assurancePR = PeriodeAssurance.new(periode_assurance_params)
    @periode_assurancePR.cfs_reversion_veuve = @cfs_reversion_veuve
    # @periode_assurancePR.pays_residence!
    @periode_assurancePR.type_periode = :pays_residence
    # @periode_assurancePR.reversion!
    @periode_assurancePR.provenance = :reversion

    if @periode_assurancePR.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Période dans le pays de résidence ajoutée.'
    else
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Erreur sur la création.'
    end
  end

  def ajouter_periode_assurance_SP
    @periode_assuranceSP = PeriodeAssurance.new(periode_assurance_params)
    @periode_assuranceSP.cfs_reversion_veuve = @cfs_reversion_veuve
    @periode_assuranceSP.second_pays!
    @periode_assuranceSP.reversion!

    if @periode_assuranceSP.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Période dans le second pays ajoutée.'
    else
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Erreur à la création.'
    end
  end

  def destroy_periode_assurance
    @periode_assurance = PeriodeAssurance.find(params[:periode_assurance_id])
    @periode_assurance.destroy
    redirect_to [:admin, @cfs_reversion_veuve], notice: 'Suppression faite avec succès.'
  end

  def ajouter_employeur_ext
    @employeur = EmployeurExterieur.new(employeur_ext_params)
  

    if @employeur.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Employeur ajoutée.'
    else
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Erreur sur la création.'
    end
  end


  def ajouter_carrires_prest_exterieure
    @carriere_prest = CarrieresExterieure.new(carrieres_prest_exterieure_params)
    @carriere_prest.etat = :en_attente
    if @carriere_prest.save
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Carriere ajoutée.'
    else
      redirect_to [:admin, @cfs_reversion_veuve], notice: 'Erreur sur la création.'
    end
  end

  private

  def can_soumettre_operation
    unless current_user.can_allocataire? and current_user.admin_agence.id == @cfs_reversion_veuve.ajoute_par.admin_agence.id
      flash[:error] = "Vous ne pouvez pas valider ce dossier de prestation. Vous n'etes pas abilité."
      redirect_to admin_cfs_reversion_veuves_path
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_cfs_reversion_veuve
    #@cfs_reversion_veuve = PrestationExtFrance.find(params[:id])
    @cfs_reversion_veuve = CfsReversionVeuve.visible_for_admins.find(params[:id] || params[:cfs_reversion_veuve_id])
  rescue ActiveRecord::RecordNotFound => e
    @cfs_reversion_veuve = current_user.cfs_reversion_veuve_creees.find(params[:id] || params[:cfs_reversion_veuve_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cfs_reversion_veuve_params
    params.require(:cfs_reversion_veuve).permit(:sexe_salarie, :numero_affiliation, :prenom, :nom, :nom_jeune_fille, :date_naissance,
                                                  :lieu_naissance, :adresse_residence, :prenom_pere, :prenom_mere, :nom_pere, :nom_mere, :nationalite_id, :num_immatric_ipres,
                                                  :num_immatric_cfs, :situation_familiale, :date_mariage, :date_situation_fam, :date_ouverture_dossier, :nature, :inapte,
                                                  :date_depart_inapt, :date_decision_inapt, :titulaire_pens_invalidite, :titre_reg_gl, :titre_reg_agric, :titre_reg_minier,
                                                  :titre_reg_special, :institution_reg_spec, :num_pension_inapt, :date_cess_act_sn, :total_an_carr_sn, :date_cess_act_fr,
                                                  :total_an_carr_fr, :sens_convention, :type_retraite, :mode_paiement, :decide_points, :decide_montant_annuel, :decide_date,
                                                  :etat, :date_soumission, :email, :user_id, :type_piece, :motif_rejet, :numero_piece, :compte_bancaire_numero_compte,
                                                  :compte_bancaire_code_guichet, :compte_bancaire_code_banque, :compte_bancaire_nom_banque, :nom_defunt, :prenom_defunt,
                                                :numero_securite_sociale_defunt, :numero_securite_sociale_veuve, :adresse_postale)
  end


  def cfs_reversion_veuve_rejet_params
    params.require(:cfs_reversion_veuve).permit(:motif_rejet)
  end

  def cfs_reversion_veuve_affecter_allocataire_params
    params.require(:cfs_reversion_veuve).permit(:affectation_allocataire)
  end

  def cfs_reversion_veuve_affecter_salarie_params
    params.require(:cfs_reversion_veuve).permit(:affectation_salarie)
  end

  def carriere_params
    params.require(:carriere).permit(:date_entree, :date_sortie, :type_regime_id, :salaire, :ref_employeur, :exercice, :points, :salaire1, :salaire2, :motif)
  end
  def periode_assurance_params
    params.require(:periode_assurance).permit(:date_debut, :date_fin, :trimestre_assurance, :trimestre_equivalente, :type_periode)
  end

  def carrieres_prest_exterieure_params
    params.require(:carrieres_exterieure).permit(:cfs_reversion_veuve_id,:date_debut, :date_fin, :salaire, :employeur_exterieur_id, :type_regime_id, :salaire, :ref_employeur, :exercice, :points, :salaire1, :salaire2)
  end

  def employeur_ext_params
    params.require(:employeur_exterieur).permit(:prenom_employeur, :nom_employeur, :email, :adresse, :raison_sociale, :telephone)
  end


  def rejet(demande)
    return :creation if demande.soumis?
    return :soumis if demande.instruit?
    return :instruit if demande.carriere_valide?
    return :carriere_valide if demande.cotisation_valide?
    return :cotisation_valide if demande.recap_valide?
    return :recap_valide if demande.prestation_valide?
    return :liquidation_valide if demande.dossier_valide?
  end
end