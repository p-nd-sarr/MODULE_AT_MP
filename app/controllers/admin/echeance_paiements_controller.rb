class Admin::EcheancePaiementsController < Admin::ApplicationController
  before_action :set_echeance_paiement, only: [
    :show, :rejeter, :valider_liquidation, :valider_instruction, :valider_service, :valider_directeur, :revisions,
    :suspensions, :sortie_majorations, :regularisations, :changement_infos, :paiements, :primo_pensionnes, :suivi_avis,
    :suivi_avances, :extinctions, :changement_adresses, :changement_mode_paiements, :pension_alimentaires
  ]

  def index
    @echeance_paiements = EcheancePaiement.all.order('annee desc, numero_periode desc')
  end

  def en_attente_validation_instruction
    @echeance_paiements = EcheancePaiement.with_creation_state
  end

  def en_attente_validation_liquidation
    @echeance_paiements = EcheancePaiement.with_creation_state
  end

  def en_attente_validation_service
    @echeance_paiements = EcheancePaiement.with_valider_chef_section_state
  end

  def en_attente_validation_dp
    @echeance_paiements = EcheancePaiement.with_valider_chef_service_state
  end

  def valider_instruction
    @echeance_paiement.instruit_par = current_user
    @echeance_paiement.instruit_le = DateTime.now
    @echeance_paiement.validation_instruction = true
    @echeance_paiement.save
    flash[:notice] = 'Echeance Paiement valider par le chef de section instruction'
    redirect_to [:admin, @echeance_paiement]
  end

  def valider_liquidation
    @echeance_paiement.liquider_par = current_user
    @echeance_paiement.liquider_le = DateTime.now
    @echeance_paiement.validation_liquidation = true
    @echeance_paiement.save
    flash[:notice] = 'Echeance Paiement valider par le chef de section instruction'
    redirect_to [:admin, @echeance_paiement]
  end

  def valider_service
    if @echeance_paiement.valider_chef_section?
      puts "====> valider_service"
      @echeance_paiement.valider_service_par = current_user
      @echeance_paiement.valider_service_le = DateTime.now
      @echeance_paiement.section_valider!
      #@echeance_paiement.save
      flash[:notice] = 'Echeance Paiement validé'
      redirect_to [:admin, @echeance_paiement]
    else
      redirect_to [:admin, @echeance_paiement]
    end
  end

  def valider_directeur
    if @echeance_paiement.valider_chef_service?
      @echeance_paiement.service_valider!
      @echeance_paiement.valider_par = current_user
      @echeance_paiement.valider_le = DateTime.now
      @echeance_paiement.save
      flash[:notice] = 'Echeance Paiement validé'
      redirect_to [:admin, @echeance_paiement]
    else
      redirect_to [:admin, @echeance_paiement]
    end
  end

  def rejeter
    @echeance_paiement.est_rejete!
    @echeance_paiement.traite_par = current_user
    @echeance_paiement.traite_le = DateTime.now
    @echeance_paiement.save
    flash[:notice] = 'Echeance Paiement rejeté'
    redirect_to [:admin, @echeance_paiement]
  end

  def show
    @paiements = @echeance_paiement.paiement_allocataires.includes(:allocataire).page(params[:page]).per(100)
    @dossier_liquidations = LiquidationRetraite.all
  end

  def primo_pensionnes
    @q = Allocataire.actif.periode_activation(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).ransack(params[:q])
    # @liquidation_valides = LiquidationRetraite.with_dossier_valide_state.periode(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).page(params[:page]).per(100)
    @allocataires = @q.result.page(params[:page]).order('nom, prenom, numero_allocataire').per(100)
  end

  def revisions
    @q = RevisionPension.with_valider_revision_state.periode(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).ransack(params[:q])
    @revision_pensions = @q.result.page(params[:page]).order('created_at').per(100)
  end

  def extinctions
    @q = Allocataire.eteint.periode_eteint(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).ransack(params[:q])
    @allocataires = @q.result.page(params[:page]).order('nom, prenom, numero_allocataire').per(100)
  end

  def suspensions
    @q = Allocataire.suspendus.periode_suspension(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).ransack(params[:q])
    @allocataires = @q.result.page(params[:page]).order('nom, prenom, numero_allocataire').per(100)
  end

  def sortie_majorations
    @q = Allocataire.sortie_majorations(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).ransack(params[:q])
    @allocataires = @q.result.page(params[:page]).order('nom, prenom, numero_allocataire').per(100)
  end

  def regularisations
    #@regularisation_pensions = RegularisationPension.regularise.periode(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).page(params[:page]).per(100)
    @q = RegularisationPension.with_validation_inspection_state.periode(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).ransack(params[:q])
    @regularisation_pensions = @q.result.page(params[:page]).order('nom, prenom, numero_allocataire').per(100)
  end

  def changement_infos
    @q = AllocataireSuiviModification.periode(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).ransack(params[:q])
    @modifcation_allocataires = @q.result.page(params[:page]).order('created_at').per(100)
  end

  def paiements
    # @montant_total = @echeance_paiement.compta_transactions.sum(:montant)
    @q = @echeance_paiement.ordre_paiements.ransack(params[:q])
    @nombre_dossiers = @q.result.count(:numero_allocataire)
    @ordre_paiements = @q.result.includes(:allocataire, :compta_transactions).order('numero desc')
    @ordre_paiements = @ordre_paiements.page(params[:page]).per(100) unless params[:format] == 'xlsx'
    if params[:format] == 'xlsx'
      response.headers['Content-Disposition'] = "attachment; filename=""echeance_paiement_#{@echeance_paiement.created_at.strftime('%Y_%m_%d')}.xlsx"""
    end
  end

  def suivi_avis
    @q = AvisTier.periode(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).ransack(params[:q])
    @avis_tiers = @q.result.page(params[:page]).order('created_at').per(100)
  end

  def suivi_avances
    @q = PretAllocataire.periode(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).ransack(params[:q])
    @pret_allocataires = @q.result.page(params[:page]).order('created_at').per(100)
  end

  def changement_mode_paiements
    @q = ModifierModePaiement.with_dossier_valide_state.periode(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).ransack(params[:q])
    @modifier_mode_paiements = @q.result.page(params[:page]).order('created_at').per(100)
  end

  def changement_adresses
    @q = ModifierAdresse.with_dossier_valide_state.periode(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).ransack(params[:q])
    @modifier_adresses = @q.result.page(params[:page]).order('created_at').per(100)
    #@modifier_adresses = ModifierAdresse.with_dossier_valide_state
  end

  def pension_alimentaires
    @q = PensionAlimentaire.validation_directeur.periode(@echeance_paiement.periode_variation_debut, @echeance_paiement.periode_variation_fin).ransack(params[:q])
    @pension_alimentaires = @q.result.page(params[:page]).order('created_at').per(100)
  end

  private

  def set_echeance_paiement
    @echeance_paiement = EcheancePaiement.find(params[:id] || params[:echeance_paiement_id])
  end
end