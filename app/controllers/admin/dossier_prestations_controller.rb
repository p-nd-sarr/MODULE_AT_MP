class Admin::DossierPrestationsController < Admin::ApplicationController
  before_action :set_dossier_prestation, except: [:index, :new, :create, :en_attente, :allocation_en_attente, :ajoutee, :update_document, :recipisse_dossier, :historique_dossier, :valider_ordre, :generer_paiement, :valider_x_postnatales, :valider_x_paiement,
                                                  :create_allocataire_pf, :retour, :show_raison_social, :attente_validation_postnatale, :attente_validation_prenatale, :attente_validation_familiale, :anciens_dossiers, :nouveaux_dossiers, :clotures_requests, :attributaire_tierce_en_attente, :incomplete_dossiers]
  before_action :can_valide_operation, only: [:valider]
  before_action :can_soumettre_operation, only: [:soumettre]
  after_action :create_allocataire, only: [:valider]
  after_action :create_allocataire_pf, only: [:soumettre]
  after_action :rejeter_sous_dossiers, only: [:rejeter_create]
  before_action :can_validate_document_section, only: [:valider_documents]
  before_action :can_update_or_delete_tdp, only: [:delete_carriere, :update_document_tdp]
  before_action :can_update_or_delete_folder, only: [:destroy]
  # after_action :retour_sous_dossiers, only: [:retour_process]
  before_action :is_completion_possible?, only: [:set_complete]
  before_action :do_exist?, only: [:set_complete]
  before_action :can_regularize_widow?, only: [:initiate_widow_regularization]
  before_action :can_access_reg_widow, only: [:regularisation_widow_details]
  before_action :can_generate_allocation_for_individual, only: [:individual_regularisation_pay_child]
  before_action :can_generate_allocation_after_term, only: [:regularisation_after_term_pay_child]

  def index
    #@q = DossierPrestation.visible_for_admins.ransack(params[:q])
    @q = current_user.admin_agence.nil? ? DossierPrestation.list_dossier_allocataire.not_deleted.not_incomplete.ransack(params[:q]) : DossierPrestation.en_agence(current_user.admin_agence.id).list_dossier_allocataire.not_deleted.not_incomplete.ransack(params[:q])
    if params[:nin_conjoint]
      conjoint = Conjoint.find_by_numero_piece(params[:nin_conjoint])
      @q = conjoint.nil? ? DossierPrestation.none.ransack(params[:q]) : DossierPrestation.where(num_affiliation: conjoint.numero_affiliation).not_deleted.not_incomplete.ransack(params[:q])
    end
    @dossier_prestations = @q.result.order('created_at desc')
    @dossier_prestations = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def en_attente
    @q = DossierPrestation.en_agence(current_user.admin_agence.id).en_attente.not_deleted.not_incomplete.ransack(params[:q])
    if params[:nin_conjoint]
      conjoint = Conjoint.find_by_numero_piece(params[:nin_conjoint])
      @q = conjoint.nil? ? DossierPrestation.none.ransack(params[:q]) : DossierPrestation.en_attente.where(num_affiliation: conjoint.numero_affiliation).not_deleted.not_incomplete.ransack(params[:q])
    end
    @dossier_prestations = @q.result.page(params[:page]).per(100)
  end

  def attente_validation_postnatale
    @q = DossierPrestation.en_agence(current_user.admin_agence.id).est_valide.with_allocation_postanatale_soumis.not_deleted.not_incomplete.ransack(params[:q])
    if params[:nin_conjoint]
      conjoint = Conjoint.find_by_numero_piece(params[:nin_conjoint])
      @q = conjoint.nil? ? DossierPrestation.none.ransack(params[:q]) : DossierPrestation.with_allocation_postanatale_soumis.where(num_affiliation: conjoint.numero_affiliation).not_deleted.not_incomplete.ransack(params[:q])
    end
    @dossier_prestations_post = @q.result.order('created_at desc')
    @dossier_prestations_post = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def attente_validation_prenatale
    @dossier_prestations_pre = DossierPrestation.en_agence(current_user.admin_agence.id).with_allocation_prenatale_soumis.not_deleted.not_incomplete.page(params[:page]).per(100)
  end

  def attente_validation_familiale
    @q = DossierPrestation.en_agence(current_user.admin_agence.id).est_valide.with_allocation_familiale_soumis.not_deleted.not_incomplete.ransack(params[:q])
    if params[:nin_conjoint]
      conjoint = Conjoint.find_by_numero_piece(params[:nin_conjoint])
      @q = conjoint.nil? ? DossierPrestation.none.ransack(params[:q]) : DossierPrestation.with_allocation_familiale_soumis.where(num_affiliation: conjoint.numero_affiliation).not_deleted.not_incomplete.ransack(params[:q])
    end
    @dossier_prestations_fam = @q.result.order('created_at desc')
    @dossier_prestations_fam = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def allocation_en_attente
   @total_prenatale_en_attente = 0
   @total_postnatale_en_attente = 0
   @total_familiale_en_attente = 0
   @mes_dossiers_valides = DossierPrestation.en_agence(current_user.admin_agence.id).pret_pour_allocations_f.not_deleted.not_incomplete

   @mes_dossiers_valides.each do |dossier_prestation|
     dossier_prestation.allocation_prenatales.each do |prenatale|
       if prenatale.etat == "soumis"
         @total_prenatale_en_attente += 1
       end
     end
     dossier_prestation.allocation_postnatales.each do |postnatale|
       if postnatale.etat == "soumis"
         @total_postnatale_en_attente += 1
       end
     end
     if dossier_prestation.allocation_familiales.not_from_echeance.each do |familiale|
       if familiale.etat == "soumis"
         @total_familiale_en_attente += 1
       end
     end
     end
   end
  end

  def valider_ordre
    @dp_postnatales = DossierPrestation.with_allocation_postanatale_valide
    @dp_prenatales = DossierPrestation.with_allocation_prenatale_valide
    @dp_familiales = DossierPrestation.with_allocation_familiale_valide
    all_dp = (@dp_familiales + @dp_postnatales + @dp_prenatales)
    @dps = DossierPrestation.where(id: all_dp.map(&:id)).en_agence(current_user.admin_agence.id).est_valide
    @q = @dps.ransack(params[:q])
    if params[:nin_conjoint]
      conjoint = Conjoint.find_by_numero_piece(params[:nin_conjoint])
      @q = conjoint.nil? ? DossierPrestation.none.ransack(params[:q]) : @dps.where(num_affiliation: conjoint.numero_affiliation).ransack(params[:q])
    end
    @dossier_prestations = @q.result(distinct: true).order('created_at DESC').page(params[:page]).per(100)
  end

  def ajoutee
    @dossier_prestations = current_user.dossier_prestation_crees.not_deleted.not_incomplete.page(params[:page]).per(100)
  end

  def anciens_dossiers
    @q = DossierPrestation.en_agence(current_user.admin_agence.id).list_dossier_allocataire.where(est_repris: true).not_deleted.not_incomplete.ransack(params[:q])
    @dossier_prestations = @q.result.order('created_at desc')
    @dossier_prestations = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def nouveaux_dossiers
    @q = DossierPrestation.en_agence(current_user.admin_agence.id).list_dossier_allocataire.where(est_repris: false).not_deleted.not_incomplete.ransack(params[:q])
    @dossier_prestations = @q.result.order('created_at desc')
    @dossier_prestations = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def incomplete_dossiers
    @q = DossierPrestation.en_agence(current_user.admin_agence.id).list_dossier_allocataire.where(est_repris: true, incomplete: true).not_deleted.ransack(params[:q])
    if params[:nin_conjoint]
      conjoint = Conjoint.find_by_numero_piece(params[:nin_conjoint])
      @q = conjoint.nil? ? DossierPrestation.none.ransack(params[:q]) : DossierPrestation.where(num_affiliation: conjoint.numero_affiliation, incomplete: true).not_deleted.ransack(params[:q])
    end
    @dossier_prestations = @q.result.order('created_at desc')
    @dossier_prestations = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def valider
    @dossier_prestation.etat = :valide
    @dossier_prestation.traite_par = current_user
    @dossier_prestation.traite_le = DateTime.now
    @dossier_prestation.date_validation = Date.today
    @dossier_prestation.save
    flash[:notice] = 'Dossier validé avec succés.'
    redirect_to [:admin, @dossier_prestation]
  end

  def rejeter; end

  def rejeter_sous_dossiers
    dossier_avec_conjoints = DossierPrestation.where(num_affiliation: @dossier_prestation.num_affiliation).where.not(conjoint_id: nil)
    dossier_avec_conjoints.each { |dossier_avec_conjoint|
      dossier_avec_conjoint.etat = :rejete
      dossier_avec_conjoint.motif_rejet = "Rejet dossier allocataire"
      dossier_avec_conjoint.save
    }
  end

  def rejeter_create
    if @dossier_prestation.update(dossier_prestation_rejet_params.merge(etat: :rejete,
                                                                        traite_par: current_user,
                                                                        traite_le: DateTime.now))
      redirect_to admin_dossier_prestations_path, notice: 'Demande traitée.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      render :rejeter
    end
  end

  def dossier_prestation_rejet_params
    params.require(:dossier_prestation).permit(:motif_rejet)
  end

  def dossier_prestation_retour_params
    params.require(:dossier_prestation).permit(:motif_retour)
  end


  # GET /dossier_prestations/1
  # GET /dossier_prestations/1.json
  def show
    if @dossier_prestation.deleted? or @dossier_prestation.incomplete?
      redirect_to admin_dossier_prestations_path, notice: 'Dossier incomplet ou supprimé.'
    end
    @document_dossier_prestation = DocumentDossierPrestation.new
    @carriere_dossier_prestation = CarriereDossierPrestation.new
    @agents = User.users_for_type('gestionnaire_compte_allocataire').en_agence(current_user.agence_id)
    @attributaire_tierce = AttributaireTierce.new

    @transactions = @dossier_prestation.compta_transactions.includes(:ordre_paiement).order("created_at DESC")
    @payment_orders = @dossier_prestation.ordre_paiements.includes(:compta_transactions).order("created_at DESC").page(params[:page]).per(10)

    #@paiements = PaiementAllocataire.where(numero_allocataire: @dossier_prestation.num_affiliation).order("created_at DESC").page(params[:page]).per(10)
    @temps_de_presences = CarriereDossierPrestation.where(dossier_prestation_id: params[:id]).order("annee DESC")
    @beneficiary = Conjoint.where(numero_affiliation: @dossier_prestation.num_affiliation, est_af_beneficiaire: true).first

    @ref_employeur = CarriereDossierPrestation.where(id: params[:id])
    if @dossier_prestation.conjoint.nil?
      @enfants = Enfant.where(numero_affiliation: @dossier_prestation.num_affiliation).not_deleted.not_incomplete
      @conjoints = Conjoint.where(numero_affiliation: @dossier_prestation.num_affiliation).not_deleted.not_incomplete
    else
      @enfants = Enfant.where(conjoint_id: @dossier_prestation.conjoint.id).not_deleted.not_incomplete
      @conjoints = @dossier_prestation.conjoint
    end

    @beneficiary_association = BeneficiaryAssociationsToDp.new
    @beneficiary_associations = @dossier_prestation.beneficiary_associations_to_dps.map { |beneficiary| beneficiary }.group_by { |x| x.type_beneficiary }

    @q = @dossier_prestation.allocations_familiales_migrees.ransack(params[:q])
    @allocations_familiales_migrees = @q.result.includes(:enfant).page(params[:page]).per(100)

    @q = @dossier_prestation.allocations_prenatales_migrees.ransack(params[:q])
    @allocations_prenatales_migrees = @q.result.includes(:conjoint).page(params[:page]).per(100)

    @q = @dossier_prestation.allocations_postnatales_migrees.ransack(params[:q])
    @allocations_postnatales_migrees = @q.result.includes(:conjoint, :enfant).page(params[:page]).per(100)

    @cloture_request = DemandePfCloture.new
  end

  # GET /dossier_prestations/new
  def new
    @dossier_prestation = DossierPrestation.new(num_affiliation: params[:num_affiliation])
  end

  # GET /dossier_prestations/1/edit
  def edit
    #edit
  end

  def edit_specially

  end

  def edit_incomplete
  end

  def update_specially
    if @dossier_prestation.update(dossier_prestation_params)
      redirect_to [:admin, @dossier_prestation], notice: 'La modification a été effectuée avec succès.'
    else
      render :'edit_specially'
    end
  end

  def update_incomplete
    if @dossier_prestation.update(dossier_prestation_params)
      redirect_to admin_dossier_prestation_edit_incomplete_path(@dossier_prestation), notice: 'Dossier was successfully updated.'
    else
      render :edit_incomplete
    end
  end

  def set_complete
    @dossier_prestation.turn_to_complete!
    redirect_to admin_dossier_prestation_edit_incomplete_path(@dossier_prestation), notice: 'Dossier validé avec succès.'
  end

  def search
    if params[:search].blank?
      redirect_to admin_dossier_prestations_path
    else
      @parameter = params[:search].downcase
      @results = DossierPrestation.all.where("lower(name) LIKE :search", search: @parameter)
    end
  end

  # POST /dossier_prestations
  # POST /dossier_prestations.json
  def create
    @dossier_prestation = DossierPrestation.new(dossier_prestation_params)
    @dossier_prestation.ajoute_par = current_user
    @dossier_prestation.etat = :creation
    @dossier_prestation.traite_par = current_user
    @dossier_prestation.traite_le = DateTime.now
    @dossier_prestation.date_validation = Date.today
    @dossier_prestation.date_ouverture = @dossier_prestation.set_date_ouverture_droit
    @dossier_prestation.admin_agence = current_user.admin_agence

=begin
    premiere_mariage = Conjoint.premiere_date_mariage.where(numero_affiliation: @dossier_prestation.num_affiliation).pluck(:date_mariage).first
    #date d'ouverture date de reception -1 ans
    unless @dossier_prestation.date_reception.nil?
      if not premiere_mariage.nil? and not @dossier_prestation.date_embauche.nil?
        @dossier_prestation.date_ouverture = [@dossier_prestation.date_reception.last_year.to_date, premiere_mariage.to_date, @dossier_prestation.date_embauche.to_date].max
      elsif premiere_mariage.nil? and not @dossier_prestation.date_embauche.nil?
        @dossier_prestation.date_ouverture = [@dossier_prestation.date_reception.last_year.to_date, @dossier_prestation.date_embauche.to_date].max
      elsif @dossier_prestation.date_embauche.nil? and not premiere_mariage.nil?
        @dossier_prestation.date_ouverture = [@dossier_prestation.date_reception.last_year.to_date, premiere_mariage.to_date].max
      else
        @dossier_prestation.date_ouverture = @dossier_prestation.date_reception.last_year.to_date
      end
    end
=end

    if @dossier_prestation.save
      redirect_to [:admin, @dossier_prestation], notice: 'Le dossier est créé.'
    else
      render :new
    end
  end

  def create_dossier_conjoint
    @new_dossier_prestation = DossierPrestation.new
    @new_dossier_prestation.num_affiliation = @dossier_prestation.num_affiliation
    @new_dossier_prestation.conjoint_id = params[:conjoint_id]
    @new_dossier_prestation.nom = @dossier_prestation.nom
    @new_dossier_prestation.nin = @dossier_prestation.nin
    @new_dossier_prestation.prenom = @dossier_prestation.prenom
    @new_dossier_prestation.sexe_salarie = @dossier_prestation.sexe_salarie
    @new_dossier_prestation.date_naissance = @dossier_prestation.date_naissance
    @new_dossier_prestation.lieu_naissance = @dossier_prestation.lieu_naissance
    @new_dossier_prestation.telephone = @dossier_prestation.telephone
    @new_dossier_prestation.adresse_domicile = @dossier_prestation.adresse_domicile
    @new_dossier_prestation.date_reception = @dossier_prestation.est_repris ? @dossier_prestation.date_ouverture : @dossier_prestation.date_reception
    @new_dossier_prestation.ajoute_par = current_user
    @new_dossier_prestation.etat = :valide
    @new_dossier_prestation.etat_civil_demandeur_valid = true
    @new_dossier_prestation.carriere_valid = true
    @new_dossier_prestation.enfants_valid = true
    @new_dossier_prestation.document_valid = true
    @new_dossier_prestation.date_embauche = @dossier_prestation.date_embauche
    @new_dossier_prestation.employeur_actuel = @dossier_prestation.employeur_actuel
    @new_dossier_prestation.date_ouverture = @dossier_prestation.est_repris ? @dossier_prestation.date_ouverture : @dossier_prestation.set_date_ouverture_droit
    @new_dossier_prestation.admin_agence = @dossier_prestation.admin_agence

    if @new_dossier_prestation.save
      redirect_to admin_dossier_prestation_path(@new_dossier_prestation), notice: "Le dossier a été crée avec succès"
    else
      error_message = @new_dossier_prestation.errors.full_messages
      flash[:error] = "Une erreur est survenue lors de la création", error_message
      redirect_to admin_dossier_prestation_path(@dossier_prestation)
    end

  end

  def list_dossier_conjoint
    if (@dossier_prestation.conjoint.nil?)
      @enfants = Enfant.where(numero_affiliation: @dossier_prestation.num_affiliation)
      @conjoints = Conjoint.where(numero_affiliation: @dossier_prestation.num_affiliation).where.not(etat_conjoint: :deceder)
    else
      @enfants = Enfant.where(conjoint_id: @dossier_prestation.conjoint.id)
      @conjoints = @dossier_prestation.conjoint
    end
  end

  def all_regularisation
  end

  def individual_regularisation_af
    @q = @dossier_prestation.carriere_dossier_prestations.where(echeance_caisse_id: nil).order(created_at: :desc).ransack(params[:q])
    @time_of_presence = @q.result.select { |x| x.is_expired_tdp }
  end

  def individual_regularisation_af_details
    @annee = params[:annee].to_i
    @trimestre = CarriereDossierPrestation.trimestres[params[:trimestre]].to_i
    period = set_period_for_allocation_f(@trimestre, @annee)
    @enfants = @dossier_prestation.enfants.eligible_for_alloc_familiale(period, @dossier_prestation.num_affiliation)
  end

  def individual_regularisation_pay_child
    @enfant = Enfant.find(params[:enfant_id])
    @trimestre = params[:trimestre].to_i
    @annee = params[:annee].to_i
    @dossier_prestation.individual_regularisation_generate_allocation(@enfant, @trimestre, @annee)
    @trimestre = 'trimestre' + @trimestre.to_s
    redirect_to admin_dossier_prestation_individual_regularisation_af_details_path(@dossier_prestation, @trimestre, @annee), notice: 'Allocation générée avec succès.'
  end

  def regularisation_after_term
    @q = EcheanceCaisse.joins(echeance_caisse_employeurs: :echeance_caisse_dossiers).where(echeance_caisse_dossiers: { num_affiliation: @dossier_prestation.num_affiliation }).ransack(params[:q])
    @echeances = @q.result.order('created_at DESC').page(params[:page]).per(10)
  end

  def regularisation_after_term_details
    @echeance = EcheanceCaisse.where(trimestre: params[:trimestre], annee: params[:annee]).first
    period = set_period_for_allocation_f(@echeance.trimestre, @echeance.annee)
    @echeance_dossier = @dossier_prestation.echeance_caisse_dossiers.where(echeance_caisse_id: @echeance.id, num_affiliation: @dossier_prestation.num_affiliation).first
    @echeance_enfants = @echeance_dossier.echeance_caisse_enfants
    @paid_echeance_amount = @echeance_dossier.get_total_amount
    @allocations = @dossier_prestation.allocation_familiales.where(trimestre: @echeance.trimestre, annee: @echeance.annee).where.not(enfant_id: @echeance_enfants.pluck(:enfant_id).uniq)
    @allocations_amount = @allocations.sum(:montant_paiement)
    @nbr_month_left = @echeance_enfants.length + (@allocations.length * 3) < 18 ? 18 - (@echeance_enfants.length + (@allocations.length * 3)) : 0
    @nbr_month_left = @nbr_month_left - ((@nbr_month_left / 3) * @echeance_dossier.get_excluded_months_by_child) unless @echeance_dossier.get_excluded_months_by_child.nil?
    @payable_amount = @nbr_month_left * 2600
    @enfants = @dossier_prestation.enfants.eligible_for_alloc_familiale(period, @dossier_prestation.num_affiliation).where.not(id: @echeance_dossier.echeance_caisse_enfants.pluck(:enfant_id))
  end

  def regularisation_after_term_pay_child
    @enfant = Enfant.find(params[:enfant_id])
    @nbr_month_left = params[:nbr_month_left].to_i
    @trimestre = params[:trimestre]
    @annee = params[:annee]
    @echeance_dossier_id = params[:echeance_dossier_id]

    begin
      @dossier_prestation.generate_allocation(@enfant, @nbr_month_left, @trimestre, @annee, @echeance_dossier_id)
      redirect_to admin_dossier_prestation_regularisation_after_term_details_path(@dossier_prestation, @trimestre, @annee), notice: 'Allocation générée avec succès.'
    rescue ActiveRecord::RecordInvalid => e
      # En cas d'erreur de validation, ajouter un message d'alerte
      flash[:alert] = "Erreur lors de la génération de l'allocation : #{e.message}"
      redirect_to admin_dossier_prestation_regularisation_after_term_details_path(@dossier_prestation, @trimestre, @annee)
    rescue => e
      # En cas d'autres erreurs, les afficher également
      flash[:alert] = "Une erreur est survenue : #{e.message}"
      redirect_to admin_dossier_prestation_regularisation_after_term_details_path(@dossier_prestation, @trimestre, @annee)
    end
  end

  def regularisation_widow
    death_salary = DecesSalarie.find_by(numero_affiliation: @dossier_prestation.num_affiliation)
    @q = EcheanceVeuvesCaisse.where('periode_debut > ?', death_salary.date_deces).ransack(params[:q])
    @echeances = @q.result.order('created_at DESC').page(params[:page]).per(10)
  end

  def initiate_widow_regularization
    @trimestre = params[:trimestre].to_i
    @annee = params[:annee].to_i
    death_salary = DecesSalarie.find_by(numero_affiliation: @dossier_prestation.num_affiliation)
    @maintien_prestation = MaintienPrestation.new
    @maintien_prestation.dossier_prestation = @dossier_prestation
    @maintien_prestation.type_maintien = MaintienPrestation.type_maintiens[:deces]
    @maintien_prestation.commentaire = 'Maintien des prestations suité au décès du salarié'
    @maintien_prestation.date_effective = death_salary.date_deces
    @maintien_prestation.date_demande_maintien = Date.today
    @maintien_prestation.date_arret_maintien = @dossier_prestation.get_date_arret_maintien(@maintien_prestation)

    if @maintien_prestation.save
      redirect_to admin_dossier_prestation_regularisation_widow_details_path(@dossier_prestation, @trimestre, @annee), notice: 'Initialisation de la régularisation effectuée avec succès.'
    else
      flash[:error] = "Erreur lors de l'initialisation!.", @maintien_prestation.errors.full_messages
      redirect_to admin_dossier_prestation_regularisation_widow_details_path(@dossier_prestation, @trimestre, @annee)
    end
  end

  def regularisation_widow_details
    @echeance = EcheanceVeuvesCaisse.where(trimestre: params[:trimestre], annee: params[:annee]).first
    period = set_period_for_allocation_f(@echeance.trimestre, @echeance.annee)
    @echeance_enfants = @echeance.echeance_veuves_caisse_enfants.where(dossier_prestation_id: @dossier_prestation.id)
    @paid_echeance_amount = @echeance_enfants.sum(:montant)
    @allocations = @dossier_prestation.allocation_familiales.where(trimestre: @echeance.trimestre, annee: @echeance.annee).where.not(enfant_id: @echeance_enfants.pluck(:enfant_id).uniq)
    @allocations_amount = @allocations.sum(:montant_paiement)
    @nbr_month_left = @echeance_enfants.length + (@allocations.length * 3) < 18 ? 18 - (@echeance_enfants.length + (@allocations.length * 3)) : 0
    @payable_amount = @nbr_month_left * 2600
    @enfants = @dossier_prestation.enfants.eligible_for_alloc_familiale(period, @dossier_prestation.num_affiliation).where.not(id: @echeance_enfants.pluck(:enfant_id))
  end

  def regularisation_widow_pay_child
    @enfant = Enfant.find(params[:enfant_id])
    @nbr_month_left = params[:nbr_month_left].to_i
    @trimestre = params[:trimestre]
    @annee = params[:annee]
    @dossier_prestation.generate_allocation(@enfant, @nbr_month_left, @trimestre, @annee)
    redirect_to admin_dossier_prestation_regularisation_widow_details_path(@dossier_prestation, @trimestre, @annee), notice: 'Allocation générée avec succès.'
  end

  # PATCH/PUT /dossier_prestations/1
  # PATCH/PUT /dossier_prestations/1.json
  def update
    if @dossier_prestation.update(dossier_prestation_params)
      @dossier_prestation.date_ouverture = @dossier_prestation.set_date_ouverture_droit
      @dossier_prestation.etat_civil_demandeur_valid!(false)
      redirect_to [:admin, @dossier_prestation], notice: 'La demande de liquidation est bien mise à jour.'
    else
      render :edit
    end
  end

  # DELETE /dossier_prestations/1
  # DELETE /dossier_prestations/1.json
  def destroy
    @dossier_prestation.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @dossier_prestation], notice: 'Dossier prestation est supprimée.' }
      format.json { head :no_content }
    end
  end

  def valider_etat_civil_demandeur
    if @dossier_prestation.etat_civil_demandeur_valid!
      redirect_to [:admin, @dossier_prestation], notice: 'Section validée avec succès.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document.", @dossier_prestation.errors.full_messages
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def valider_enfants
    if @dossier_prestation.enfants_valide!
      redirect_to [:admin, @dossier_prestation], notice: 'Section validée avec succès.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document.", @dossier_prestation.errors.full_messages
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def valider_carriere
    if @dossier_prestation.carriere_valid!
      redirect_to [:admin, @dossier_prestation], notice: 'Section validée avec succès.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document.", @dossier_prestation.errors.full_messages
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def valider_documents
    if @dossier_prestation.document_valid!
      redirect_to [:admin, @dossier_prestation], notice: 'Section validée avec succès.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document.", @dossier_prestation.errors.full_messages
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def create_document
    @document_dossier_prestation = DocumentDossierPrestation.new(document_dossier_prestation_params)
    @document_dossier_prestation.dossier_prestation = @dossier_prestation
    @document_dossier_prestation.date_depot = Date.today

    if @document_dossier_prestation.save
      @dossier_prestation.document_valid!(false)
      redirect_to [:admin, @dossier_prestation], notice: 'Le document est ajouté.'
    else
      flash[:error] = "Une erreur est survenue lors de l'ajout du document."
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def update_document
    @document_dossier_prestation = DocumentDossierPrestation.find(params[:document_dossier_prestation_id])
    @document_dossier_prestation.update(document_dossier_prestation_params)
    redirect_to [:admin, @document_dossier_prestation.dossier_prestation], notice: 'Le document à été modifié avec succès'
  end

  def update_document_form
    @document_dossier_prestation = DocumentDossierPrestation.find(params[:document_dossier_prestation_id])
  end

  def destroy_document
    @document_dossier_prestation = DocumentDossierPrestation.find(params[:document_dossier_prestation_id])
    @document_dossier_prestation.destroy
    redirect_to [:admin, @dossier_prestation], notice: 'Le document à été suprimer avec succès.'
  end

  def create_document_tdp
    @carriere_dossier_prestation = CarriereDossierPrestation.new(carriere_dossier_prestation_params)
    @carriere_dossier_prestation.dossier_prestation = @dossier_prestation
    @carriere_dossier_prestation.date_depot = Date.today
    @carriere_dossier_prestation.annee = params[:annee]["presence(1i)"] if params[:annee]

    #@carriere_dossier_prestation.infos_jour!(true)
    #@carriere_dossier_prestation.infos_heure!(false)
    if @carriere_dossier_prestation.save
      flash[:notice] = 'Le document TDP est ajouté.'
      redirect_to [:admin, @dossier_prestation]
    else
      flash[:error] = "Trimestre non valide.", @carriere_dossier_prestation.errors.full_messages
      #render :show
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def edit_carriere
    @carriere = CarriereDossierPrestation.find(params[:carriere_id])
  end

  def delete_carriere
    @carriere_dossier_prestation = CarriereDossierPrestation.find(params[:carriere_id])
    @carriere_dossier_prestation.destroy
    redirect_to [:admin, @dossier_prestation], notice: 'Temps de présence suupprimé avec succès.'
  end

  def update_document_tdp
    @carriere = CarriereDossierPrestation.find(params[:carriere_id])
    @carriere.update(carriere_dossier_prestation_params.merge(id: @carriere.id))

    if @carriere.save
      redirect_to [:admin, @dossier_prestation], notice: 'Temps de présence mis à jour.'
    else
      flash[:error] = "Echec mis à jour."
      #render :show
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def recipisse_dossier
    @dossier_prestation = DossierPrestation.find(params[:id] || params[:dossier_prestation_id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Récépissé du dossier de prestation No. #{@dossier_prestation.id}",
               page_size: 'A4',
               template: "admin/dossier_prestations/recipisse_dossier.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def historique_dossier
    @dossier_prestations = DossierPrestation.find(params[:dossier_prestation_id])

    render template: "/admin/dossier_prestations/historique_dossier"
  end

  # def soumettre
  #   @dossier_prestation.etat = :soumis
  #   @dossier_prestation.date_soumission = DateTime.now
  #   if @dossier_prestation.save!
  #     redirect_to [:admin, @dossier_prestation], notice: 'Le dossier de prestation est soumis !'
  #   else
  #     redirect_to [:admin, @dossier_prestation]
  #   end
  # end

  def soumettre
    if @dossier_prestation.creation?
      @dossier_prestation.est_soumis!
      @dossier_prestation.date_soumission = DateTime.now
      @dossier_prestation.ajoute_par = current_user
      @dossier_prestation.traite_le = DateTime.now
    end
    if @dossier_prestation.save
      redirect_to [:admin, @dossier_prestation], notice: 'Le dossier de prestation est soumis !'
    else
      flash[:error] = "Une erreur est survenue lors de la soumission."
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def soumission_form; end

  def retour
    @dossier_prestation = DossierPrestation.new(id: params[:dossier_prestation_id])
  end

  def retour_sous_dossiers
    dossier_avec_conjoints = DossierPrestation.all.where(num_affiliation: @dossier_prestation.num_affiliation).where.not(conjoint_id: nil)
    dossier_avec_conjoints.each { |dossier_avec_conjoint|
      dossier_avec_conjoint.etat = :creation
      dossier_avec_conjoint.motif_rejet = "Retour dossier allocataire"
      dossier_avec_conjoint.save
    }
  end

  def retour_process
    if @dossier_prestation.soumis?
      @dossier_prestation.update(dossier_prestation_retour_params.merge(traite_le: DateTime.now, date_soumission: nil))
      @dossier_prestation.retour_creation!
      redirect_to [:admin, @dossier_prestation], notice: 'Le dossier de prestation est retourné avec succés !'
    end
  end

  def generer_paiement
    puts "id =====> #{params[:id]} - #{params[:paiement_id]}"
    @paiement = PaiementAllocataire.find(params[:id] || params[:dossier_prestation_id])

    #@dossier_prestation = DossierPrestation.find(params[:id] || params[:dossier_prestation_id])
    @dossier_prestation = @paiement.dossier_prestation

    @prestation_prenatales = AllocationPrenatale.where(paiement_id: @paiement.id)
    @prestation_postnatales = AllocationPostnatale.where(paiement_id: @paiement.id)
    @prestation_familiales = AllocationFamiliale.where(paiement_id: @paiement.id)

    @paiement = PaiementAllocataire.where(numero_allocataire: @dossier_prestation.num_affiliation).last

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "paiement prestation n°. #{@dossier_prestation.id}",
               page_size: 'A4',
               template: "admin/dossier_prestations/paiement_prestation.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def valider_prenatales
    cpt = 0
    @allocation_prenatales = @dossier_prestation.allocation_prenatales.soumis

    @allocation_prenatales.each do |allocation_prenatale|
      if @dossier_prestation.feminin?
        migrated_allocation = @dossier_prestation.allocations_prenatales_migrees.find_by(volet: allocation_prenatale.read_attribute_before_type_cast(:volet), date_visite: allocation_prenatale.date_visite)
      else
        migrated_allocation = @dossier_prestation.allocations_prenatales_migrees.find_by(volet: allocation_prenatale.read_attribute_before_type_cast(:volet), conjoint_id: allocation_prenatale.dossier_prestation.conjoint.old_conjoint_id, date_visite: allocation_prenatale.date_visite)
      end
      cpt += 1 unless migrated_allocation.nil?
      next unless migrated_allocation.nil?
      allocation_prenatale.etat = :valide
      allocation_prenatale.traite_par = current_user
      allocation_prenatale.traite_le = DateTime.now
      allocation_prenatale.date_validation = Date.today
      allocation_prenatale.save
    end
    message = 'Prestations prénatales validées. '
    message = [message, cpt, ' allocations déjà payées dans progress'].join('') if cpt > 0
    flash[:notice] = message
    redirect_to admin_dossier_prestation_allocation_prenatales_path(@dossier_prestation)
  end

  def liquider_prenatales
    cpt = 0
    @allocation_prenatales = @dossier_prestation.allocation_prenatales.creation

    @allocation_prenatales.each do |allocation_prenatale|
      if @dossier_prestation.feminin?
        migrated_allocation = @dossier_prestation.allocations_prenatales_migrees.find_by(volet: allocation_prenatale.read_attribute_before_type_cast(:volet), date_visite: allocation_prenatale.date_visite)
      else
        migrated_allocation = @dossier_prestation.allocations_prenatales_migrees.find_by(volet: allocation_prenatale.read_attribute_before_type_cast(:volet), conjoint_id: allocation_prenatale.dossier_prestation.conjoint.old_conjoint_id, date_visite: allocation_prenatale.date_visite)
      end
      cpt += 1 unless migrated_allocation.nil?
      next unless migrated_allocation.nil?
      allocation_prenatale.etat = 'soumis'
      allocation_prenatale.date_soumission = Date.today
      allocation_prenatale.set_montant_paiement!
      allocation_prenatale.save
    end
    message = 'Prestations prénatales liquidées. '
    message = [message, cpt, ' allocations déjà payées dans progress'].join('') if cpt > 0
    flash[:notice] = message
    redirect_to admin_dossier_prestation_allocation_prenatales_path(@dossier_prestation)

  end

  def valider_postnatales
    cpt = 0
    @allocation_postnatales = @dossier_prestation.allocation_postnatales.soumis

    @allocation_postnatales.each do |allocation_postnatale|
      migrated_allocation = @dossier_prestation.allocations_postnatales_migrees.where.not(enfant_id: nil).find_by(volet: allocation_postnatale.read_attribute_before_type_cast(:volet), enfant_id: allocation_postnatale.enfant.old_id)
      cpt += 1 unless migrated_allocation.nil?
      next unless migrated_allocation.nil?
      allocation_postnatale.etat = :valide
      allocation_postnatale.valide_par = current_user
      allocation_postnatale.traite_par = current_user
      allocation_postnatale.traite_le = DateTime.now
      allocation_postnatale.date_validation = Date.today
      allocation_postnatale.save
    end
    message = 'Prestations postnatales validées. '
    message = [message, cpt, ' allocations déjà payées dans progress'].join('') if cpt > 0
    flash[:notice] = message
    redirect_to admin_dossier_prestation_allocation_postnatales_path(@dossier_prestation)

  end

  def liquider_postnatales
    cpt = 0
    @allocation_postnatales = @dossier_prestation.allocation_postnatales.creation

    @allocation_postnatales.each do |allocation_postnatale|
      migrated_allocation = @dossier_prestation.allocations_postnatales_migrees.where.not(enfant_id: nil).find_by(volet: allocation_postnatale.read_attribute_before_type_cast(:volet), enfant_id: allocation_postnatale.enfant.old_id)
      cpt += 1 unless migrated_allocation.nil?
      next unless migrated_allocation.nil?
      # allocation_postnatale.condition_1=true
      # allocation_postnatale.condition_2=true
      # allocation_postnatale.condition_3=true

      allocation_postnatale.etat = 'soumis'
      allocation_postnatale.date_soumission = Date.today
      allocation_postnatale.set_montant_paiement!
      allocation_postnatale.save
    end
    message = 'Prestations postnatales liquidées. '
    message = [message, cpt, ' allocations déjà payées dans progress'].join('') if cpt > 0
    flash[:notice] = message
    redirect_to admin_dossier_prestation_allocation_postnatales_path(@dossier_prestation)

  end

  def valider_x_postnatales
    cpt = 0
    @allocation_postnatales = AllocationPostnatale.where(dossier_prestation_id: DossierPrestation.en_agence(current_user.admin_agence.id).est_valide.with_allocation_postanatale_soumis.pluck(:id)).soumis

    @allocation_postnatales.each do |allocation_postnatale|
      migrated_allocation = AllocationsPostnatalesMigree.where.not(enfant_id: nil).find_by(volet: allocation_postnatale.read_attribute_before_type_cast(:volet), enfant_id: allocation_postnatale.enfant.old_id)
      cpt += 1 unless migrated_allocation.nil?
      next unless migrated_allocation.nil?
      allocation_postnatale.etat = :valide
      allocation_postnatale.valide_par = current_user
      allocation_postnatale.traite_par = current_user
      allocation_postnatale.traite_le = DateTime.now
      allocation_postnatale.date_validation = Date.today
      allocation_postnatale.save
    end
    message = 'Prestations postnatales validées. '
    message = [message, cpt, ' allocations déjà payées dans progress'].join('') if cpt > 0
    flash[:notice] = message
    redirect_to attente_validation_postnatale_admin_dossier_prestations_path

  end

  def liquider_familiales
    cpt = 0
    @allocation_familiales = @dossier_prestation.allocation_familiales.creation.where(document_valid: true)

    @allocation_familiales.each do |allocation_familiale|
      migrated_allocation = @dossier_prestation.allocations_familiales_migrees.where.not(enfant_id: nil).find_by(annee: allocation_familiale.annee, trimestre: allocation_familiale.read_attribute_before_type_cast(:trimestre), enfant_id: allocation_familiale.enfant.old_id)
      cpt += 1 unless migrated_allocation.nil?
      next unless migrated_allocation.nil?
      allocation_familiale.etat = :soumis
      allocation_familiale.date_soumission = Date.today
      allocation_familiale.date_liquidation = Date.today
      if allocation_familiale.montant_paiement.nil?
        allocation_familiale.montant_paiement = allocation_familiale.montant_a_payer
      end
      allocation_familiale.save
    end

    message = 'Prestations familiales liquidées. '
    message = [message, cpt, ' allocations déjà payées dans progress'].join('') if cpt > 0
    flash[:notice] = message
    redirect_to admin_dossier_prestation_allocation_familiales_path(@dossier_prestation)

  end

  def liquider_familiales_by_period
    annee = params[:annee]
    trimestre = params[:trimestre]
    cpt = 0
    @allocation_familiales = trimestre.nil? ? @dossier_prestation.allocation_familiales.creation.by_year(annee).where(document_valid: true) : @dossier_prestation.allocation_familiales.creation.by_periode(trimestre, annee).where(document_valid: true)

    @allocation_familiales.each do |allocation_familiale|
      migrated_allocation = @dossier_prestation.allocations_familiales_migrees.where.not(enfant_id: nil).find_by(annee: allocation_familiale.annee, trimestre: allocation_familiale.read_attribute_before_type_cast(:trimestre), enfant_id: allocation_familiale.enfant.old_id)
      cpt += 1 unless migrated_allocation.nil?
      next unless migrated_allocation.nil?
      allocation_familiale.etat = :soumis
      allocation_familiale.date_soumission = Date.today
      allocation_familiale.date_liquidation = Date.today
      if allocation_familiale.montant_paiement.nil?
        allocation_familiale.montant_paiement = allocation_familiale.montant_a_payer
      end
      allocation_familiale.save
      puts 'errorliq', allocation_familiale.errors.full_messages
    end
    message = 'Prestations familiales liquidées. '
    message = [message, cpt, ' allocations déjà payées dans progress'].join('') if cpt > 0
    flash[:notice] = message
    redirect_to admin_dossier_prestation_allocation_familiales_path(@dossier_prestation)

  end

  def valider_familiales
    cpt = 0
    @allocation_familiales = @dossier_prestation.allocation_familiales.soumis.not_from_echeance

    @allocation_familiales.each do |allocation_familiale|
      migrated_allocation = @dossier_prestation.allocations_familiales_migrees.where.not(enfant_id: nil).find_by(annee: allocation_familiale.annee, trimestre: allocation_familiale.read_attribute_before_type_cast(:trimestre), enfant_id: allocation_familiale.enfant.old_id)
      cpt += 1 unless migrated_allocation.nil?
      next unless migrated_allocation.nil?
      allocation_familiale.etat = :valide
      allocation_familiale.valide_par = current_user
      allocation_familiale.traite_par = current_user
      allocation_familiale.traite_le = DateTime.now
      allocation_familiale.date_validation = Date.today
      allocation_familiale.save
    end

    message = 'Prestations familiales validées. '
    message = [message, cpt, ' allocations déjà payées dans progress'].join('') if cpt > 0
    flash[:notice] = message
    redirect_to admin_dossier_prestation_allocation_familiales_path(@dossier_prestation)
  end

  def rejeter_familiales
    @allocation_familiales = @dossier_prestation.allocation_familiales.soumis.not_from_echeance

    @allocation_familiales.each do |allocation_familiale|
      allocation_familiale.etat = :rejete
      allocation_familiale.rejete_par = current_user
      allocation_familiale.traite_par = current_user
      allocation_familiale.traite_le = DateTime.now
      allocation_familiale.date_rejet = Date.today
      allocation_familiale.save
    end

    flash[:notice] = 'Prestations familiales validées.'
    redirect_to admin_dossier_prestation_allocation_familiales_path(@dossier_prestation)
  end

  def valider_paiement
    ValiderPaiementsDossierPrestationJob.perform_now(@dossier_prestation, current_user)

    flash[:notice] = "Génération de l'ordre de paiement en cours ..."

    redirect_to [:admin, @dossier_prestation]
  end

  def valider_x_paiement
    @dp_postnatales = DossierPrestation.with_allocation_postanatale_valide
    @dp_prenatales = DossierPrestation.with_allocation_prenatale_valide
    @dp_familiales = DossierPrestation.with_allocation_familiale_valide
    all_dp = (@dp_familiales + @dp_postnatales + @dp_prenatales)
    @dossier_prestations = DossierPrestation.where(id: all_dp.map(&:id)).en_agence(current_user.admin_agence.id).est_valide

    @dossier_prestations.each do |dossier_prestation|
      next unless ValiderPaiementsDossierPrestationJob.perform_now(dossier_prestation, current_user)
    end
    flash[:notice] = "Génération des ordres de paiement en cours ..."
    redirect_to valider_ordre_admin_dossier_prestations_path
  end

  def create_allocataire
    allocataire = Allocataire.where(numero_allocataire: @dossier_prestation.num_affiliation).first

    if allocataire.nil?
      allocataire = Allocataire.new
      allocataire.numero_allocataire = @dossier_prestation.num_affiliation
      allocataire.nom = @dossier_prestation.nom
      allocataire.prenom = @dossier_prestation.prenom
      allocataire.date_naissance = @dossier_prestation.date_naissance
      #allocataire.categorie = :familiale
      # allocataire.nombre_epouses = 0
      # allocataire.nombre_enfants = 0
      # allocataire.adresse_rue
      # allocataire.adresse_ville
      # allocataire.code_pays
      # allocataire.code_region
      # allocataire.code_commune
      # allocataire.telephone
      allocataire.save
    end
  end

  def create_allocataire_pf
    allocataire_pf = AllocatairePf.where(numero_allocataire: @dossier_prestation.num_affiliation).first

    if allocataire_pf.nil?
      allocataire_pf = AllocatairePf.new
      allocataire_pf.numero_allocataire = @dossier_prestation.num_affiliation
      allocataire_pf.nom = @dossier_prestation.nom
      allocataire_pf.prenom = @dossier_prestation.prenom
      allocataire_pf.date_naissance = @dossier_prestation.date_naissance

      allocataire_pf.save

    end

  end

  def maintien_prestations
    @maintien_prestation = MaintienPrestation.new
    @maintien_prestation_last = MaintienPrestation.where(dossier_prestations_id: @dossier_prestation.id).last
  end

  def create_maintien_prestations
    date_demande = Date.today
    @maintien_prestation = MaintienPrestation.new(maintien_prestations_params)
    @maintien_prestation.type_maintien = MaintienPrestation.type_maintiens[:chomage]
    @maintien_prestation.dossier_prestation = @dossier_prestation
    @maintien_prestation.date_demande_maintien = date_demande
    @maintien_prestation.date_arret_maintien = @dossier_prestation.get_date_arret_maintien(@maintien_prestation)
    if @maintien_prestation.save
      if @dossier_prestation.valide?
        @dossier_prestation.est_suspendu!
        @dossier_prestation.suspandu_par = current_user
        @dossier_prestation.date_suspension = Date.today
        @dossier_prestation.save
      end
      redirect_to admin_dossier_prestation_maintien_prestations_path(@dossier_prestation), notice: 'La demande de maintien a été enregistrée avec succès'
    else
      render :maintien_prestations
    end

  end

  def cancel_maintien_prestation
    @maintien_prestation = MaintienPrestation.find(params[:maintien_id])
    @maintien_prestation.inactif!
    @maintien_prestation.save
    if @maintien_prestation.dossier_prestation.suspendu?
      @maintien_prestation.dossier_prestation.retour_valides!
    end
    redirect_to admin_dossier_prestation_maintien_prestations_path(@dossier_prestation), notice: 'Le dossier a été réactivé avec succès'
  end

  def delete_maintien_prestation
    @maintien_prestation = MaintienPrestation.find(params[:maintien_id])
    if @maintien_prestation.destroy
      if @maintien_prestation.dossier_prestation.suspendu?
        @maintien_prestation.dossier_prestation.retour_valides!
      end
      redirect_to admin_dossier_prestation_maintien_prestations_path(@dossier_prestation), notice: 'Le dossier a été réactivé avec succès'
    end
  end

  def show_raison_social
    @employeur = Psrm::Employeur.find_by(fhnum: params[:fhnum])
  end

  def add_beneficiary
    @conjoint = Conjoint.find(params[:conjoint_id])
    @conjoint.is_beneficiary!
    redirect_to admin_dossier_prestation_path(@dossier_prestation), notice: 'Le conjoint a été choisi en tant bénéficiaire avec succès.'
  end

  def add_beneficiary_pre_post
    @dossier_prestation.full_name_beneficiare = @dossier_prestation.full_name
    @dossier_prestation.save
    redirect_to admin_dossier_prestation_path(@dossier_prestation), notice: 'Le bénéficiaire a été changé avec succès.'
  end

  def delete_beneficiary_pre_post
    @dossier_prestation.full_name_beneficiare = nil
    @dossier_prestation.save
    redirect_to admin_dossier_prestation_path(@dossier_prestation), notice: 'Le bénéficiaire a été changé avec succès.'
  end

  def remove_beneficiary
    @conjoint = Conjoint.find(params[:conjoint_id])
    @conjoint.is_not_beneficiary_anymore!
    redirect_to admin_dossier_prestation_path(@dossier_prestation), notice: "Le conjoint n'est plus bénéficiaire."
  end

  def renewal_child_documents
    @enfant = Enfant.find(params[:child_id])
  end

  def renewal_documents_historic
    @q = Document.where(documentable_type: Enfant.name, documentable_id: @dossier_prestation.enfants.pluck(:id)).order(created_at: :desc).ransack(params[:q])
    @renewed_documents = @q.result.page(params[:page]).per(100)
  end

  def details_pf_historics
    @pf_historic = DossierPrestationHistoric.find(params[:pf_historics_id])
  end

  def dossier_prestation_historics
    @q = @dossier_prestation.dossier_prestation_historics.order(created_at: :desc).ransack(params[:q])
    @pf_historics = @q.result.page(params[:page]).per(100)
  end

  def detail_allocation_familiale_migree
    @allocation_familiale_migree = AllocationsFamilialesMigree.find(params[:allocation_id])
  end

  def detail_allocation_prenatales_migree
    @allocation_prenatale_migree = AllocationsPrenatalesMigree.find(params[:allocation_id])
  end

  def detail_allocation_postnatale_migree
    @allocation_postnatale_migree = AllocationsPostnatalesMigree.find(params[:allocation_id])
  end

  def create_cloture_request
    @cloture_request = DemandePfCloture.new(cloture_params)
    @cloture_request.admin_agence = current_user.admin_agence
    @cloture_request.workflow_state = :soumis
    @cloture_request.dossier_prestation = @dossier_prestation
    @cloture_request.soumis_par = current_user
    if @cloture_request.save
      flash[:notice] = 'Demande soumise avec succés.'
      redirect_to [:admin, @dossier_prestation]
    else
      flash[:error] = 'Une erreur est syrvenue lors de la soumission.'
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def clotures_requests
    @q = DemandePfCloture.with_soumis_state.where(admin_agence_id: User.current.agence.id).ransack(params[:q])
    @requests = @q.result.order('created_at desc').page(params[:page]).per(100)
  end

  def cloturer
    @request = DemandePfCloture.find(params[:request_id])
    if @request.soumis?
      @request.est_valide!
      @request.date_validation = Date.today
      @request.valide_par = current_user
      @request.save
    end
    @dossier_prestation.etat = :cloturer
    @dossier_prestation.date_cloture = Date.today
    @dossier_prestation.cloture_par = current_user
    if @dossier_prestation.save(validate: false)
      flash[:notice] = 'Dossier cloturé avec succés.'
      redirect_to clotures_requests_admin_dossier_prestations_path
    else
      error_message = @dossier_prestation.errors.full_messages
      flash[:error] = 'Une erreur est survenue lors de la cloturation !', error_message
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def cancel_cloture_request
    @request = DemandePfCloture.find(params[:request_id])
    if @request.update(cloture_request_params.merge(workflow_state: :rejete, date_annulation: DateTime.now, annule_par: current_user))
      redirect_to clotures_requests_admin_dossier_prestations_path, notice: 'Demande rejetée avec succès.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement !'
      redirect_to clotures_requests_admin_dossier_prestations_path
    end

  end

  def affecter_dossier
    @agent = User.find(params[:agent_id])
    @dossier_prestation.set_as_agent_chosen(@agent.id)
    redirect_to admin_dossier_prestation_path(@dossier_prestation), notice: 'L' 'agent a été choisi en tant que titulaire du dossier.'
  end

  def annuler_affectation_dossier
    @agent = User.find(params[:agent_id])
    @dossier_prestation.is_not_agent_chosen_anymore(@agent.id)
    redirect_to admin_dossier_prestation_path(@dossier_prestation), notice: 'L' 'agent a été retiré en tant que titulaire du dossier.'
  end

  def create_attributaire_tierce
    @atttributaire_tierce = AttributaireTierce.new(attributaire_tierce_params)
    @atttributaire_tierce.ajoute_par = current_user
    @atttributaire_tierce.workflow_state = :creation
    @atttributaire_tierce.dossier_prestation = @dossier_prestation

    if @atttributaire_tierce.save
      redirect_to [:admin, @dossier_prestation], notice: 'Attributaire tierce créé avec succès.'
    else
      flash[:error] = "Une erreur est survenue lors de la création de l'attributaire !"
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def destroy_attributaire_tierce
    @attributaire_tierce = AttributaireTierce.find(params[:at_id])
    if @attributaire_tierce.destroy
      redirect_to [:admin, @dossier_prestation], notice: 'Attributaire supprimée avec succès.'
    else
      flash[:error] = "Une erreur est survenue lors de la suppression de l'attributaire !"
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def soumettre_attributaire_tierce
    @attributaire_tierce = AttributaireTierce.find(params[:at_id])
    if @attributaire_tierce.creation?
      @attributaire_tierce.est_soumis!
      @attributaire_tierce.date_soumission = DateTime.now
      @attributaire_tierce.soumis_par = current_user
    end
    if @attributaire_tierce.save
      redirect_to [:admin, @dossier_prestation], notice: 'Attributaire tierce soumis avec succès !'
    else
      flash[:error] = "Une erreur est survenue lors de la soumission."
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def attributaire_tierce_en_attente
    @dossier_prestations = DossierPrestation.en_agence(current_user.admin_agence.id)
    @q = AttributaireTierce.with_soumis_state.where(dossier_prestation_id: @dossier_prestations.ids).ransack(params[:q])
    @attributaire_tierces = @q.result.order('created_at asc').page(params[:page]).per(100)
  end

  def valider_attributaire_tierce
    @attributaire_tierce = AttributaireTierce.find(params[:at_id])
    if @attributaire_tierce.soumis?
      @attributaire_tierce.est_valide!
      @attributaire_tierce.date_validation = DateTime.now
      @attributaire_tierce.valide_par = current_user
    end
    if @attributaire_tierce.save
      redirect_to attributaire_tierce_en_attente_admin_dossier_prestations_path, notice: 'Attributaire tierce soumis avec succès !'
    else
      flash[:error] = "Une erreur est survenue lors de la soumission."
      redirect_to attributaire_tierce_en_attente_admin_dossier_prestations_path
    end
  end

  def rejeter_attributaire_tierce
    @attributaire_tierce = AttributaireTierce.find(params[:at_id])
    if @attributaire_tierce.update(attributaire_tierce_params.merge(workflow_state: :rejete, date_rejet: DateTime.now, rejete_par: current_user))
      redirect_to attributaire_tierce_en_attente_admin_dossier_prestations_path, notice: 'Attributaire rejeté avec succès.'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement !'
      redirect_to attributaire_tierce_en_attente_admin_dossier_prestations_path
    end
  end

  private

  def do_exist?
    if @dossier_prestation.dossier_exist?
      flash[:error] = "Vous ne pouvez pas valider le dossier : dossier déjà enregistré pour ce salarié"
      redirect_to admin_dossier_prestation_edit_incomplete_path(@dossier_prestation)
    end
  end

  def is_completion_possible?
    unless @dossier_prestation.can_be_completed?
      flash[:error] = "Vous ne pouvez pas valider le dossier : merci de completer les informations manquantes"
      redirect_to admin_dossier_prestation_edit_incomplete_path(@dossier_prestation)
    end
  end

  def generate_reference(dossier_prestation)
    letters = (0..9).to_a + ('A'..'Z').to_a
    dossier_prestation.id.to_s + letters.sample(10).join
  end

  def can_soumettre_operation

  end

  # Use callbacks to share common setup or constraints between actions.
  def set_dossier_prestation
    @dossier_prestation = DossierPrestation.visible_for_admins.find(params[:id] || params[:dossier_prestation_id] || params[:carriere_id] || params[:conjoint_id] )
  rescue ActiveRecord::RecordNotFound => e
    @dossier_prestation = current_user.dossier_prestation_crees.find(params[:id] || params[:dossier_prestation_id] || params[:conjoint_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dossier_prestation_params
    params.require(:dossier_prestation).permit(:sexe_salarie, :num_affiliation, :prenom, :nom, :date_naissance, :date_embauche,
                                               :lieu_naissance, :adresse_domicile, :etat, :date_soumission,
                                               :date_validation, :num_dossier, :conjoint_id, :date_reception, :nationalite, :employeur_actuel, :nin, :telephone, :date_ouverture,
                                               :id_item)
  end

  def soumission_dossier_prestation_params
    params.require(:dossier_prestation).permit(:condition_1, :condition_2, :condition_3)
  end

  def document_dossier_prestation_params
    params.require(:document_dossier_prestation).permit(:type_document, :volet, :document, :commentaire)
  end

  def carriere_dossier_prestation_params
    params.require(:carriere_dossier_prestation).permit(:num_employeur, :raison_sociale, :document, :date_document,
                                                        :trimestre, :premier_mois, :deuxiem_mois, :troisiem_mois, :annee,
                                                        :infos_jour, :infos_heure, :est_justifier, :commentaire,
                                                        :raison_sociale_employeur_mois_2, :raison_sociale_employeur_mois_3,
                                                        :num_employeur_mois_3, :num_employeur_mois_2, :est_justifier_mois2,
                                                        :est_justifier_mois3, :motif_mois1, :motif_mois2, :motif_mois3)
  end

  def carriere_dossier_prestation_edit_params
    params.require(:carriere_dossier_prestation).permit(:num_employeur, :raison_sociale, :document, :date_document,
                                                        :trimestre, :premier_mois, :deuxiem_mois, :troisiem_mois, :annee, :infos_jour, :infos_heure, :est_justifier)
  end

  private def maintien_prestations_params
    params.require(:maintien_prestation).permit(:document_justificatif, :autre_document, :commentaire, :date_effective)
  end

  def cloture_request_params
    params.require(:demande_pf_cloture).permit(:motif_annulation)
  end

  def attributaire_tierce_params
    params.require(:attributaire_tierce).permit(:prenom, :nom, :nin, :motif_rejet)
  end

  def cloture_params
    params.require(:demande_pf_cloture).permit(:motif, :commentaire, :document_justificatif)
  end

  def peut_etre_edite!
    unless @dossier_prestation.creation?
      flash[:error] = "Vous ne pouvez pas éditer un dossier déjà soumis"
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def can_add!
    unless current_user.can_add_dossier_prestation?
      flash[:error] = "Vous ne pouvez pas ajouter un nouveau dossier de prestation. Il y'a déjà un en cours"
      redirect_to admin_dossier_prestations_path
    end
  end

  def can_valide_operation
    unless current_user.chef_agence? #and current_user.admin_agence.id == @dossier_prestation.ajoute_par.admin_agence.id
      flash[:error] = "Vous ne pouvez pas valider ce dossier de prestation. Vous n'est pas abilité."
      redirect_to admin_dossier_prestations_path
    end
  end

  def can_validate_document_section
    if @dossier_prestation.documents.length == 0
      flash[:error] = "Vous devez ajouter au moins un document."
      redirect_to [:admin, @dossier_prestation]
    end
  end

  def can_update_or_delete_tdp
    carrier = @dossier_prestation.carriere_dossier_prestations.find(params['carriere_id'])
    paid_allocations = @dossier_prestation.allocation_familiales.where(annee: carrier.annee, trimestre: carrier.trimestre, paiement: true)

    unless paid_allocations.count == 0
      flash[:error] = "Impossible de supprimer ce temps de présence ! Le temps de présence est lié à des allocations familiales déjà payées."
      redirect_to admin_dossier_prestation_path(@dossier_prestation)
    end
  end

  def can_update_or_delete_folder
    sub_folders = DossierPrestation.where(num_affiliation: @dossier_prestation.num_affiliation).where.not(conjoint_id: nil)

    unless @dossier_prestation.carriere_dossier_prestations.count == 0
      flash[:error] = "Suppression impossible ! Le dossier est lié à des temps de présence."
      redirect_to admin_dossier_prestation_path(@dossier_prestation)
      return
    end

    unless @dossier_prestation.allocation_familiales.count == 0
      flash[:error] = "Suppression impossible ! Le dossier est lié à des allocations familiales."
      redirect_to admin_dossier_prestation_path(@dossier_prestation)
      return
    end

    sub_folders.each do |folder|
      unless folder.allocation_postnatales.count == 0
        flash[:error] = "Suppression impossible ! Le dossier est lié à des allocations postnatales."
        redirect_to admin_dossier_prestation_path(@dossier_prestation)
        return
      end

      unless folder.allocation_prenatales.count == 0
        flash[:error] = "Suppression impossible ! Le dossier est lié à des allocations prénatales."
        redirect_to admin_dossier_prestation_path(@dossier_prestation)
        return
      end

      unless folder.grossesses.count == 0
        flash[:error] = "Suppression impossible ! Le dossier est lié à des grossesses."
        redirect_to admin_dossier_prestation_path(@dossier_prestation)
        return
      end
    end
  end

  def can_regularize_widow?
    death_salary = DecesSalarie.find_by(numero_affiliation: @dossier_prestation.num_affiliation)
    if death_salary.nil?
      flash[:error] = 'Informations décès introuvable!'
      redirect_to [:admin, @dossier_prestation]
      return
    end

    if death_salary.date_deces.nil?
      flash[:error] = 'Date décès non renseignée!'
      redirect_to [:admin, @dossier_prestation]
      return
    end

    unless Conjoint.where(numero_affiliation: @dossier_prestation.num_affiliation).not_incomplete.not_deleted.exists?
      flash[:error] = 'Conjoint introuvables!'
      redirect_to [:admin, @dossier_prestation]
      return
    end

    unless Enfant.where(numero_affiliation: @dossier_prestation.num_affiliation).not_incomplete.not_deleted.exists?
      flash[:error] = 'Enfants introuvables!'
      redirect_to [:admin, @dossier_prestation]
      return
    end
  end

  def can_access_reg_widow
    death_salary = DecesSalarie.find_by(numero_affiliation: @dossier_prestation.num_affiliation)

    if death_salary.nil?
      flash[:error] = 'Informations décès introuvables!'
      redirect_to admin_dossier_prestation_regularisation_widow_path(@dossier_prestation)
      return
    end

    if death_salary.date_deces.nil?
      flash[:error] = 'Date de décès non renseignée!'
      redirect_to admin_dossier_prestation_regularisation_widow_path(@dossier_prestation)
      return
    end
  end

  def can_generate_allocation_for_individual
    @trimestre = params[:trimestre].to_i
    @annee = params[:annee].to_i
    if @dossier_prestation.get_amount_af_to_regularize(@annee, @trimestre).zero?
      flash[:error] = 'Régularisation impossible!'
      redirect_to admin_dossier_prestation_individual_regularisation_af_details_path(@dossier_prestation, @trimestre, @annee)
      return
    end
  end

  def can_generate_allocation_after_term
    @trimestre = params[:trimestre].to_i
    @annee = params[:annee].to_i
    @nbr_month_left = params[:nbr_month_left].to_i
    if @nbr_month_left.zero?
      flash[:error] = 'Régularisation impossible!'
      redirect_to admin_dossier_prestation_regularisation_after_term_details_path(@dossier_prestation, @trimestre, @annee)
      return
    end
  end

end
