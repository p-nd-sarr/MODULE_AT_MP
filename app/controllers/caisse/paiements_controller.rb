class Caisse::PaiementsController < Caisse::ApplicationController
  before_action :set_paiement, only: [:show, :confirm_payer, :payer, :decede, :imprimer_paiement]

  def index
    @q = Caisse::Paiement.where('caisse_paiements.created_at >= ?', Date.new(2022, 3, 1)).ransack(params[:q])
    @nombre_lignes = @q.result.count
    @nombre_lignes_depasse = true
    if @nombre_lignes <= 50
      @paiements = @q.result.includes(:allocataire) unless params[:format] == 'xlsx'
      @nombre_lignes_depasse = false
    else
      @paiements = Caisse::Paiement.none
    end
    @paiements = @q.result.includes(:allocataire).order('numero_ordre') if params[:format] == 'xlsx'
  end

  def mine
    @q = Caisse::Paiement.where(user: current_user).ransack(params[:q])
    @nombre_lignes = @q.result.count
    @montant_payes = @q.result.paye.sum(:montant)
    @paiements = @q.result.order('date_paiement desc').page(params[:page]).per(50)
    @paiements = @q.result.order('date_paiement desc') if params[:format] == 'xlsx'
  end

  def show
  end

  def confirm_payer
  end

  def payer
    nin = params[:nin]
    if @paiement.payer!(current_user, nin)
      flash[:notice] = "La facture est payée avec succès"
    else
      flash[:error] = "Une erreur est survenue lors du paiement"
    end

    render :show
    #redirect_to @paiement
  end

  def decede
    if @paiement.est_decede!(current_user)
      flash[:notice] = "L'allocataire est bien marqué comme décédé"
    else
      flash[:error] = "Une erreur est survenue lors du traitement"
    end

    render :show
    #redirect_to @paiement
  end

  def imprimer_paiement
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "paiement n°. #{@paiement.id}",
               page_size: 'A4',
               template: "caisse/paiements/imprimer_paiement.html.erb",
               layout: "pdf.html",
               orientation: "portrait",
               # lowquality: true,
               zoom: 3.6,
               # pi: 75
               margin: {
                 top: 1,
                 right: 1,
                 bottom: 1,
                 left: 1
               }
      end
    end
  end

  private

  def set_paiement
    @paiement = Caisse::Paiement.find(params[:id] || params[:paiement_id])
  end
end
