class Admin::PaiementsController < ApplicationController
  before_action :set_allocataire, only: [:index, :show, :new]

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

    @paiement.date_paiement = DateTime.now
    @paiement.etat = :soumis

    respond_to do |format|
      if @paiement.save
        format.html { redirect_to [:admin, @allocataire, @paiement], notice: 'La demande de regularisation pension was successfully created.' }
        format.json { render :index, status: :created, location: @paiement }
      else
        format.html { render :new }
        format.json { render json: @paiement.errors, status: :unprocessable_entity }
      end
    end
  end

  def generer_paiement
    @paiement = OrdrePaiement.find(params[:paiement_id])
    unless @paiement.beneficiaire_id.nil?
      @beneficiary = @paiement.conjoint? ? Conjoint.find(@paiement.beneficiaire_id) : AttributaireTierce.find(@paiement.beneficiaire_id)
    end
    @dossier_prestation = @paiement.dossier

    @prestation_prenatales = @paiement.allocation_prenatales
    @prestation_postnatales = @paiement.allocation_postnatales
    @prestation_familiales = @paiement.allocation_familiales
    @montant_total = (@prestation_prenatales.sum(:montant_paiement) + @prestation_postnatales.sum(:montant_paiement) + @prestation_familiales.sum(:montant_paiement))

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Ordre de paiement #{@paiement.numero}",
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

  def generer_paiement_caf
    @paiement = OrdrePaiement.find(params[:paiement_id])
    unless @paiement.beneficiaire_id.nil?
      @beneficiary = CafConjoint.find(@paiement.beneficiaire_id)
    end
    @prestation_exterieure = @paiement.dossier
    @associations = @paiement.indemnites_prestation_exterieure_assocs

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Ordre de paiement #{@paiement.numero}",
               page_size: 'A4',
               template: "admin/prestation_exterieures/paiement_prestation.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def generer_paiement_icm
    @paiement = OrdrePaiement.find(params[:paiement_id])

    @dossier_maternite = @paiement.dossier

    @indemnite_conges_maternites = @paiement.indemnite_conges_maternites

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Ordre de paiement #{@paiement.numero}",
               page_size: 'A4',
               template: "admin/dossier_maternites/paiement_prestation.html.erb",
               layout: "pdf.html",
               orientation: "Landscape",
               lowquality: true,
               zoom: 1,
               pi: 75
      end
    end
  end

  def set_allocataire
    @allocataire = Allocataire.find(params[:allocataire_id])
  end

end