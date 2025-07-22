class Admin::EcheanceCaissesController < ApplicationController
  before_action :set_echeance, only: [:show, :show_employeur, :show_dossier, :bordereaux, :edit_employeur,
                                      :update_employeur, :change_statut_employeur, :generate_order, :generate_payment_order, :payment_orders, :show_order, :set_individual_payment, :remove_individual_payment, :exclude_from_echeance]
  before_action :set_employeur, only: [:show_employeur, :show_dossier, :edit_employeur, :update_employeur,
                                       :change_statut_employeur, :generate_order, :generate_payment_order, :payment_orders, :show_order, :set_individual_payment, :remove_individual_payment, :exclude_from_echeance]

  def index
    @echeances = EcheanceCaisse.all.order('created_at DESC').page(params[:page]).per(50)
  end

  def show
    @q = if current_user.admin?
           @echeance.echeance_caisse_employeurs
         else
           @echeance.echeance_caisse_employeurs.where(code_agence_css: current_user.agence.try(:code_psrm))
         end
    @q = @q.ransack(params[:q])
    @employeurs = @q.result.order('raison_sociale').page(params[:page]).per(50)
  end

  def en_attente
    @q = if current_user.chef_agence?
           EcheanceCaisseEmployeur.where(code_agence_css: current_user.agence.try(:code_psrm), workflow_state: :liquide)
         elsif current_user.comptable?
           EcheanceCaisseEmployeur.where(code_agence_css: current_user.agence.try(:code_psrm), workflow_state: :liquidation_valide)
         end
    @q = @q.ransack(params[:q])
    @employeurs = @q.result.order('raison_sociale').page(params[:page]).per(50)
  end

  def bordereaux
    @code_agences = @echeance.echeance_caisse_employeurs.distinct.pluck(:code_agence_css)
    if current_user.admin?
      @autre = @code_agences.include?(nil)
    elsif current_user.gestionnaire_compte_allocataire?
      @code_agences = @code_agences.select { |agence_code| agence_code == current_user.admin_agence.code_psrm }
    end
    @agences = Admin::Agence.where(code_psrm: @code_agences.compact)
  end

  def show_employeur
    @q = @employeur.echeance_caisse_dossiers.ransack(params[:q])
    @dossiers = @q.result.page(params[:page]).per(50)
    @dossiers_liq = @employeur.echeance_caisse_dossiers.joins(:echeance_caisse_enfants).where(echeance_caisse_enfants: { document_valide: true, liquide: false, payable: true }).distinct('echeance_caisse_dossiers.id')
  end

  def edit_employeur
    @q = @employeur.echeance_caisse_dossiers.order('num_affiliation').ransack(params[:q])
    @dossiers = @q.result
  end

  def update_employeur
    if @employeur.update(employeur_params_for_update)
      redirect_to admin_echeance_caisse_employeur_path(@echeance, @employeur), notice: 'Employeur mis à jour'
    else
      render :edit_employeur, notice: 'Erreur lors de la mise à jour'
    end
  end

  def change_statut_employeur
    @employeur = EcheanceCaisseEmployeur.find(params[:employeur_id])
    statut = params[:statut]

    if @employeur.current_state.events.keys.exclude?(statut.to_sym)
      redirect_to admin_echeance_caisse_employeur_path(@employeur.echeance_caisse, @employeur), alert: "Evenement #{statut} non autorisé"
      return
    end

    begin
      @employeur.send("#{statut}!", current_user)
    rescue Workflow::TransitionHalted => e
      redirect_to admin_echeance_caisse_employeur_path(@employeur.echeance_caisse, @employeur), alert: e.message
      return
    end
    if params[:echeance_caisse_employeur]
      @employeur.update(echeance_employer_retour_params)
    end
    redirect_to admin_echeance_caisse_employeur_path(@employeur.echeance_caisse, @employeur), notice: 'Statut changé'
  end

  def show_dossier
    @dossier = @employeur.echeance_caisse_dossiers.find(params[:dossier_id])
    @enfants = @dossier.echeance_caisse_enfants.includes(:enfant).order('numero_ordre')
  end

  def exclude_from_echeance
    dossier = EcheanceCaisseDossier.find(params[:dossier_id])
    dossier.get_out_of_echeance
    redirect_to admin_echeance_caisse_employeur_path(@echeance, @employeur), notice: 'Allocataire retiré avec succès!'
  end

  def payment_orders
    @q = @employeur.echeance_caisse_lot_liquidations.ransack(params[:q])
    @echeance_lot_liquidations = @q.result.order(created_at: :asc).page(params[:page]).per(10)
  end

  def show_order
    @echeance_employeur = Psrm::Employeur.find_by_fhnum(@employeur.matric)
    @echeance_lot_liquidation = @employeur.echeance_caisse_lot_liquidations.find(params[:echeance_liquidation])
    @echeance_liquidations = @echeance_lot_liquidation.echeance_caisse_liquidations
    @q = @employeur.echeance_caisse_dossiers.joins(:echeance_caisse_enfants).where(echeance_caisse_enfants: { id: @echeance_liquidations.pluck(:echeance_caisse_enfant_id) }).distinct.ransack(params[:q])
    @echeance_caisse_dossiers = @q.result.page(params[:page]).per(20)
  end

  def generate_order
    @echeance_employeur = Psrm::Employeur.find_by_fhnum(@employeur.matric)
    @echeance_lot_liquidation = @employeur.echeance_caisse_lot_liquidations.find(params[:echeance_liquidation])
    @echeance_liquidations = @echeance_lot_liquidation.echeance_caisse_liquidations
    @echeance_caisse_dossiers = @employeur.echeance_caisse_dossiers.joins(:echeance_caisse_enfants).where(echeance_caisse_enfants: { id: @echeance_liquidations.pluck(:echeance_caisse_enfant_id) }).distinct

    respond_to do |format|
      format.html
      format.pdf do
        pdf_page = render_to_string pdf: "ORDRE DE PAIEMENT COLLECTIF",
                                    page_size: 'A4',
                                    template: "admin/echeance_caisses/generate_order.html.erb",
                                    layout: "pdf.html",
                                    orientation: "Landscape",
                                    lowquality: true,
                                    zoom: 1,
                                    pi: 75

        pdf_page = CombinePDF.parse(pdf_page)
        pdf_page.number_pages(number_format: " %s ", location: :bottom_right, font_size: 14)
        send_data pdf_page.to_pdf, filename: "etat_de_paiement.pdf", type: "application/pdf"
      end
    end
  end

  def generate_payment_order
    @echeance_employeur = Psrm::Employeur.find_by_fhnum(@employeur.matric)
    @echeance_lot_liquidation = @employeur.echeance_caisse_lot_liquidations.find(params[:echeance_liquidation])
    @echeance_liquidations = @echeance_lot_liquidation.echeance_caisse_liquidations
    @echeance_caisse_dossiers = @employeur.echeance_caisse_dossiers.joins(:echeance_caisse_enfants).where(echeance_caisse_enfants: { id: @echeance_liquidations.pluck(:echeance_caisse_enfant_id), paiement_individuel: false }).distinct
    @payment_order = OrdrePaiement.where(dossier_id: @echeance_lot_liquidation.id, dossier_type: @echeance_lot_liquidation.class.name).first
    @compta_transaction = @payment_order.compta_transactions.first

    respond_to do |format|
      format.html
      format.pdf do
        pdf_page = render_to_string pdf: "ORDRE DE PAIEMENT COLLECTIF",
                                    page_size: 'A4',
                                    template: "admin/echeance_caisses/generate_payment_order.html.erb",
                                    layout: "pdf.html",
                                    orientation: "Landscape",
                                    lowquality: true,
                                    zoom: 1,
                                    pi: 75

        pdf_page = CombinePDF.parse(pdf_page)
        pdf_page.number_pages(number_format: " %s ", location: :bottom_right, font_size: 14)
        send_data pdf_page.to_pdf, filname: "ordre_de_paiement.pdf", type: "application/pdf"
      end
    end
  end

  def set_individual_payment
    @dossier = @employeur.echeance_caisse_dossiers.find(params[:dossier_id])
    @dossier.set_individual_payment_option
    redirect_to admin_echeance_caisse_dossier_path(@employeur.echeance_caisse, @employeur, @dossier), notice: 'Paiement individuel activé!'
  end

  def remove_individual_payment
    @dossier = @employeur.echeance_caisse_dossiers.find(params[:dossier_id])
    @dossier.remove_individual_payment_option
    redirect_to admin_echeance_caisse_dossier_path(@employeur.echeance_caisse, @employeur, @dossier), notice: 'Paiement individuel désactivé!'
  end

  private

  def set_echeance
    @echeance = EcheanceCaisse.find(params[:id] || params[:echeance_caisse_id])
  end

  def set_employeur
    @employeur = @echeance.echeance_caisse_employeurs.find(params[:employeur_id])
  end

  def employeur_params_for_update
    params
      .require(:echeance_caisse_employeur)
      .permit(:prenom_mandataire, :nom_mandataire, :telephone_mandataire, :email_mandataire, :bordereau_rempli, :identifiant_mandataire, :motif_retour,
              echeance_caisse_dossiers_attributes: [:id,
                                                    :temps_presence_mois1,
                                                    :absence_justifie_mois1,
                                                    :motif_absence_mois1,
                                                    :temps_presence_mois2,
                                                    :absence_justifie_mois2,
                                                    :motif_absence_mois2,
                                                    :temps_presence_mois3,
                                                    :absence_justifie_mois3,
                                                    :motif_absence_mois3
              ]
      )
  end

  def echeance_employer_retour_params
    params.require(:echeance_caisse_employeur).permit(:motif_retour)
  end

  # def show_regularisation
  #   @regularisation = Enrolement::RegularisationPointage.find(params[:regularisation_id])
  #   @total = @regularisation.lignes.count
  #   @total_supprime = @regularisation.lignes.where(supprime: true).count
  #
  #   @q = @regularisation.lignes.ransack(params[:q])
  #   @lignes = @q.result.order('pres_nom, pres_prenom, id DESC').page(params[:page]).per(100)
  # end
  #
  # def valider_regularisation
  #   @regularisation = Enrolement::RegularisationPointage.find(params[:regularisation_id])
  #   @regularisation.valider!(current_user)
  #
  #   redirect_to regularisation_admin_enrolements_path(regularisation_id: @regularisation.id)
  # end
  #
  # def rejeter_regularisation
  #   @regularisation = Enrolement::RegularisationPointage.find(params[:regularisation_id])
  #   @regularisation.rejeter!(current_user)
  #
  #   redirect_to regularisation_admin_enrolements_path(regularisation_id: @regularisation.id)
  # end
  #
  # def delete_regularisation_ligne
  #   @regularisation = Enrolement::RegularisationPointage.find(params[:regularisation_id])
  #   @ligne = @regularisation.lignes.find(params[:regularisation_ligne_id])
  #   @ligne.supprimer!(current_user)
  #   @total_supprime = @regularisation.lignes.where(supprime: true).count
  #   # redirect_to regularisation_admin_enrolements_path(regularisation_id: @regularisation.id)
  # end
  #
  # def paiements_regularisation
  #   @regularisation = Enrolement::RegularisationPointage.find(params[:regularisation_id])
  #   # @montant_total = @regularisation.compta_transactions.sum(:montant)
  #   @q = @regularisation.ordre_paiements.ransack(params[:q])
  #   @nombre_dossiers = @q.result.count(:numero_allocataire)
  #   @ordre_paiements = @q.result.includes(:allocataire, :compta_transactions).order('numero desc')
  #   @ordre_paiements = @ordre_paiements.page(params[:page]).per(100)
  # end
end
