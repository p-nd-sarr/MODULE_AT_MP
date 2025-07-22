class Admin::OrdrePaiementsController < Admin::ApplicationController
  before_action :set_ordre_paiement, only: [:show, :rendre_impaye, :marquer_impaye, :annuler_impaye]
 

  def index
    @echeance_paiements = OrdrePaiement.all.order('created_at desc')
  end

  def show
  end

  def en_attente_validation_impayes
    @ordre_paiements = OrdrePaiement.marques_impayes.page(params[:page]).per(100)
  end



  def marquer_impaye
    motif = ordre_paiement_motif_impaye_params[:motif_impaye]
    @ordre_paiement.marquer_impaye(current_user, motif)
    redirect_to [:admin, @ordre_paiement], notice: 'ordre de paiement est marqué impayé avec succés.'
  end 

  def rendre_impaye
    @ordre_paiement.rendre_impaye(current_user)
    redirect_to en_attente_validation_impayes_admin_ordre_paiements_path, notice: 'ordre de paiement est rendu impayé avec succés.'
  end 

  def annuler_impaye
    @ordre_paiement.annuler_impaye
    if current_user.agent_dfc?
       redirect_to [:admin, @ordre_paiement], notice: 'ordre de paiement est marqué impayé avec succés.'
    else
      redirect_to en_attente_validation_impayes_admin_ordre_paiements_path, notice: 'ordre de paiement est rendu impayé avec succés.'
    end
    
  end 

  private

  def set_ordre_paiement
    @ordre_paiement = OrdrePaiement.find(params[:id] || params[:ordre_paiement_id])
  end

  def ordre_paiement_motif_impaye_params
    params.require(:ordre_paiement).permit(:motif_impaye)
  end

end