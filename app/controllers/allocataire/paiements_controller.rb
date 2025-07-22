class Allocataire::PaiementsController < ApplicationController

  def index
    @paiements = PaiementAllocataire.where(numero_allocataire: current_user.numero_salarie).order("created_at DESC").page(params[:page]).per(10)
  end

  def show
    @paiement = PaiementAllocataire.find(params[:id])
  end

end