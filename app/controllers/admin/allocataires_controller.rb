# frozen_string_literal: true

class Admin::AllocatairesController < ApplicationController
  before_action :set_allocataire, only: %i[show list_grappe_familiale valider rejeter soumettre edit update
                                           activer suspendre demande_suspension historique lever_suspension
                                           affilier_association affiliation_association imprimer_carte_allocataire rejeter_allocataire]
  before_action :recup_param, only: [:show]
  before_action :create_historique, only: %i[soumettre suspendre lever_suspension rejeter]

  def index
    @q = Allocataire.all.ransack(params[:q])
    @allocataires = @q.result.order('nom, prenom, numero_allocataire')
    unless params[:format] == 'xlsx'
      @allocataires = @allocataires.page(params[:page]).per(100)
    end
    if params[:format] == 'xlsx'
      response.headers['Content-Disposition'] = 'attachment; filename=' "allocataires_#{Date.today.strftime('%Y_%m_%d')}.xlsx" ''
      render :liste
    end
  end

  def all_revisions
    @q = RevisionPension.all.ransack(params[:q])
    @revision_pensions = @q.result.order('created_at desc')
    @revision_pensions = @q.result.order('created_at desc').page(params[:page]).per(100) unless params[:format] == 'xlsx'
  end

  def historiques_suivi
    # @q = AllocataireSuiviModification.all.ransack(params[:q])
    if params[:q].nil?
      params[:q] = {}
      params[:q][:created_at_gteq] = Date.today.strftime('%Y-%m-%d')
      params[:q][:created_at_lteq] = Date.today.strftime('%Y-%m-%d')
    end
    if params[:q][:created_at_gteq].empty?
      params[:q][:created_at_gteq] = Date.today.strftime('%Y-%m-%d')
    end
    if params[:q][:created_at_lteq].empty?
      params[:q][:created_at_lteq] = Date.today.strftime('%Y-%m-%d')
    end
    @q = AllocataireSuiviModification.all.ransack(params[:q])
    @historique_suivi_allocataires = @q.result.page(params[:page]).per(100)
  end

  def demandes_en_attente
    @q = Allocataire.inactif.ransack(params[:q])
    @total = @q.result.count
    @allocataires = @q.result.page(params[:page]).order('created_at').per(100)
    @allocataires = @allocataires unless params[:format] == 'xlsx'
  end

  def demandes_a_activer
    @q = Allocataire.valider.ransack(params[:q])
    @total = @q.result.count
    @allocataires = @q.result.page(params[:page]).order('date_activation_dp').per(100)
  end

  def allocataires_actifs
    @q = Allocataire.allocataires_actifs.ransack(params[:q])
    @total = @q.result.count
    @allocataires = @q.result.order('date_activation_dp')
  end

  def allocataires_eteints
    @q = Allocataire.allocataires_eteints.ransack(params[:q])
    @total = @q.result.count
    @allocataires = @q.result.order('date_eteint')
  end

  def allocataires_affilies_association
    @q = Allocataire.allocataires_affilies_association.ransack(params[:q])
    @total = @q.result.count
    @allocataires = @q.result.order('numero_allocataire')
  end

  def historiques_paiements
    @q = OrdrePaiement.all.ransack(params[:q])
    @total = @q.result.count
    @ordre_paiements = @q.result.page(params[:page]).order('numero_allocataire').per(100)
  end

  def toutes_les_demandes
    @modifier_adresses = ModifierAdresse.all
    @modifier_mode_paiements = ModifierModePaiement.all
    @regularisation_pensions = RegularisationPension.all
    @demande_grappe_familiales = UpdateGrappeFamiliale.all
    @demande_revisions = RevisionPension.all
    @suspension_allocataires = SuspensionAllocataire.all

    @en_attente_allocataires = Allocataire.valider
  end

  def demandes_grappes_familiales_affectees
    @update_grappe_conjoints = UpdateGrappeFamiliale.all.where(etat: :affecte, affectation_allocataire: current_user.id).where.not('conjoint_id IS ?', nil)
    @update_grappe_enfants = UpdateGrappeFamiliale.all.where(etat: :affecte, affectation_allocataire: current_user.id).where.not('enfant_id IS ?', nil)
  end

  def demandes_modifier_adresses
    @modifier_adresses = ModifierAdresse.all
    @en_attente_soumissions = @modifier_adresses.with_creation_state.page(params[:page]).per(100)
    @en_attentes_affectations =  @modifier_adresses.with_soumis_state.en_attente_affectation.page(params[:page]).per(100)
    @en_attentes_modif_soumis =  @modifier_adresses.with_soumis_state.where(affectation_allocataire: current_user.id)
    @en_attentes_validation_dossier = @modifier_adresses.with_modif_soumis_state.page(params[:page]).per(100)
    @validees =   @modifier_adresses.with_dossier_valide_state.page(params[:page]).per(100)
    @rejetees =   @modifier_adresses.with_dossier_rejete_state.page(params[:page]).per(100)
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires allocataires
  end

  def demandes_modifier_mode_paiements
    @modifier_mode_paiements = ModifierModePaiement.all
    @en_attente_soumissions = @modifier_mode_paiements.with_creation_state.page(params[:page]).per(100)
    @en_attentes_affectations = @modifier_mode_paiements.with_soumis_state.en_attente_affectation.page(params[:page]).per(100)
    @en_attentes_modif_soumis = @modifier_mode_paiements.with_soumis_state.where(affectation_allocataire: current_user.id)
    @en_attentes_validation_dossier = @modifier_mode_paiements.with_modif_soumis_state.page(params[:page]).per(100)
    @validees =  @modifier_mode_paiements.with_dossier_valide_state.page(params[:page]).per(100)
    @rejetees =  @modifier_mode_paiements.with_dossier_rejete_state.page(params[:page]).per(100)
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires allocataires
  end

  def demandes_regularisation_pensions
    @regularisation_pensions = RegularisationPension.all
    @en_attente_soumissions = @regularisation_pensions.with_creation_state.page(params[:page]).per(100)
    @en_attente_instruction = @regularisation_pensions.with_soumis_state.page(params[:page]).per(100)
    @en_attentes_affectations = @regularisation_pensions.with_instruit_state.en_attente_affectation.page(params[:page]).per(100)
    @en_attentes_soumission_recap =  @regularisation_pensions.with_instruit_state.where(affectation_allocataire: current_user.id)
    @en_attentes_validation_recap =  @regularisation_pensions.with_recap_soumis_state
    @en_attentes_validation_dossier = @regularisation_pensions.with_recap_valide_state.page(params[:page]).per(100)
    @validees = @regularisation_pensions.with_dossier_valide_state.page(params[:page]).per(100)
    @dossiers_regularises = @regularisation_pensions.with_regularise_state.page(params[:page]).per(100)
    @rejetees = @regularisation_pensions.with_dossier_rejete_state.page(params[:page]).per(100)
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires allocataires
  end

  def demandes_grappes_familiales
    @gestionnaires = User.gestionnaire_compte_allocataire # avoir la liste des gestionnaires allocataires
    @update_grappe_conjoints = UpdateGrappeFamiliale.all.where(etat: :soumis).where.not('conjoint_id IS ?', nil)
    @update_grappe_enfants = UpdateGrappeFamiliale.all.where(etat: :soumis).where.not('enfant_id IS ?', nil)
  end

  def suspension_soumis
    @demandes_suspension_allocataires = SuspensionAllocataire.all.where(etat: :soumis)
  end

  def suspendus
    @q = Allocataire.all.where(etat: :suspendus).ransack(params[:q])
    @allocataires = @q.result.page(params[:page]).per(100)
  end

  def en_attente_soumission
    @modifier_mode_paiements = ModifierModePaiement.en_attente_soumission
  end

  def show
    @allocataire = Allocataire.find(params[:id] || params[:allocataire_id])
    # @historique = Historique.all.where(allocataire_id: @allocataire.id)

    # @demande_liquidation = LiquidationRetraite.find_by_allocataire_id(@allocataire.id)

    @carriere = Carriere.new
  end

  def demande_suspension
    @allocataire = Allocataire.find_by(numero_allocataire: params[:matricule])
  end

  def edit
    unless current_user.super_admin?
      redirect_to [:admin, @allocataire], notice: 'Vous ne pouvez pas modifier cet allocataire'
      return
    end
  end

  def update
    unless current_user.super_admin?
      redirect_to [:admin, @allocataire], notice: 'Vous ne pouvez pas modifier cet allocataire'
      return
    end

    if @allocataire.update(allocataire_params)
      redirect_to [:admin, @allocataire], notice: 'Allocataire mis à jour avec succès.'
    else
      render :edit
    end
  end

  def new
    @allocataire = Allocataire.new
  end

  def new_allocataire_pf
    @allocataire = Allocataire.new
  end

  def soumettre
    # @allocataire = Allocataire.find_by_numero_allocataire(params[:matricule])
    if @allocataire.update(motif_params.merge(etat: :soumis, date_soumission: Date.today))
      record_history('Suspension allocataire', @allocataire.etat)
      redirect_to admin_allocataires_path, notice: 'La demande de suspension est soumise.'
    end
  end

  def activer
    @allocataire.etat = :actif
    @allocataire.date_activation_insp = Date.today
    if @allocataire.save
      redirect_to admin_allocataires_path, notice: 'Allocataire activé avec succés.'
    end
  end

  def valider
    @allocataire.etat = :valider
    @allocataire.date_activation_dp = Date.today
    if @allocataire.save
      redirect_to admin_allocataires_path, notice: 'Allocataire validé avec succés.'
    end
  end

  #   def rejeter
  #     @allocataire.etat = :rejete
  #     if @allocataire.save
  #       record_history("Suspension allocataire",@allocataire.etat)
  #       redirect_to admin_allocataires_path, notice: 'Allocataire validé avec succés.'
  #     end
  #   end
  #
  # def rejeter1
  #   if @allocataire.update(allocataire_rejet_params.merge(etat: :rejete,
  #                                                         traite_par: current_user,
  #                                                         traite_le: DateTime.now))
  #     redirect_to [:admin, @allocataire], notice: 'Allocataire rejeté.'
  #   else
  #     flash[:error] = 'Une erreur est survenue lors du traitement'
  #     redirect_to [:admin, @allocataire]
  #   end
  # end

  def rejeter
    rejet_allocataire_from_liquidation(@allocataire) unless @allocataire.liquidation_retraite.nil?
    rejet_allocataire_from_reversion_avant_liquidation(@allocataire) unless @allocataire.dossier_reversion_salary.nil?
    rejet_allocataire_from_reversion_apres_liquidation(@allocataire) unless @allocataire.reversion_veuve.nil?
  end

  def suspendre
    @allocataire.etat = :suspendus
    if @allocataire.save
      record_history('Suspension allocataire', @allocataire.etat)
      redirect_to admin_allocataires_path, notice: 'Allocataire suspendu avec succés.'
    end
  end

  def lever_suspension
    @allocataire.etat = :actif
    if @allocataire.save
      record_history('lever_suspension', @allocataire.etat)
      redirect_to admin_allocataires_path, notice: 'la levée de suspension a été effectué avec succés.'
    else
      redirect_to admin_allocataires_path
    end
  end

  # Les affectations allocataires

  def affecter_update_grappe_familiale
    @update_grappe_familiale = UpdateGrappeFamiliale.find(params[:id] || params[:update_grappe_familiale_id])
    @allocataire = Allocataire.find_by(numero_allocataire: @update_grappe_familiale.num_affiliation)
    if @update_grappe_familiale.update!(grappe_familiale_affecter_allocataire_params.merge(affectation_allocataire_date: DateTime.now,
                                                                                           etat: :affecte))
      record_history('affectation mise a jour grappe familiale', @update_grappe_familiale.etat)
      redirect_to admin_demandes_grappes_familiales_path, notice: 'Demande de modification a ete affecté aux gestionnaires.'
    end
  end

  def create_historique
    if @allocataire.actif?
      historique = Historique.new
      historique.date_soumission = Time.zone.now
      historique.etat = :soumis
      historique.allocataire_id = @allocataire.id
      historique.user_id = current_user.id
      historique.save

    elsif @allocataire.soumis?
      historique = Historique.new
      historique.date_suspension = Time.zone.now
      historique.etat = :suspendus
      historique.allocataire_id = @allocataire.id
      historique.user_id = current_user.id
      historique.save

    elsif @allocataire.suspendus?
      historique = Historique.new
      historique.date_lever_suspension = Time.zone.now
      historique.etat = :lever_suspension
      historique.allocataire_id = @allocataire.id
      historique.user_id = current_user.id
      historique.save
    elsif @allocataire.inactif?
      historique = Historique.new
      historique.evenement = 'rejet liquidation de retraite'
      historique.etat = :rejete
      historique.allocataire_id = @allocataire.id
      historique.user_id = current_user.id
      historique.save
    end
  end

  def historique
    @historique = Historique.all.where(allocataire_id: @allocataire.id)
  end

  ##########-----------Forms des  demandes ---------------------------------------------

  def update_grappe_familiale_form
    @conjoints = Conjoint.all.where(numero_affiliation: @allocataire.numero_allocataire)
    @enfants = Enfant.all.where(numero_affiliation: @allocataire.numero_allocataire)
  end

  def list_grappe_familiale
    @conjoints = Conjoint.all.where(numero_affiliation: @allocataire.numero_allocataire)
    @enfants = Enfant.all.where(numero_affiliation: @allocataire.numero_allocataire)
  end

  def update_grappe_form
    @type = params[:type]
    @etat = params[:etat]
    @update_grappe_familiale = UpdateGrappeFamiliale.new
    if @type == 'enfant'
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

  def sousmettre_grappe_familiale
    @etat = params[:etat]
    @type = params[:type]

    @update_grappe_familiale = UpdateGrappeFamiliale.new(grappe_familiale_params)
    @update_grappe_familiale.user = current_user
    @update_grappe_familiale.ajoute_par = current_user

    if @etat == 'divorce'
      @update_grappe_familiale.etat = :soumis
      @update_grappe_familiale.type_demande = :divorce
    else
      @update_grappe_familiale.etat = :soumis
      @update_grappe_familiale.type_demande = :deces
    end

    if @update_grappe_familiale.save!
      redirect_to admin_demandes_grappes_familiales_path, notice: 'Déclaration de deces encours de traitement.'
    else
      render :new
    end
  end

  ###########---------------Validations des demandes allocataires----------------------------

  def valider_update_grappe_enfant
    @update_grappe_familiale = UpdateGrappeFamiliale.find(params[:id] || params[:update_grappe_familiale_id])
    @allocataire = Allocataire.find_by(numero_allocataire: @update_grappe_familiale.num_affiliation)
    @enfant = Enfant.find(@update_grappe_familiale.enfant_id)
    @update_grappe_familiale.traite_par = current_user
    @update_grappe_familiale.traite_le = DateTime.now
    @update_grappe_familiale.etat = :valide
    @enfant.etat = :deces
    @enfant.save

    if @update_grappe_familiale.save
      record_history('valider_update_grappe_enfant', @update_grappe_familiale.etat)
      redirect_to admin_demandes_grappes_familiales_path, notice: 'Demande de modification validée.'
    end
  end

  def valider_update_grappe_conjoint
    @update_grappe_familiale = UpdateGrappeFamiliale.find(params[:id] || params[:update_grappe_familiale_id])
    @allocataire = Allocataire.find_by(numero_allocataire: @update_grappe_familiale.num_affiliation)
    @conjoint = Conjoint.find(@update_grappe_familiale.conjoint_id)
    @update_grappe_familiale.traite_par = current_user
    @update_grappe_familiale.traite_le = DateTime.now
    @update_grappe_familiale.etat = :valide
    @conjoint.etat = if @update_grappe_familiale.type_demande == 'Décédé'
                       :deces
                     else
                       :divorce
                     end
    @conjoint.save
    if @update_grappe_familiale.save
      record_history('valider_update_grappe_conjoint', @update_grappe_familiale.etat)
      redirect_to admin_demandes_grappes_familiales_path, notice: 'Demande de modification validée.'
    end
  end

  def valider_suspension_allocataire
    @suspension_allocataires = SuspensionAllocataire.find(params[:id])
    @allocataire = Allocataire.find_by(numero_allocataire: @suspension_allocataires.numero_allocataire)
    @suspension_allocataires.valider_par = current_user
    @suspension_allocataires.date_validation = DateTime.now
    @suspension_allocataires.etat = :valide
    @suspension_allocataires.save
    @allocataire.etat = :suspendus
    if @allocataire.save
      record_history('valider_demande_suspension_allocataires',  @suspension_allocataires.etat)
      redirect_to [:admin, @allocataire], notice: 'La demande de suspension a été effectuée avec success.'
    end
  end

  def show_suspension_allocataire
    @suspension_allocataire = SuspensionAllocataire.find(params[:id] || params[:suspension_allocataires_id])
  end

  def rejeter_suspension_allocataire
    @suspension_allocataire = SuspensionAllocataire.find(params[:id] || params[:suspension_allocataire_id])

    if @suspension_allocataire.update(suspension_allocataire_motifs_rejet_params.merge(traite_par: current_user,
                                                                                       traite_le: DateTime.now, etat: :rejete))

      redirect_to admin_toutes_les_demandes_path, notice: 'La demande de suspension a été rejetée avec succés.'
   end
  end

  def affiliation_association; end

  def affilier_association
    if @allocataire.update(affiliation_association_params)
      redirect_to [:admin, @allocataire], notice: 'Allocataire affilié à une association avec succés..'
    else
      flash[:error] = 'Une erreur est survenue lors du traitement'
      redirect_to [:admin, @allocataire]
    end
  end

  #####------------------------Rejets des demandes d'allocataires---------------------------------

  def rejeter_update_grappe_enfant
    @update_grappe_familiale = UpdateGrappeFamiliale.find(params[:id] || params[:update_grappe_familiale_id])

    if @update_grappe_familiale.update(update_grappe_motifs_rejet_params.merge(traite_par: current_user,
                                                                               traite_le: DateTime.now, etat: :rejete))
      redirect_to admin_demandes_grappes_familiales_path, notice: 'Demande rejetée avec succès .'
    end
  end

  def rejeter_update_grappe_conjoint
    @update_grappe_familiale = UpdateGrappeFamiliale.find(params[:id] || params[:update_grappe_familiale_id])

    if @update_grappe_familiale.update(update_grappe_motifs_rejet_params.merge(traite_par: current_user,
                                                                               traite_le: DateTime.now, etat: :rejete))
      redirect_to admin_demandes_grappes_familiales_path, notice: 'Demande rejetée avec succès .'
    end
  end

  def import
    user_id = current_user.id

    if params[:file].nil?
      redirect_to '/admin/allocataires', notice: 'Fichier introuvable'
    else
      Allocataire.my_import(params[:file], user_id, params[:etat])
      redirect_to '/admin/allocataires', notice: 'Fichier allocataire importé avec succés'
    end
  end

  def update_affiliation
    user_id = current_user.id
    if params[:file].nil?
      redirect_to '/admin/allocataires', notice: 'Fichier introuvable'
    else
      Allocataire.update_affiliation(params[:file], user_id)
      redirect_to '/admin/allocataires', notice: 'Fichier allocataire importé avec succés'
    end
  end

  def imprimer_carte_allocataire
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Carte allocataire no. #{@allocataire.id}",
               page_size: 'A5',
               template: 'admin/allocataires/carte_allocataire.html.erb',
               layout: 'pdf.html',
               orientation: 'Landscape',
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  ######-----------------------Details des demandes allocataies---------------------------------
  def show_update_grappe_familiale
    @update_grappe_familiale = UpdateGrappeFamiliale.find(params[:id] || params[:update_grappe_familiale_id])
  end

  def grappe_familiale_affecter_allocataire_params
    params.require(:update_grappe_familiale).permit(:affectation_allocataire)
  end

  def grappe_familiale_params
    params.require(:update_grappe_familiale).permit(:num_affiliation, :prenom, :nom, :date_deces,
                                                    :lieu_deces, :etat, :adresse_domicile, :date_soumission,
                                                    :date_validation, :num_dossier, :conjoint_id, :enfant_id, :attachment)
  end

  def motif_params
    params.require(:allocataire).permit(:motif_suspension)
  end

  def recup_param
    @allocataire = Allocataire.find_by(numero_allocataire: params[:matricule])
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:id] || params[:allocataire_id])
    puts "===> allocataire: #{@allocataire.id}"
  end

  ######-------------------Params Motifs rejet demandes allocataires----------------------------------------

  def allocataire_params
    params.require(:allocataire).permit(:prenom, :nom, :numero_allocataire, :ipres_ancien_matric, :date_naissace, :etat, :adresse_rue, :telephone, :adresse_ville, :mode_paiement, :sexe, :situation_matrimoniale_code, :numero_identification_nationale, :type_piece_identification_id,
                                        :points_rg, :points_rc, :points_base_rg, :points_base_rc, :point_minoration_rg, :point_minoration_rc, :point_majoration_rg, :point_majoration_rc, :points_servis_rg, :points_servis_rc)
  end

  def suspension_allocataire_motifs_rejet_params
    params.require(:suspension_allocataire).permit(:motif_rejet)
  end

  def update_grappe_motifs_rejet_params
    params.require(:update_grappe_familiale).permit(:motif_rejet)
  end

  def record_history(type_demande, etat)
    historique = Historique.new
    historique.evenement = type_demande
    historique.etat = etat
    historique.allocataire_id = @allocataire.id
    historique.user_id = current_user.id
    historique.save
  end

  def allocataire_rejet_params
    params.require(:allocataire).permit(:motif_rejet)
  end

  def affiliation_association_params
    params.require(:allocataire).permit(:admin_association_allocataire_id)
  end

  def rejet_allocataire_from_liquidation(allocataire)
    demande = allocataire.liquidation_retraite
    if current_user.directeur_prestation?
      unless demande.nil?
        demande.workflow_state = :creation
        demande.motif_rejet_allocataire = allocataire_rejet_params[:motif_rejet]
        demande.rejet_allocataire_par_id = current_user.id
        demande.date_rejet_allocataire = DateTime.now
        demande.allocataire_id = nil
        demande.save
      end
      allocataire.destroy
      redirect_to admin_allocataires_path, notice: 'Allocataire a été rejeté avec succés.'
    elsif current_user.inspection?
      allocataire.etat = :inactif
      allocataire.motif_rejet = allocataire_rejet_params[:motif_rejet]
      allocataire.save

      redirect_to [:admin, allocataire]
    end
  end

  def rejet_allocataire_from_reversion_avant_liquidation(allocataire)
    demande = allocataire.dossier_reversion_salary
    if current_user.directeur_prestation?
      unless demande.nil?
        demande.etat = :creation
        demande.motif_rejet_allocataire = allocataire_rejet_params[:motif_rejet]
        demande.rejet_allocataire_par_id = current_user.id
        demande.date_rejet_allocataire = DateTime.now
        demande.allocataire_id = nil
        demande.save
        base = demande.base_reversion_salary
        base.workflow_state = :creation
        base.save
      end
      allocataire.destroy
      redirect_to admin_allocataires_path, notice: 'Allocataire a été rejeté avec succés.'
    elsif current_user.inspection?
      allocataire.etat = :inactif
      allocataire.motif_rejet = allocataire_rejet_params[:motif_rejet]
      allocataire.save

      redirect_to [:admin, allocataire]
    end
  end

  def rejet_allocataire_from_reversion_apres_liquidation(allocataire)
    demande = allocataire.reversion_veuve
    if current_user.directeur_prestation?
      unless demande.nil?
        demande.workflow_state = :creation
        demande.motif_rejet_allocataire = allocataire_rejet_params[:motif_rejet]
        demande.rejet_allocataire_par_id = current_user.id
        demande.date_rejet_allocataire = DateTime.now
        demande.allocataire_id = nil
        demande.save
      end
      allocataire.destroy
      redirect_to admin_allocataires_path, notice: 'Allocataire a été rejeté avec succés.'
    elsif current_user.inspection?
      allocataire.etat = :inactif
      allocataire.motif_rejet = allocataire_rejet_params[:motif_rejet]
      allocataire.save

      redirect_to [:admin, allocataire]
    end
  end
end
