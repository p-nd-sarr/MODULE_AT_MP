class Admin::PaiementAllocatairesController < ApplicationController
  before_action :set_allocataire, only: [:index, :show, :new, :create, :retourner]

  def index
    @paiements = PaiementAllocataire.where(numero_allocataire: @allocataire.numero_allocataire).order("created_at DESC").page(params[:page]).per(10)
  end

  def show
    @paiement = PaiementAllocataire.find(params[:id])
  end

  def new
    @paiement = PaiementAllocataire.new
  end

  def create
    @paiement = PaiementAllocataire.new(paiement_params)
    @paiement.numero_allocataire = @allocataire.numero_allocataire

    @paiement.montant_net = @allocataire.montant_net
    @paiement.regime = @allocataire.regime
    @paiement.mode_paiement = @allocataire.mode_paiement

    @paiement.date_paiement = DateTime.now
    @paiement.etat = :en_attente_paiement

    respond_to do |format|
      if @paiement.save!
        format.html { redirect_to [:admin, @allocataire, @paiement], notice: 'La demande de regularisation pension was successfully created.' }
        format.json { render :index, status: :created, location: @paiement }
      else
        format.html { render :new }
        format.json { render json: @paiement.errors, status: :unprocessable_entity }
      end
    end
  end


  def generer_paiement
    puts "id =====> #{params[:id]} - #{params[:paiement_id]}"
    @paiement = PaiementAllocataire.find(params[:id] || params[:paiement_id])

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

  def retourner
    @paiement = PaiementAllocataire.find(params[:id] || params[:paiement_allocataire_id])
    @paiement.etat = :retourne
    unless @paiement.save
      flash[:error] = "Paiement retourné"
    end
    redirect_to [:admin, @allocataire, @paiement]
  end

  private

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id])
  end

  def paiement_params
    params.require(:paiement_allocataire).permit(:annee, :periode, :mode_paiement)
  end
end
