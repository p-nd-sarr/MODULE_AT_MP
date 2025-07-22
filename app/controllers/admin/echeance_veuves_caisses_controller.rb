class Admin::EcheanceVeuvesCaissesController < ApplicationController
  before_action :set_echeance_veuves_caisse, only: [:show, :show_veuve, :change_statut, :all_liquidations_slices, :liquidation_details, :generer_ordre_paiement]
  before_action :set_veuve, only: [:show_veuve]

  # GET echeance_veuves_caisses
  def index
    @echeances = EcheanceVeuvesCaisse.all.order('created_at DESC').page(params[:page]).per(50)
  end

  # GET echeance_veuves_caisses/1
  def show
    @q = if current_user.admin?
           @echeance.echeance_veuves_caisse_epouses
         elsif current_user.gestionnaire_compte_allocataire? or current_user.chef_agence? or current_user.comptable?
           @echeance.echeance_veuves_caisse_epouses.where(admin_agence_id: current_user.agence_id)
         else
           EcheanceVeuvesCaisseEpouse.none
         end
    @q = @q.ransack(params[:q])
    @epouses = @q.result.order('nom').page(params[:page]).per(50)
    @epouses_liq = EcheanceVeuvesCaisseEpouse.joins(:echeance_veuves_caisse_enfants).where(echeance_veuves_caisse_epouses: { echeance_veuves_caisse_id: @echeance.id, admin_agence_id: current_user.agence_id }, echeance_veuves_caisse_enfants: { document_valide: true, liquide: false }).distinct('echeance_veuves_caisse_epouses.id')
  end

  def show_veuve
    @enfants = @veuve.echeance_veuves_caisse_enfants.includes(:enfant).order('numero_ordre')
  end

  def change_statut
    statut = params[:statut]

    if @echeance.current_state.events.keys.exclude?(statut.to_sym)
      redirect_to admin_echeance_veuves_caiss_path(@echeance), alert: "Evenement #{statut} non autorisé"
      return
    end

    begin
      @echeance.send("#{statut}!", current_user)
    rescue Workflow::TransitionHalted => e
      redirect_to admin_echeance_veuves_caiss_path(@echeance), alert: e.message
      return
    end
    if params[:echeance_veuves_caisse]
      @echeance.update(echeance_veuve_retour_params)
    end
    redirect_to admin_echeance_veuves_caiss_path(@echeance), notice: 'Statut changé'
  end

  def all_liquidations_slices
    @q = @echeance.echeance_veuves_caisse_lot_liquidations.ransack(params[:q])
    @echeance_lot_liquidations = @q.result.page(params[:page]).per(10)
  end

  def liquidation_details
    @echeance_lot_liquidation = @echeance.echeance_veuves_caisse_lot_liquidations.find(params[:liquidation_id])
    @echeance_liquidations = @echeance_lot_liquidation.echeance_veuves_caisse_liquidations
    @q = EcheanceVeuvesCaisseEpouse.joins(:echeance_veuves_caisse_enfants).where(echeance_veuves_caisse_enfants: { id: @echeance_liquidations.pluck(:echeance_veuves_caisse_enfant_id) }).distinct.ransack(params[:q])
    @epouses = @q.result.page(params[:page]).per(20)
  end

  def generer_ordre_paiement
    @paiement = OrdrePaiement.find(params[:ordre_id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Ordre de paiement #{@paiement.numero}",
               page_size: 'A4',
               template: "admin/echeance_veuves_caisses/generer_ordre_paiement.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end

  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_echeance_veuves_caisse
    @echeance = EcheanceVeuvesCaisse.find(params[:id] || params[:echeance_veuves_caiss_id])
  end

  def set_veuve
    @veuve = @echeance.echeance_veuves_caisse_epouses.find(params[:veuve_id])
  end

  def echeance_veuve_retour_params
    params.require(:echeance_veuves_caisse).permit(:motif_retour)
  end
end
