class Admin::PaiementsCaissesController < ApplicationController
  before_action :set_paiement, only: [:show, :rendre_impayee]

  def index
    # @q = Caisse::Paiement.where('created_at >= ?', Date.new(2022, 3, 1)).ransack(params[:q])
    @q = Caisse::Paiement.ransack(params[:q])
    @nombre_lignes = @q.result.count
    @montant_payes = @q.result.paye.sum(:montant)

    if params[:format] == 'xlsx'
      @paiements = @q.result.includes(:allocataire).order('date_paiement desc, numero_ordre desc')
    else
      @paiements = @q.result.includes(:allocataire).order('date_paiement desc, numero_ordre desc').page(params[:page]).per(50)
    end
  end

  def show; end # :noqa

  def rendre_impayee
    if @paiement.rendre_impaye!(current_user)
      flash[:notice] = "L'état de la facture a été bien modifié"
    else
      flash[:error] = "Vous ne pouvez pas changer l'état de ce paiement"
    end
    render :show
  end

  private

  def set_paiement
    @paiement = Caisse::Paiement.find(params[:id] || params[:paiements_caisse_id])
  end
end
