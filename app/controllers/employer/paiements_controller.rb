class Employer::PaiementsController < Employer::ApplicationController
  before_action :peut_acceder!
  def index

   # @paiements = Psrm::Reglement.where(ANC_NUM_IPRES: current_user.num_ipres).page(params[:page]).per(10)

  end

  def new
    @paiement = Paiement.new

    @factures = Facture.where("statut = 0").order("created_at DESC")
  end

  def peut_acceder!
    @immatriculation = current_user.immatriculations.first
    if @immatriculation == nil or @immatriculation.statut_demande != nil
      flash[:info] = "Immatriculation pas encore valide. Veillez faire la demande!"
      redirect_to [:employer, 'immatriculations']
    end
  end
end